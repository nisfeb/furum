::  tests for lib/furum-rules: the decisions the agent applies to every
::  remote poke, timer and subscription fact
::
/+  *test, *furum-types, fr=furum-rules
|%
::  a board hosted by ~zod: ~nec posts, ~bud reads, ~wes moderates, and
::  anyone else gets the default role
::
++  brd
  ^-  board
  =|  b=board
  %=  b
    host.info          ~zod
    default-role.info  %reader
    roles              (my ~[[~nec %poster] [~bud %reader] [~wes %mod]])
  ==
::
++  post-at
  |=  [id=@ud created=@da up=@ud dn=@ud]
  ^-  post
  =|  p=post
  %=  p
    id          id
    created     created
    up-votes    (sy (turn (scag up (gulf 1 20)) |=(i=@ `@p`i)))
    down-votes  (sy (turn (scag dn (gulf 101 120)) |=(i=@ `@p`i)))
  ==
::
::  who may moderate, post and delete: the host is a mod with no role
::  entry, and each clause of can-post and can-delete counts on its own
::
++  test-roles
  ;:  weld
    (expect-eq !>(%.y) !>((is-mod:fr ~zod brd)))
    (expect-eq !>(%.y) !>((is-mod:fr ~wes brd)))
    (expect-eq !>(%.n) !>((is-mod:fr ~nec brd)))
    (expect-eq !>(%.y) !>((can-post:fr ~wes brd)))
    (expect-eq !>(%.y) !>((can-post:fr ~nec brd)))
    (expect-eq !>(%.n) !>((can-post:fr ~bud brd)))
    (expect-eq !>(%.n) !>((can-post:fr ~fed brd)))
    (expect-eq !>(%poster) !>((get-role:fr ~fed =/(b brd b(default-role.info %poster)))))
    (expect-eq !>(%.y) !>((can-delete:fr ~nec ~nec brd)))
    (expect-eq !>(%.y) !>((can-delete:fr ~wes ~nec brd)))
    (expect-eq !>(%.n) !>((can-delete:fr ~bud ~nec brd)))
  ==
::
::  a paid board's content goes to mods and paid-up members only, and
::  access ends at the instant it expires
::
++  test-paid-access
  =/  now  ~2026.1.1
  =/  paid=board
    =/  b  brd
    %=  b
      payment  `[100 ~d30 ~]
      paid     (my ~[[~nec (add now 1)] [~bud now]])
    ==
  ;:  weld
    (expect-eq !>(%.y) !>((has-paid-access:fr ~fed brd now)))
    (expect-eq !>(%.y) !>((has-paid-access:fr ~wes paid now)))
    (expect-eq !>(%.y) !>((has-paid-access:fr ~nec paid now)))
    (expect-eq !>(%.n) !>((has-paid-access:fr ~bud paid now)))
    (expect-eq !>(%.n) !>((has-paid-access:fr ~fed paid now)))
  ==
::
::  a non-mod may act once their cooldown has passed, not a tick before;
::  mods are never limited
::
++  test-check-rate-limit
  =/  now  ~2026.1.1..00.10.00
  =/  lim  |=(ago=@dr (my ~[[[~nec %b] [(sub now ago) ~s10]]]))
  ;:  weld
    (expect-eq !>(%.y) !>((check-rate-limit:fr ~nec %b brd now ~)))
    (expect-eq !>(%.y) !>((check-rate-limit:fr ~nec %b brd now (lim ~s10))))
    (expect-eq !>(%.n) !>((check-rate-limit:fr ~nec %b brd now (lim (sub ~s10 1)))))
    (expect-eq !>(%.y) !>((check-rate-limit:fr ~wes %b brd now (lim ~s1))))
  ==
::
::  the cooldown starts at 10s, doubles while someone keeps acting, stops
::  at 10m, and resets once they have been quiet for four cooldowns
::
++  test-update-rate-limit
  =/  now  ~2026.1.1..01.00.00
  =/  after
    |=  [ago=@dr cd=@dr]
    ^-  @dr
    =/  lim  (my ~[[[~nec %b] [(sub now ago) cd]]])
    cooldown:(~(got by (update-rate-limit:fr ~nec %b now lim)) [~nec %b])
  ;:  weld
    (expect-eq !>([now ~s10]) !>((~(got by (update-rate-limit:fr ~nec %b now ~)) [~nec %b])))
    (expect-eq !>(~s20) !>((after ~s15 ~s10)))
    (expect-eq !>(~s20) !>((after (sub ~s40 1) ~s10)))
    (expect-eq !>(~s10) !>((after ~s40 ~s10)))
    (expect-eq !>(~m10) !>((after ~s1 ~m8)))
  ==
::
::  prune runs on one 6-hour grid: every time in a slot names the slot's
::  end, and a run at a slot's end waits for the next
::
++  test-prune-at
  =/  slot  ~2026.1.1..06.00.00
  ;:  weld
    (expect-eq !>(slot) !>((prune-at:fr ~2026.1.1..03.00.00)))
    (expect-eq !>(slot) !>((prune-at:fr (sub slot 1))))
    (expect-eq !>(~2026.1.1..12.00.00) !>((prune-at:fr slot)))
  ==
::
::  auto-prune deletes content: only posts at least `after` old, below the
::  minimum net score, and not pinned. each bound is checked from both sides
::
++  test-prunable
  =/  now  ~2026.2.1
  =/  cut  (sub now ~d7)
  =/  b=board
    =/  b  brd
    %=  b
      pinned  (sy ~[4])
      posts
        %-  my
        :~  [0 (post-at 0 cut 0 0)]
            [1 (post-at 1 (add cut 1) 0 0)]
            [2 (post-at 2 ~2026.1.1 1 0)]
            [3 (post-at 3 ~2026.1.1 2 0)]
            [4 (post-at 4 ~2026.1.1 0 0)]
            [5 (post-at 5 ~2026.1.1 3 5)]
        ==
    ==
  %+  expect-eq
    !>(`(list post-id)`~[0 2 5])
    !>((sort (prunable:fr b [2 ~d7] now) lth))
::
::  what a remote poster can store is bounded: each cap is accepted
::  exactly and refused one byte over, and a post needs a title
::
++  test-post-caps
  =/  txt  |=(n=@ud (crip (reap n 'a')))
  ;:  weld
    (expect-eq !>(%.y) !>((sane-post:fr (txt 300) `(txt 2.048) `(txt 40.000))))
    (expect-eq !>(%.n) !>((sane-post:fr (txt 301) ~ ~)))
    (expect-eq !>(%.n) !>((sane-post:fr '' ~ ~)))
    (expect-eq !>(%.n) !>((sane-post:fr 't' `(txt 2.049) ~)))
    (expect-eq !>(%.n) !>((sane-post:fr 't' ~ `(txt 40.001))))
    (expect-eq !>(%.y) !>((sane-comment:fr (txt 10.000))))
    (expect-eq !>(%.n) !>((sane-comment:fr (txt 10.001))))
    (expect-eq !>(%.n) !>((sane-comment:fr '')))
  ==
::
::  a paid board's group: its moderators and its members whose time has
::  not run out; the host needs none. The next expiry is the soonest
::  still to come
::
++  test-group
  =/  now  ~2026.1.10
  =/  b=board
    =/  b  brd
    %=  b
      roles  (my ~[[~wes %mod] [~bus %poster]])
      paid   (my ~[[~nec (add now ~d1)] [~lur (sub now ~d1)] [~dev (add now ~h1)] [~fed now]])
    ==
  ;:  weld
    (expect-eq !>((sy ~[~wes ~nec ~dev])) !>((group-ships:fr b now)))
    (expect-eq !>(`(add now ~h1)) !>((next-expiry:fr b now)))
    (expect-eq !>(~) !>((next-expiry:fr brd now)))
  ==
::
::  every ship reads each board's pub/, and a free board's content/; a
::  paid board's content never
::
++  test-open-paths
  %+  expect-eq
    !>(`(list path)`~[/boards/f/pub /boards/f/content /boards/p/pub])
  !>((open-paths:fr ~[[%f |] [%p &]]))
::
::  a post the browser flags as cross-site never acts for the owner; a
::  same-origin one, or one with no such header, does
::
++  test-cross-site
  =/  sfs  |=(v=@t ~[['sec-fetch-site' v]])
  ;:  weld
    (expect-eq !>(%.n) !>((cross-site:fr ~)))
    (expect-eq !>(%.n) !>((cross-site:fr ~[['referer' 'x']])))
    (expect-eq !>(%.n) !>((cross-site:fr (sfs 'same-origin'))))
    (expect-eq !>(%.y) !>((cross-site:fr (sfs 'cross-site'))))
    (expect-eq !>(%.y) !>((cross-site:fr (sfs 'same-site'))))
    (expect-eq !>(%.y) !>((cross-site:fr (sfs 'none'))))
  ==
::
::  a fault is said when it is new or its line changed, and counted when
::  it is kept already; a crash (again ~h2) is said again after two quiet
::  hours, a fault waiting for a person never
::
++  test-fault-plan
  =/  now  ~2026.1.1
  =/  old=fault:fr  ['x' now now 1]
  ;:  weld
    (expect-eq !>([& ['x' now now 1]]) !>((fault-plan:fr ~ 'x' now ~)))
    (expect-eq !>([| ['x' now (add now ~m5) 2]]) !>((fault-plan:fr `old 'x' (add now ~m5) ~)))
    (expect-eq !>([& ['y' now (add now ~m5) 2]]) !>((fault-plan:fr `old 'y' (add now ~m5) ~)))
    (expect-eq !>([| ['x' now (add now ~h3) 2]]) !>((fault-plan:fr `old 'x' (add now ~h3) ~)))
    (expect-eq !>([& ['x' (add now ~h3) (add now ~h3) 1]]) !>((fault-plan:fr `old 'x' (add now ~h3) `~h2)))
    (expect-eq !>([| ['x' now (add now ~h1) 2]]) !>((fault-plan:fr `old 'x' (add now ~h1) `~h2)))
  ==
::
::  the grant's faults: a granted road's fault goes; a missing one that
::  must be there is kept and said once; one only needed in use is not
::
++  test-grant-faults
  =/  now  ~2026.1.1
  =/  grant  (need (de:json:html '{"poke":["/sys/behn/"],"peek":[]}'))
  =/  needs  ~[[%timer 'poke' '/sys/behn/' & 'T'] [%read 'peek' '/sys/ames/ships/' & 'R'] [%iris 'poke' '/sys/iris/' | 'I']]
  =/  kept  (my ~[[%timer ['T' now now 1]] [%read ['R' now now 1]]])
  ;:  weld
    (expect-eq !>([(my ~[[%read ['R' now now 1]]]) ~['R']]) !>((grant-faults:fr ~ grant now needs)))
    (expect-eq !>([(my ~[[%read ['R' now now 2]]]) ~]) !>((grant-faults:fr kept grant now needs)))
  ==
--
