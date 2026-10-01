::  tests for the furum nexus: its fibers driven through +on-file the way
::  grubbery starts them (lib/fiber-test), and the pure rules they use
::
/+  *test, *furum-types, ft=fiber-test, tarball, nexus, fr=furum-rules, fb=furum-board, ca=cashu, th=furum-theme
/=  app  /nex/furum/app
|%
++  now  ~2026.1.1
++  rf  |=([up=@ud p=path n=@ta] ^-(road:tarball [%| up [%& p n]]))
++  rv  |=([up=@ud p=path] ^-(road:tarball [%| up [%| p]]))
++  start
  |=  [w=world:ft =rail:tarball =prod:fiber:nexus]
  (run:ft w ((on-file:app rail *blot:tarball) prod) !>(~))
++  poke  |=([=from:fiber:nexus =sage:tarball] ^-(intake:ft [%poke from sage]))
++  from-ship  |=(s=@p ^-(from:fiber:nexus [0 /sys/ames/ships/(scot %p s) %x]))
++  op  |=(n=* ^-(sage:tarball [[/furum %op] [%noun n]]))
::  answer the next n reads with nothing
++  nones
  |=  [n=@ud t=trail:ft]
  ^-  trail:ft
  ?:  =(0 n)  t
  $(n (dec n), t (answer-peek:ft a-world:ft t [%none ~]))
::  the writer risen: its grants and its sweep each list the boards
::  first, then it reads its grant (none yet: it says nothing)
++  writer  ^-(trail:ft (nones 3 (start a-world:ft [~ %'main.sig'] ~)))
::  only what a run did after `a`
++  new  |=([a=trail:ft b=trail:ft] ^-(trail:ft b(darts (slag (lent darts.a) darts.b))))
::  answer each read, by what it reads, while the fiber waits on one
::  (at most n)
++  serve
  |=  [n=@ud t=trail:ft f=$-(road:tarball view:nexus)]
  (serve-in a-world:ft n t f)
::  the same in a world of the test's own, which then answers what the
::  fiber sends next (a refused road stays refused)
++  serve-in
  |=  [w=world:ft n=@ud t=trail:ft f=$-(road:tarball view:nexus)]
  ^-  trail:ft
  ?:  =(0 n)  t
  ?.  ?=(%wait end.t)  t
  ?~  darts.t  t
  ?.  ?=([%node * * %peek *] (rear darts.t))  t
  $(n (dec n), t (answer-peek:ft w t (f (rear (peeks:ft t)))))
++  file  |=(n=* ^-(view:nexus [%file *cass:clay [[/ %noun] %& !>(n)]]))
::  a host of a free board f and a paid board p: what each read finds
++  two-boards
  |=  r=road:tarball
  ^-  view:nexus
  ?:  =(r (rv 0 /boards))
    [%ball *wave:nexus (as-ball (my ~[[/f/pub/card ~] [/p/pub/card ~]]))]
  ?:  =(r (rf 0 /boards/f/pub %card))  (file [%2 *board-info ~])
  ?:  =(r (rf 0 /boards/p/pub %card))  (file [%2 *board-info `[100 ~d30 ~]])
  [%none ~]
::  every registry action a run sent
++  reg-acts  |=(t=trail:ft (turn (pokes:ft t [/usergroups %registry-action]) tail))
++  jailed  ^-(world:ft =/(w a-world:ft w(refuse ~[/sys])))
::  a road to a directory on another ship, ending in `last`
++  remote-to
  |=  [r=road:tarball last=@ta]
  ^-  ?
  ?.  ?=([%& %| ^] r)  |
  =/  p=path  p.p.r
  &(=((scag 3 p) /sys/ames/ships) =((rear p) last))
::  the faults a run kept at /tr/fault, by kind
++  fault-kinds
  |=  t=trail:ft
  ^-  (list @tas)
  %-  zing
  %+  murn  (made-files t)
  |=  [r=road:tarball n=*]
  ?.  ?=([%| @ %& [%tr ~] %fault] r)  ~
  `~(tap in ~(key by +:;;([%1 (map @tas fault:fr)] n)))
::  what a run wrote of the directory and its trace
++  dir-files
  |=  t=trail:ft
  %+  skim  (made-files t)
  |=  [r=road:tarball *]
  |(=(r (rf 0 / %directory)) =(r (rf 0 /tr %dir)))
++  made-files
  |=  t=trail:ft
  ^-  (list [road:tarball *])
  %+  murn  darts.t
  |=  d=dart:nexus
  ?.  ?=([%node * * %make * * %| *] d)  ~
  `[road.d q.bask.p.make.load.d]
++  as-ball
  |=  gs=(map path *)
  ^-  ball:tarball
  %+  roll  ~(tap by gs)
  |=  [[p=path v=*] b=ball:tarball]
  (~(put ba:tarball b) [(snip p) (rear p)] [[/ %noun] %& !>(v)])
++  made
  |=  t=trail:ft
  ^-  (list road:tarball)
  %+  murn  darts.t
  |=  d=dart:nexus
  ?.  ?=([%node * * %make *] d)  ~
  `road.d
::
::  the writer opens exactly the inbox to other ships' pokes, and asks
::  for it itself: the registry drops a grant from any other fiber (spike
::  B). A grant naming main.sig would let any ship write the boards
::
++  test-writer-grants-the-inbox
  =/  t  (nones 1 (start a-world:ft [~ %'main.sig'] ~))
  ;:  weld
    (expect-eq !>(%wait) !>(end.t))
    %+  expect-eq
      !>  ^-  (list *)
      :~  [%register [~ %'main.sig'] ~]
          [%how /public [~ (sy ~[(rf 0 / %'inbox.sig')]) (sy ~[(rf 0 / %registry)])]]
      ==
      !>((turn (pokes:ft t [/usergroups %registry-action]) |=([* n=*] n)))
  ==
::
::  crash rule 8: a weir that refuses the clock parks a crashed fiber
::  with nothing sent but the one clock read; a poke meanwhile is refused
::  with the note, and the restart that brings (no crash) parks again
::  without writing rise.json. Jailed, a clean start asks the registry
::  nothing and waits for pokes
::
++  test-refusing-weir-parks
  =/  crashed  (start jailed [~ %'main.sig'] `~[leaf+"boom"])
  =/  poked  (feed:ft jailed crashed (poke *from:fiber:nexus (op ~)))
  =/  again  (start jailed [~ %'main.sig'] `err.poked)
  =/  fresh  (start jailed [~ %'main.sig'] ~)
  ;:  weld
    (expect-eq !>([%wait 1]) !>([end.crashed (lent darts.crashed)]))
    %+  expect-eq  !>([%fail ~[leaf+"%furum writer: failed: waiting after a crash; the poke was refused"]])
      !>([end.poked err.poked])
    (expect-eq !>([%wait 1 ~]) !>([end.again (lent darts.again) (made again)]))
    (expect-eq !>(%wait) !>(end.fresh))
    (expect-eq !>(~) !>((pokes:ft fresh [/usergroups %registry-action])))
  ==
::
::  a crash waits a minute before the fiber tries again: rise.json gets
::  the count, a timer is set for the retry, and the crash is kept at
::  /tr/fault (said once). Its own wake brings the writer back up;
::  another timer's does not
::
++  test-crash-waits-then-rises
  =/  t  (start a-world:ft [~ %'main.sig'] `~[leaf+"boom"])
  ::  rise.json, then the faults
  =/  t  (nones 2 t)
  =/  wake  |=(w=wire (poke *from:fiber:nexus [[/ %timer-wake] !>(w)]))
  =/  other  (feed:ft a-world:ft t (wake /other))
  =/  woke  (nones 1 (feed:ft a-world:ft t (wake /rise)))
  ;:  weld
    (expect-eq !>(%wait) !>(end.t))
    (expect-eq !>(~[(rf 0 / %'rise.json') (rf 0 /tr %fault)]) !>((made t)))
    %+  expect-eq  !>(`(list [@tas @da @da @ud])`~[[%crash-writer now now 1]])
    !>  %-  zing
        %+  murn  (made-files t)
        |=  [r=road:tarball n=*]
        ?.  =(r (rf 0 /tr %fault))  ~
        =/  fs  ;;([%1 (map @tas fault:fr)] n)
        `(turn ~(tap by +.fs) |=([k=@tas f=fault:fr] [k at.f last.f n.f]))
    %+  expect-eq  !>(`(list *)`~[[/rise (add now ~m1)]])
      !>((turn (pokes:ft t [/ %timer-set]) |=([* n=*] n)))
    (expect-eq !>(~) !>((pokes:ft other [/usergroups %registry-action])))
    (expect-eq !>(2) !>((lent (pokes:ft woke [/usergroups %registry-action]))))
  ==
::
::  crash rule 9: after a reload an op queued before the start's kick is
::  held until the writer is up, then applied, not a crash
::
++  test-restart-under-writes
  =/  t
    %:  run-behind:ft  a-world:ft
      ((on-file:app [~ %'main.sig'] *blot:tarball) ~)
      !>(~)
      (poke *from:fiber:nexus (op [%from ~nec [/foo %bar] ~]))
    ==
  ::  the rise's two board listings, its grant, then the inbox ring
  =/  t  (nones 4 t)
  ;:  weld
    (expect-eq !>(%wait) !>(end.t))
    (expect-eq !>(~[(rf 0 / %sweep) (rf 0 /tr %inbox)]) !>((made t)))
  ==
::
::  the writer takes ops only from this nexus's own fibers. A ship's
::  poke and a malformed op are refused into /tr/last, never a crash,
::  and a good op from the inbox lands on its own ring
::
++  test-writer-refuses
  =/  t0  writer
  =/  t1  (feed:ft a-world:ft t0 (poke (from-ship ~nec) (op [%from ~bus [/ %x] ~])))
  =/  t2  (feed:ft a-world:ft t1 (poke *from:fiber:nexus (op 'garbage')))
  =/  t3  (feed:ft a-world:ft t2 (poke *from:fiber:nexus [[/ %json] !>(~)]))
  =/  t4  (feed:ft a-world:ft t3 (poke *from:fiber:nexus (op [%from ~nec [/foo %bar] ~])))
  =/  t4  (answer-peek:ft a-world:ft t4 [%none ~])
  ;:  weld
    (expect-eq !>(%wait) !>(end.t4))
    %+  expect-eq
      !>(~[(rf 0 /tr %last) (rf 0 /tr %last) (rf 0 /tr %last) (rf 0 /tr %inbox)])
      !>((made (new t0 t4)))
  ==
::
::  a change another ship asks for and our writer refuses is told back
::  to it, through the outbox, never from the writer itself
::
++  test-refusal-told-back
  =/  w  writer
  =.  w
    %^  feed:ft  a-world:ft  w
    %+  poke  *from:fiber:nexus
    [[/furum %op] !>([%from ~nec [/furum %msg] [%act %create-board %b 'B' '' %poster]])]
  ::  the inbox ring, the board, its members, the rate limits
  =.  w  (nones 4 w)
  =/  out
    %+  skim  (made-files w)
    |=([r=road:tarball *] ?=([%| @ %& [%outbox ~] @] r))
  %+  expect-eq
    !>(`(list *)`~[[~nec %note '~zod refused your change' 'only the host may create a board' `'/apps/furum/b/~zod/b' ~]])
  !>((turn out tail))
::
::  a note is kept only from a ship whose boards we read; a link no page
::  may follow is dropped from it; it pushes only when its kind is one
::  the owner picked
::
++  test-notes-from-followed
  =/  w  writer
  =/  note
    |=  [src=@p url=(unit @t) tags=(set term)]
    %+  feed:ft  a-world:ft
    :-  w
    %+  poke  *from:fiber:nexus
    [[/furum %op] !>([%from src [/furum %msg] [%note 'hi' 'there' url tags]])]
  =/  none  |=(t=trail:ft (answer-peek:ft a-world:ft t [%none ~]))
  =/  following  [%ball *wave:nexus (as-ball (my ~[[/b ~]]))]
  ::  the inbox ring, then whether we follow the sender
  =/  stranger  (none (none (note ~nec ~ ~)))
  ::  the ring, the follows, the notes so far, the prefs
  =/  known
    (none (none (answer-peek:ft a-world:ft (none (note ~bus `'javascript:alert(1)' ~)) following)))
  =/  wanted
    (none (none (answer-peek:ft a-world:ft (none (note ~bus ~ (sy ~[%comments]))) following)))
  =/  notes
    |=  t=trail:ft
    %+  murn  (made-files t)
    |=  [r=road:tarball n=*]
    ?.  =(r (rf 0 / %notes))  ~
    `(turn ;;((list notification) +.n) |=(x=notification url.x))
  ;:  weld
    (expect-eq !>(~) !>((notes stranger)))
    (expect-eq !>(`(list (list (unit @t)))`~[~[~]]) !>((notes known)))
    (expect-eq !>(~) !>((pokes:ft known [/ %push-action])))
    (expect-eq !>(1) !>((lent (pokes:ft wanted [/ %push-action]))))
  ==
::
::  a host's note about a board of its that we follow (it let us in)
::  wakes that board's follower; a note naming another ship's board, or
::  none, wakes nothing
::
++  test-note-wakes-follower
  =/  following  [%ball *wave:nexus (as-ball (my ~[[/b ~]]))]
  =/  run
    |=  [src=@p url=(unit @t)]
    =/  t
      %+  feed:ft  a-world:ft
      :-  writer
      %+  poke  *from:fiber:nexus
      [[/furum %op] !>([%from src [/furum %msg] [%note 'You can read a paid board' 'x' url (sy ~[%payments])]])]
    %^  serve  6  t
    |=(r=road:tarball ?:(=(r (rv 0 /follows/(scot %p src))) following [%none ~]))
  =/  woke
    |=  t=trail:ft
    ^-  (list road:tarball)
    %+  murn  (pokes:ft (new writer t) [/furum %op])
    |=([r=road:tarball *] ?.(?=([%| @ %& [%follows @ ~] @] r) ~ `r))
  ;:  weld
    (expect-eq !>(~[(rf 0 /follows/~bus %b)]) !>((woke (run ~bus `'/apps/furum/b/~bus/b'))))
    (expect-eq !>(~) !>((woke (run ~bus `'/apps/furum/b/~nec/b'))))
    (expect-eq !>(~) !>((woke (run ~bus ~))))
  ==
::
::  a board whose content our copy says is closed to us: its follower
::  doesn't ask for the content at the start, nor at its heartbeat,
::  since the host would refuse and both kernels print it; asked to look
::  again (a local poke), it does
::
++  test-closed-content
  =/  wake  |=(w=wire (poke *from:fiber:nexus [[/ %timer-wake] !>(w)]))
  =/  copy
    |=  r=road:tarball
    ^-  view:nexus
    ?:  =(r (rv 2 /cache/~nec/b))  [%ball *wave:nexus (as-ball (my ~[[/pub/card ~]]))]
    ?:  =(r (rf 2 /cache/~nec/b %access))  (file [%1 |])
    [%none ~]
  =/  asks  |=(t=trail:ft (lent (skim (peeks:ft t) |=(r=road:tarball (remote-to r %content)))))
  =/  up  (serve 3 (start a-world:ft [/follows/~nec %b] ~) copy)
  =/  up  (serve 4 (feed:ft a-world:ft up [%news /fp *wave:nexus]) copy)
  =/  beat  (serve 4 (feed:ft a-world:ft up (wake /hb)) copy)
  =/  told  (serve 4 (feed:ft a-world:ft beat (poke *from:fiber:nexus [[/furum %op] !>(~)])) copy)
  ;:  weld
    (expect-eq !>(0) !>((asks up)))
    (expect-eq !>(0) !>((asks beat)))
    (expect-eq !>(1) !>((asks told)))
  ==
::
::  a board we hold a copy of, out of reach: its follower keeps trying,
::  asking nothing more, until three hours of tries; then it asks the
::  host for pub/, and refused it lets the board go
::
++  test-follower-lets-go
  =/  wake  |=(w=wire (poke *from:fiber:nexus [[/ %timer-wake] !>(w)]))
  =/  held
    |=  r=road:tarball
    ^-  view:nexus
    ?:  =(r (rv 2 /cache/~nec/b))  [%ball *wave:nexus (as-ball (my ~[[/pub/card ~]]))]
    [%none ~]
  ::  one round: its reads, the keep's deadline, the wait before the next
  =/  round
    |=  t=trail:ft
    (feed:ft a-world:ft (feed:ft a-world:ft (serve 3 t held) (wake /fp/keep-deadline)) (wake /wait))
  =/  pubs  |=(t=trail:ft (lent (skim (peeks:ft t) |=(r=road:tarball (remote-to r %pub)))))
  =/  gone  |=(t=trail:ft (turn (pokes:ft t [/furum %op]) tail))
  =/  t  (start a-world:ft [/follows/~nec %b] ~)
  =/  t  (round (round (round (round (round (round (round (round t))))))))
  =/  t  (serve 3 t held)
  =/  let  (answer-peek:ft a-world:ft t [%veto ~])
  ;:  weld
    (expect-eq !>(1) !>((pubs t)))
    (expect-eq !>(`(list *)`~[[%gone ~nec %b]]) !>((gone let)))
  ==
::
::  the writer's start reads the shell's grant: a road furum can't do
::  without that isn't granted is kept as a fault (and said); a road only
::  needed in use isn't; a grant with everything clears what was kept;
::  before any approval (no grant.json) nothing happens
::
++  test-check-grant
  =/  grant
    |=  [poke=(list @t) peek=(list @t)]
    %-  pairs:enjs:format
    :~  ['poke' a+(turn poke |=(r=@t s+r))]
        ['peek' a+(turn peek |=(r=@t s+r))]
        ['make' a+~]
    ==
  =/  all  `(list @t)`~['/sys/bowl.sig' '/sys/eyre/' '/sys/behn/' '/sys/ames/registry' '/sys/ames/ships/' '/sys/iris/']
  =/  run
    |=  [g=(unit json) kept=(map @tas fault:fr)]
    %^  serve  4  (start a-world:ft [~ %'main.sig'] ~)
    |=  r=road:tarball
    ?:  =(r (rf 0 / %'grant.json'))  ?~(g [%none ~] [%file *cass:clay [[/ %json] %& !>(u.g)]])
    ?:  =(r (rf 0 /tr %fault))  (file [%1 kept])
    [%none ~]
  =/  stale  (my ~[[%timer ['x' now now 1]] [%groups ['y' now now 1]]])
  ;:  weld
    ::  no grant yet: nothing
    (expect-eq !>(~) !>((fault-kinds (run ~ ~))))
    ::  /sys/behn/ refused: that fault alone (/sys/ames/usergroups/ is
    ::  only needed once a board is paid)
    %+  expect-eq  !>(~[%timer])
      !>((fault-kinds (run `(grant (skip all |=(r=@t =(r '/sys/behn/'))) ~['/sys/ames/ships/']) ~)))
    ::  everything granted again: the kept timer fault goes; the group
    ::  fault stays until a grant names /sys/ames/usergroups/
    %+  expect-eq  !>(~[%groups])
      !>((fault-kinds (run `(grant all ~['/sys/ames/ships/']) stale)))
  ==
::
::  following another ship's board puts it in the feed and starts its
::  mirror; following our own only the feed; unfollowing only the feed
::
++  test-follow
  =/  w  writer
  =/  act
    |=  a=action
    %^  feed:ft  a-world:ft  w
    (poke *from:fiber:nexus [[/furum %op] !>([%act ~zod a])])
  =/  none  |=(t=trail:ft (answer-peek:ft a-world:ft t [%none ~]))
  ::  the feed, then whether we mirror it already
  =/  theirs  (none (none (act [%follow-board ~nec %b])))
  =/  ours  (none (act [%follow-board ~zod %b]))
  =/  gone  (none (act [%unfollow-board ~nec %b]))
  ;:  weld
    %+  expect-eq
      !>  ^-  (list [road:tarball *])
      :~  [(rf 0 / %feed) [%1 (sy ~[[~nec %b]])]]
          [(rf 0 /follows/~nec %b) [%1 ~]]
      ==
    !>((made-files (new w theirs)))
    (expect-eq !>(~[[(rf 0 / %feed) [%1 (sy ~[[~zod %b]])]]]) !>((made-files (new w ours))))
    ::  unfollowing what isn't followed changes nothing
    (expect-eq !>(~) !>((made-files (new w gone))))
  ==
::
::  the directory reader: a read of the registry that fails says why at
::  /tr/dir (no answer; our own weir refusing, a veto; the registry's
::  refusing, a %veto view) and is tried again in a minute, then two, not
::  an hour on; a read that works keeps the directory, clears the
::  reason, and waits the hour. It reads the default registry,
::  ~ricsul-bilwyt
::
++  test-directory-retries
  =/  wake  |=(w=wire (poke *from:fiber:nexus [[/ %timer-wake] !>(w)]))
  =/  none  |=(r=road:tarball ^-(view:nexus [%none ~]))
  =/  timers  |=(t=trail:ft (turn (pokes:ft t [/ %timer-set]) tail))
  ::  a start: its prefs, its directory's hosts, then the keep's deadline
  =/  begin
    |=  [w=world:ft t=trail:ft]
    (feed:ft w (serve-in w 5 t none) (wake /r/keep-deadline))
  =/  up  (begin a-world:ft (start a-world:ft [~ %'dir.sig'] ~))
  ::  the registry never answers; again, and it still doesn't
  =/  late  (serve 2 (feed:ft a-world:ft up (wake /timeout/reg)) none)
  =/  again  (begin a-world:ft (feed:ft a-world:ft late (wake /rh)))
  =/  later  (serve 2 (feed:ft a-world:ft again (wake /timeout/reg)) none)
  ::  the read is refused
  =/  shut  =/(w a-world:ft w(refuse ~[/sys/ames/ships]))
  =/  no  (serve-in shut 3 (begin shut (start shut [~ %'dir.sig'] ~)) none)
  ::  the registry refuses it
  =/  theirs  (serve 2 (answer-peek:ft a-world:ft up [%veto ~]) none)
  ::  it reads, after a failure was traced
  =/  was  [%1 `[~ricsul-bilwyt 'it did not answer in time' now]]
  =/  ok  (answer-peek:ft a-world:ft up (file [%1 *registry-store]))
  =/  ok  (serve 3 ok |=(r=road:tarball ?:(=(r (rf 0 /tr %dir)) (file was) [%none ~])))
  ;:  weld
    (expect-eq !>(`(list [road:tarball *])`~[[(rf 0 /tr %dir) was]]) !>((made-files late)))
    ::  no answer is kept for the page, and said nowhere
    (expect-eq !>(~) !>((fault-kinds late)))
    (expect-eq !>([/rh (add now ~m1)]) !>((rear (timers late))))
    (expect-eq !>([/rh (add now ~m2)]) !>((rear (timers later))))
    %+  expect-eq
      !>  ^-  (list [road:tarball *])  ~[[(rf 0 /tr %dir) [%1 `[~ricsul-bilwyt 'this ship does not let furum read other ships. On grubbery\'s permissions page, allow furum /sys/ames/ships/ under "may read"' now]]]]
    !>((dir-files no))
    (expect-eq !>(~) !>((fault-kinds no)))
    %+  expect-eq
      !>  ^-  (list [road:tarball *])  ~[[(rf 0 /tr %dir) [%1 `[~ricsul-bilwyt 'it refused to let this ship read it' now]]]]
    !>((dir-files theirs))
    (expect-eq !>(~) !>((fault-kinds theirs)))
    %+  expect-eq
      !>  ^-  (list [road:tarball *])  ~[[(rf 0 / %directory) [%1 *registry-store]] [(rf 0 /tr %dir) [%1 ~]]]
    !>((dir-files ok))
    (expect-eq !>([/rh (add now ~h1)]) !>((rear (timers ok))))
  ==
::
::  a follower of a board it has never read asks its host for the
::  board's pub/, which every hosted board opens to every ship. Refused
::  by the host (a %veto view), it has no such board: the follower tells
::  the writer and ends, sending no keep. Our own weir refusing, a host
::  that doesn't answer, or a board we hold a copy of: followed as before
::
++  test-follower-gives-up
  =/  shut  =/(w a-world:ft w(refuse ~[/sys/ames/ships]))
  =/  none  |=(r=road:tarball ^-(view:nexus [%none ~]))
  =/  keeps
    |=  t=trail:ft
    (lent (skim darts.t |=(d=dart:nexus ?=([%node * * %keep *] d))))
  =/  gone  |=(t=trail:ft (turn (pokes:ft t [/furum %op]) tail))
  =/  fresh  (answer-peek:ft a-world:ft (serve 3 (start a-world:ft [/follows/~nec %b] ~) none) [%veto ~])
  ::  our own weir refuses the read: nothing is known of the board
  =/  ours  (serve-in shut 4 (start shut [/follows/~nec %b] ~) none)
  ::  a copy of it here
  =/  held
    %-  serve-in
    :^  shut  3  (start shut [/follows/~nec %b] ~)
    |=  r=road:tarball
    ?.  =(r (rv 2 /cache/~nec/b))  [%none ~]
    [%ball *wave:nexus (as-ball (my ~[[/pub/card ~]]))]
  ::  its host is silent
  =/  quiet  (serve 3 (start a-world:ft [/follows/~nec %b] ~) none)
  =/  quiet  (feed:ft a-world:ft quiet (poke *from:fiber:nexus [[/ %timer-wake] !>(/timeout/nb)]))
  ;:  weld
    (expect-eq !>([%done `(list *)`~[[%gone ~nec %b]] 0]) !>([end.fresh (gone fresh) (keeps fresh)]))
    (expect-eq !>([`(list *)`~ 1]) !>([(gone ours) (keeps ours)]))
    ::  our own weir refusing is the grant check's to say, not this
    (expect-eq !>(~) !>((fault-kinds ours)))
    (expect-eq !>([`(list *)`~ 1]) !>([(gone held) (keeps held)]))
    (expect-eq !>([`(list *)`~ 1]) !>([(gone quiet) (keeps quiet)]))
  ==
::
::  the writer, told a board is gone: when, and no follower left
::
++  test-give-up
  =/  t  (feed:ft a-world:ft writer (poke *from:fiber:nexus (op [%gone ~nec %b])))
  =/  culls
    %+  murn  darts.t
    |=(d=dart:nexus ?.(?=([%node * * %cull *] d) ~ `road.d))
  ;:  weld
    (expect-eq !>(`(list [road:tarball *])`~[[(rf 0 /gone/~nec %b) [%1 now]]]) !>((made-files (new writer t))))
    (expect-eq !>(~[(rf 0 /follows/~nec %b)]) !>(culls))
  ==
::
::  a board its host said a moment ago it has no such board of: its page
::  says so, where it would load for ever; a minute on, it asks again
::
++  test-gone-board-page
  =/  w  =/(w a-world:ft w(refuse ~[/sys/scry]))
  =/  page
    |=  when=@da
    =/  t  (run:ft w ((on-file:app [/requests %r1] *blot:tarball) ~) (request:ft ~zod & %'GET' '/apps/furum/b/~nec/b' ''))
    =/  t
      %-  serve-in
      :^  w  6  t
      |=  r=road:tarball
      ?:(=(r (rf 1 /gone/~nec %b)) (file [%1 when]) [%none ~])
    (status:ft t)
  =/  [code=@ud body=@t]  (page now)
  ;:  weld
    (expect-eq !>(404) !>(code))
    (expect-eq !>(%.y) !>(?=(^ (find "~nec has no board named b" (trip body)))))
    (expect-eq !>(200) !>(code:(page (sub now ~m2))))
  ==
::
::  a ship that doesn't keep the registry refuses registry actions; one
::  that does keeps the entry
::
++  test-registry-writer
  =/  w  writer
  =/  reg
    %^  feed:ft  a-world:ft  w
    (poke *from:fiber:nexus [[/furum %ask] !>([%reg ~nec /apps/furum [%register %b 'B' '']])])
  =/  prefs
    |=  who=@p
    [%file *cass:clay [[/ %noun] %& !>([%2 | ~ who])]]
  ::  the prefs: the registry is elsewhere, or here
  =/  elsewhere  (answer-peek:ft a-world:ft reg (prefs ~nec))
  =/  here  (answer-peek:ft a-world:ft (answer-peek:ft a-world:ft reg (prefs ~zod)) [%none ~])
  ;:  weld
    %+  expect-eq  !>(`(list *)`~[`[404 'this ship keeps no directory']])
      !>((turn (pokes:ft elsewhere [/furum %done]) tail))
    %+  expect-eq
      !>  ^-  (list [road:tarball *])
      ~[[(rf 0 / %registry) [%1 (my ~[[%b [%b 'B' '' ~nec ~ |]]]) (my ~[[~nec /apps/furum]]) ~]]]
    !>((made-files (new w here)))
  ==
::
::  a member given access goes into the board's group, which the registry
::  then opens the board's content to: its content, nothing more
::
++  test-grant-writes-group
  =/  pay=payment-config  [100 ~d30 ~]
  =/  brd=board
    =|  b=board
    b(name.info %b, host.info ~zod, payment `pay)
  =/  file  |=(n=* [%file *cass:clay [[/ %noun] %& !>(n)]])
  =/  w0  writer
  =/  w
    %^  feed:ft  a-world:ft  w0
    (poke *from:fiber:nexus [[/furum %op] !>([%act ~zod %grant-paid %b ~nec ~2026.2.1])])
  ::  the board, its members, the rate limits
  =.  w  (answer-peek:ft a-world:ft w [%ball *wave:nexus (as-ball (grubs:fb brd))])
  =.  w  (nones 2 w)
  ::  the sweep: the boards, then b's card, roles and members
  =.  w  (answer-peek:ft a-world:ft w [%ball *wave:nexus (as-ball (my ~[[/b/pub/card ~]]))])
  =.  w  (answer-peek:ft a-world:ft w (file [%2 info.brd `pay]))
  =.  w  (nones 1 w)
  =.  w  (answer-peek:ft a-world:ft w (file [%1 (my ~[[~nec ~2026.2.1]])]))
  =/  grp=path  /sys/ames/usergroups/'furum-b.grp'
  =/  files  (made-files (new w0 w))
  ;:  weld
    %+  expect-eq  !>(`(list *)`~[[%1 (my ~[[~nec ~2026.2.1]])]])
      !>((murn files |=([r=road:tarball n=*] ?.(=(r (rf 0 /members %b)) ~ `n))))
    %+  expect-eq  !>(`(list *)`~[(sy ~[~nec])])
      !>((murn files |=([r=road:tarball n=*] ?.(=(r [%& %& grp %'who.ships']) ~ `n))))
    %+  expect-eq  !>(`(list *)`~[[%how /furum-b [~ ~ (sy ~[(rv 0 /boards/b/content)])]]])
      !>((turn (pokes:ft (new w0 w) [/usergroups %registry-action]) tail))
  ==
::
::  at a rise, every ship may read each board's pub/ and the free board's
::  content/, never the paid one's; the paid board alone gets a group
::
++  test-public-grant-set
  ::  each board's listing, then its card, roles and members, twice:
  ::  for the public grant, then for the sweep
  =/  t  (serve 30 (start a-world:ft [~ %'main.sig'] ~) two-boards)
  =/  groups
    %+  murn  (made-files t)
    |=  [r=road:tarball *]
    ?.  ?=([%& %& [%sys %ames %usergroups @ ~] %'who.ships'] r)  ~
    `i.t.t.t.path.p.p.r
  ;:  weld
    %+  expect-eq
      !>  %-  sy
          :~  (rf 0 / %registry)  (rv 0 /boards/f/pub)
              (rv 0 /boards/f/content)  (rv 0 /boards/p/pub)
          ==
    !>  =/  how  (skim (reg-acts t) |=(a=* ?=([%how [%public ~] *] a)))
        ?~  how  ~
        =/  a  ;;(registry-action:nexus i.how)
        ?>(?=(%how -.a) peek.weir.a)
    (expect-eq !>(~['furum-p.grp']) !>(groups))
  ==
::
::  a board made, or given a price, changes what every ship may read, so
::  the public grant is sent again; giving access doesn't
::
++  test-public-grant-resent
  =/  w0  writer
  =/  ask
    |=  [a=action f=$-(road:tarball view:nexus) n=@ud]
    %^  serve  n
      (feed:ft a-world:ft w0 (poke *from:fiber:nexus [[/furum %op] !>([%act ~zod a])]))
    f
  =/  public
    |=  t=trail:ft
    (lent (skim (reg-acts (new w0 t)) |=(a=* ?=([%how [%public ~] *] a))))
  ::  a free board b and nothing else, then b with a price
  =/  free
    |=  r=road:tarball
    ^-  view:nexus
    ?:  =(r (rv 0 /boards/b))
      =|  b=board
      [%ball *wave:nexus (as-ball (grubs:fb b(name.info %b, host.info ~zod)))]
    ?:  =(r (rv 0 /boards))  [%ball *wave:nexus (as-ball (my ~[[/b/pub/card ~]]))]
    ?:  =(r (rf 0 /boards/b/pub %card))  (file [%2 *board-info ~])
    [%none ~]
  ;:  weld
    (expect-eq !>(1) !>((public (ask [%create-board %b 'B' '' %poster] |=(* [%none ~]) 30))))
    (expect-eq !>(1) !>((public (ask [%set-payment %b `[100 ~d30 ~]] free 30))))
    (expect-eq !>(0) !>((public (ask [%grant-paid %b ~nec ~2026.2.1] free 30))))
  ==
::
::  the sweeper sleeps until the next member runs out, then asks the
::  writer to sweep; it never asks before
::
++  test-sweeper
  =/  t0  (start a-world:ft [~ %'sweep.sig'] ~)
  =/  due
    |=  at=(unit @da)
    %^  serve  1
      (feed:ft a-world:ft t0 [%news /s *wave:nexus])
    |=(* (file [%1 at]))
  =/  later  (due `(add now ~h1))
  =/  asks  |=(t=trail:ft (turn (pokes:ft t [/furum %ask]) tail))
  ;:  weld
    ::  a member runs out in an hour: a timer then, no ask yet
    %+  expect-eq  !>(`(list *)`~[[/sw (add now ~h1)]])
      !>((skim (turn (pokes:ft later [/ %timer-set]) tail) |=(a=* ?=([[%sw ~] *] a))))
    (expect-eq !>(~) !>((asks later)))
    ::  its wake, an hour and more on, or a member already out: the
    ::  writer is asked
    %+  expect-eq  !>(`(list *)`~[[%sweep ~]])
      =/  lw  =/(w a-world:ft w(now (add now ~h2)))
      =/  woken  (feed:ft lw later (poke *from:fiber:nexus [[/ %timer-wake] !>(/sw)]))
      !>((asks (answer-peek:ft lw woken (file [%1 `(add now ~h1)]))))
    (expect-eq !>(`(list *)`~[[%sweep ~]]) !>((asks (due `now))))
    ::  another timer's wake is not its time
    %+  expect-eq  !>(~)
      !>((asks (feed:ft a-world:ft later (poke *from:fiber:nexus [[/ %timer-wake] !>(/other)]))))
  ==
::
::  the inbox forwards another ship's poke with the sender the transport
::  names, and ignores a local one
::
++  test-inbox-forwards
  =/  t0  (start a-world:ft [~ %'inbox.sig'] ~)
  =/  t1  (feed:ft a-world:ft t0 (poke (from-ship ~nec) [[/foo %bar] !>(42)]))
  =/  t2  (feed:ft a-world:ft t1 (poke *from:fiber:nexus [[/foo %bar] !>(43)]))
  ;:  weld
    (expect-eq !>(%wait) !>(end.t2))
    %+  expect-eq  !>(`(list [road:tarball *])`~[[(rf 0 / %'main.sig') [%from ~nec [/foo %bar] 42]]])
      !>((pokes:ft t2 [/furum %op]))
  ==
::
::  the owner's pages are the owner's alone: a guest, or another ship
::  eyre authenticated, is refused; the about page is anyone's; a board
::  a guest can't see answers as one that isn't there; a form posted
::  from another site is refused
::
++  test-owner-gate
  ::  a ship whose weir refuses /sys/scry: no talon settings to read
  =/  w  =/(w a-world:ft w(refuse ~[/sys/scry]))
  =/  code
    |=  req=vase
    =/  t  (run:ft w ((on-file:app [/requests %r1] *blot:tarball) ~) req)
    ::  the reads before answering: the owner's theme, then for a guest's
    ::  board page the board
    =?  t  ?=(%wait end.t)  (answer-peek:ft w t [%none ~])
    =?  t  ?=(%wait end.t)  (answer-peek:ft w t [%none ~])
    code:(status:ft t)
  =/  ask  |=([src=@p auth=? meth=@tas url=@t] (code (request:ft src auth meth url '')))
  =/  xsite
    !>  :-  ~zod
    ^-  inbound-request:eyre
    :*  &  |  [%ipv4 .127.0.0.1]  %'POST'  '/apps/furum/create'
        ~[['sec-fetch-site' 'cross-site']]  ~
    ==
  ;:  weld
    (expect-eq !>(200) !>((ask ~zod & %'GET' '/apps/furum/guide')))
    (expect-eq !>(200) !>((ask ~zod & %'GET' '/apps/furum/guide/')))
    (expect-eq !>(403) !>((ask ~zod | %'GET' '/apps/furum/guide')))
    (expect-eq !>(403) !>((ask ~nec & %'GET' '/apps/furum/guide')))
    (expect-eq !>(200) !>((ask ~nec | %'GET' '/apps/furum/about')))
    (expect-eq !>(403) !>((ask ~nec | %'GET' '/apps/furum/b/~zod/b')))
    (expect-eq !>(404) !>((ask ~zod & %'GET' '/apps/furum/x')))
    (expect-eq !>(405) !>((ask ~zod & %'PUT' '/apps/furum/create')))
    (expect-eq !>(403) !>((code xsite)))
  ==
::
::  an ask is answered, to the fiber that asked, whether refused or
::  applied: a malformed op, another ship's preferences and a bad board
::  name at once, a new board once it is made
::
++  test-ask-answered
  =/  from  `from:fiber:nexus`[1 /requests %r1]
  =/  back  `road:tarball`[%| 1 %& /requests %r1]
  =/  t0  writer
  =/  bad  (feed:ft a-world:ft t0 (poke from [[/furum %ask] [%noun 'garbage']]))
  =/  answer
    |=  n=*
    (turn (pokes:ft (feed:ft a-world:ft t0 (poke from [[/furum %ask] [%noun n]])) [/furum %done]) tail)
  =/  mk
    %^  feed:ft  a-world:ft  t0
    %+  poke  from
    [[/furum %ask] !>([%act ~zod %create-board %b 'B' '' %poster])]
  ::  the board, its members, the rate limits; then the listings the
  ::  public grant and the sweep make of the boards
  =/  mk  (nones 5 mk)
  ;:  weld
    %+  expect-eq  !>(`(list [road:tarball *])`~[[back `[400 'a malformed op']]])
      !>((pokes:ft bad [/furum %done]))
    ::  another ship's preferences are not the writer's to keep
    %+  expect-eq  !>(`(list *)`~[`[403 'only the owner keeps these preferences']])
      !>((answer [%act ~nec %toggle-dark-mode ~]))
    ::  a name no board may have is refused as a name, not looked up
    %+  expect-eq  !>(`(list *)`~[`[400 'board names may only use a-z, 0-9 and -']])
      !>((answer [%act ~zod %create-board 'Bad Name' 'x' '' %poster]))
    (expect-eq !>(~[(rv 0 /boards/b)]) !>((scag 1 (made (new t0 mk)))))
    (expect-eq !>(`(list [road:tarball *])`~[[back ~]]) !>((pokes:ft mk [/furum %done])))
  ==
::
::  auto-prune: at its slot the tick pokes the writer, and the writer
::  deletes the posts past the board's age and under its score, and
::  rewrites only the bucket they were in
::
++  test-prune
  =/  tick  (start a-world:ft [~ %'prune.sig'] ~)
  =/  woke  (feed:ft a-world:ft tick (poke *from:fiber:nexus [[/ %timer-wake] !>(/wait)]))
  =/  brd=board
    =|  b=board
    %=  b
      name.info  %b
      prune      `[1 ~d7]
      posts
        %-  my
        :~  [0 [0 ~nec 'old' ~ ~ ~2025.1.1 ~ ~ 0]]
            [1 [1 ~nec 'new' ~ ~ ~2026.1.1 ~ ~ 0]]
        ==
    ==
  =/  w0  writer
  =/  w  (feed:ft a-world:ft w0 (poke *from:fiber:nexus [[/furum %op] !>([%prune ~])]))
  ::  the listing of /boards, then board b
  =.  w  (answer-peek:ft a-world:ft w [%ball *wave:nexus (as-ball (my ~[[/b/pub/card ~]]))])
  =.  w  (answer-peek:ft a-world:ft w [%ball *wave:nexus (as-ball (grubs:fb brd))])
  ;:  weld
    %+  expect-eq  !>(`(list [road:tarball *])`~[[(rf 0 / %'main.sig') [%prune ~]]])
      !>((pokes:ft woke [/furum %op]))
    %+  expect-eq  !>(`(list *)`~[[/wait ~2026.1.1..06.00.00] [/wait ~2026.1.1..06.00.00]])
      !>((turn (pokes:ft woke [/ %timer-set]) |=([* n=*] n)))
    %+  expect-eq
      !>  ^-  (list [road:tarball *])
      ~[[(rf 0 /boards/b/content/posts %b0) [%1 (my ~[[1 `post-core`[1 ~nec 'new' ~ ~ ~2026.1.1]]])]]]
    !>((made-files (new w0 w)))
  ==
::
::  a crash waits 1, 2, 4 minutes, up to an hour; two quiet hours start
::  the count over; a refused poke's restart keeps the wait it had
::
++  test-rise-plan
  =/  row
    |=  [n=@ud last=@da until=@da]
    ^-  json
    %-  pairs:enjs:format
    :~  ['n' (numb:enjs:format n)]
        ['last_ms' (numb:enjs:format (ms-of:fr last))]
        ['until_ms' (numb:enjs:format (ms-of:fr until))]
    ==
  ;:  weld
    (expect-eq !>([1 (add now ~m1)]) !>((rise-plan:fr ~ & now)))
    (expect-eq !>([2 (add now ~m2)]) !>((rise-plan:fr (row 1 (sub now ~m1) now) & now)))
    (expect-eq !>([3 (add now ~m4)]) !>((rise-plan:fr (row 2 (sub now ~m5) now) & now)))
    (expect-eq !>([7 (add now ~h1)]) !>((rise-plan:fr (row 6 (sub now ~h1) now) & now)))
    (expect-eq !>([12 (add now ~h1)]) !>((rise-plan:fr (row 11 (sub now ~h1) now) & now)))
    (expect-eq !>([1 (add now ~m1)]) !>((rise-plan:fr (row 9 (sub now (add ~h2 ~s1)) now) & now)))
    (expect-eq !>([10 (add now ~h1)]) !>((rise-plan:fr (row 9 (sub now ~h2) now) & now)))
    (expect-eq !>([4 (add now ~m7)]) !>((rise-plan:fr (row 4 now (add now ~m7)) | now)))
    %+  expect-eq  !>([3 (add now ~m4)])
      !>((rise-plan:fr (rise-row:fr [3 (add now ~m4)] now) | now))
  ==
::  ==  payments
::
::  answer the last cull a stopped run sent, as done
++  gone
  |=  t=trail:ft
  ^-  trail:ft
  =/  ws  (murn darts.t |=(d=dart:nexus ?.(?=([%node * * %cull *] d) ~ `wire.d)))
  ?~  ws  t
  (feed:ft a-world:ft t [%gone (rear ws) ~])
::
::  a test mint: one keyset, 00ab, every amount's key k*G
::
++  kk  7
++  j  |=(t=@t (need (de:json:html t)))
++  the-mint  'http://m'
++  keysets-json  (j '{"keysets":[{"id":"00ab","unit":"sat","active":true,"input_fee_ppk":100}]}')
++  keys-json
  ^-  json
  %-  pairs:enjs:format
  :~  :-  'keysets'
      :-  %a
      :_  ~
      %-  pairs:enjs:format
      :~  ['id' s+'00ab']
          ['unit' s+'sat']
          :-  'keys'
          %-  pairs:enjs:format
          %+  turn  (gulf 0 10)
          |=(i=@ [(crip (a-co:co (bex i))) s+(point-to-hex:ca (ec-mul:ca secp-g:ca kk))])
      ==
  ==
++  the-keys  (need (parse-keys:ca keys-json))
::  the mint's signature on an output, and the proof it makes
++  sig
  |=  o=out:ca
  ^-  json
  %-  pairs:enjs:format
  :~  ['amount' (numb:enjs:format amount.o)]
      ['id' s+id.o]
      ['C_' s+(point-to-hex:ca (ec-mul:ca (hex-to-point:ca b.o) kk))]
  ==
++  proof-of
  |=  o=out:ca
  ^-  cashu-proof
  [amount.o id.o secret.o (point-to-hex:ca (ec-mul:ca (hash-to-curve:ca secret.o) kk))]
::  the mint's answer, as iris hands it on
++  mint-says
  |=  [code=@ud body=json]
  ^-  intake:ft
  %+  poke  *from:fiber:nexus
  :-  [/ %http-response]
  !>  ^-  client-response:iris
  [%finished [code ~] `['application/json' (as-octs:mimes:html (en:json:html body))]]
::  what a payment asked the mint, in order: method and path
++  asked
  |=  t=trail:ft
  ^-  (list [@t @t])
  %+  turn  (pokes:ft t [/ %iris-request])
  |=  [* n=*]
  =/  r  ;;(request:http n)
  [method.r (rsh [3 (met 3 the-mint)] url.r)]
++  last-body
  |=  t=trail:ft
  ^-  json
  =/  r  ;;(request:http +:(rear (pokes:ft t [/ %iris-request])))
  (need (de:json:html q:(need body.r)))
++  pay-of  |=(t=trail:ft ^-(pay +:;;([%1 pay] q.state.t)))
++  a-pay  ^-(pay [~nec %b 'n1' the-mint 100 ~d30 %quote ~])
::  a payment's fiber, started with this step
++  pay-run
  |=  s=pay-step
  =/  p  a-pay
  (run:ft a-world:ft ((on-file:app [/pay %x] *blot:tarball) ~) !>([%1 p(step s)]))
++  two-proofs
  (j '[{"amount":64,"id":"00ab","secret":"s1","C":"02aa"},{"amount":64,"id":"00ab","secret":"s2","C":"02bb"}]')
::
::  ecash in hand: the mint's keysets and keys, then outputs for all of
::  it less the mint's fee (two proofs at 100 per thousand: 1), kept
::  before anything is sent; the mint's record of them asked first, then
::  the swap; its signatures made proofs, and the payment handed to the
::  writer
::
++  test-pay-swap
  =/  t0  (pay-run [%swap two-proofs])
  =/  t1  (feed:ft a-world:ft t0 (mint-says 200 keysets-json))
  =/  t2  (feed:ft a-world:ft t1 (mint-says 200 keys-json))
  =/  p2  (pay-of t2)
  ?>  ?=(%swapping -.step.p2)
  =/  outs  outs.step.p2
  =/  t3  (feed:ft a-world:ft t2 (mint-says 200 (j '{"outputs":[],"signatures":[],"promises":[]}')))
  =/  swap-body  (last-body t3)
  =/  t4  (feed:ft a-world:ft t3 (mint-says 200 (pairs:enjs:format ~[['signatures' [%a (turn outs sig)]]])))
  ;:  weld
    %+  expect-eq  !>(~[1 2 4 8 16 32 64])
      !>((sort (turn outs |=(o=out:ca amount.o)) lth))
    (expect-eq !>(the-keys) !>(keys.step.p2))
    %+  expect-eq
      !>(`(list [@t @t])`~[['GET' '/v1/keysets'] ['GET' '/v1/keys/00ab'] ['POST' '/v1/restore'] ['POST' '/v1/swap']])
      !>((asked t3))
    (expect-eq !>((build-swap-request:ca two-proofs (out-reqs:ca outs))) !>(swap-body))
    (expect-eq !>([%done (turn outs proof-of)]) !>(step:(pay-of t4)))
    %+  expect-eq  !>(`(list [road:tarball *])`~[[(rf 1 / %'main.sig') [%settle %x]]])
      !>((pokes:ft t4 [/furum %ask]))
  ==
::
::  answers come back by fiber, not by request: an earlier request's
::  answer (the keysets again, a restart's leftover) is let go while the
::  keys are awaited, and the keys' own is taken. A failure names no
::  request and is taken as it comes: no keys, so the step waits and
::  tries again
::
++  test-pay-stale-answer
  =/  t1  (feed:ft a-world:ft (pay-run [%swap two-proofs]) (mint-says 200 keysets-json))
  =/  stale  (feed:ft a-world:ft t1 (mint-says 200 keysets-json))
  =/  real  (feed:ft a-world:ft stale (mint-says 200 keys-json))
  =/  broke  (feed:ft a-world:ft t1 (mint-says 500 (j '{"detail":"oops"}')))
  ;:  weld
    (expect-eq !>([%wait 2]) !>([end.stale (lent (asked stale))]))
    (expect-eq !>(%swapping) !>(-.step:(pay-of real)))
    (expect-eq !>(%swap) !>(-.step:(pay-of broke)))
    (expect-eq !>(2) !>((lent (asked broke))))
    %+  expect-eq  !>(`(list *)`~[[/wait (add now ~s15)]])
      !>((skim (turn (pokes:ft broke [/ %timer-set]) tail) |=(a=* ?=([[%wait ~] *] a))))
  ==
::
::  a swap resumed after a restart asks the mint what it signed before it
::  swaps again: signed, those are the proofs, and no second swap goes
::
++  test-pay-resumes-by-restore
  =/  outs  (new-outs:ca ~[1 2 4] '00ab' 9)
  =/  t0  (pay-run [%swapping two-proofs the-keys outs])
  =/  answer
    %-  pairs:enjs:format
    :~  ['outputs' [%a (turn outs |=(o=out:ca (pairs:enjs:format ~[['B_' s+b.o] ['amount' (numb:enjs:format amount.o)] ['id' s+'00ab']])))]]
        ['signatures' [%a (turn outs sig)]]
    ==
  =/  t1  (feed:ft a-world:ft t0 (mint-says 200 answer))
  ;:  weld
    (expect-eq !>(`(list [@t @t])`~[['POST' '/v1/restore']]) !>((asked t1)))
    (expect-eq !>((build-restore-request:ca (out-reqs:ca outs))) !>((last-body t1)))
    (expect-eq !>([%done (turn outs proof-of)]) !>(step:(pay-of t1)))
  ==
::
::  a swap the mint refuses fails with the mint's reason, but only once
::  the mint says it signed none of our outputs
::
++  test-pay-refused
  =/  outs  (new-outs:ca ~[1 2 4] '00ab' 9)
  =/  none  (mint-says 200 (j '{"outputs":[],"signatures":[]}'))
  =/  t0  (pay-run [%swapping two-proofs the-keys outs])
  =/  t1  (feed:ft a-world:ft t0 none)
  =/  t2  (feed:ft a-world:ft t1 (mint-says 400 (j '{"detail":"Token already spent.","code":11001}')))
  =/  t3  (feed:ft a-world:ft t2 none)
  ;:  weld
    (expect-eq !>(%swapping) !>(-.step:(pay-of t2)))
    %+  expect-eq
      !>(`(list [@t @t])`~[['POST' '/v1/restore'] ['POST' '/v1/swap'] ['POST' '/v1/restore']])
      !>((asked t3))
    (expect-eq !>([%failed 'Token already spent.' ~]) !>(step:(pay-of t3)))
    (expect-eq !>(1) !>((lent (pokes:ft t3 [/furum %ask]))))
  ==
::
::  an invoice asked for: the mint's quote, the invoice sent to the payer
::  under its nonce, then the quote asked after until it is paid; paid,
::  our outputs for the price, kept before the mint is asked to sign them.
::  Another quote's answer is let go
::
++  test-pay-invoice
  =/  exp  (add now ~h1)
  =/  q  |=([id=@t st=@t] (pairs:enjs:format ~[['quote' s+id] ['request' s+'lnbc1'] ['state' s+st] ['expiry' (numb:enjs:format (unm:chrono:userlib exp))]]))
  =/  t0  (pay-run [%quote ~])
  =/  t1  (feed:ft a-world:ft t0 (mint-says 200 (q 'q1' 'UNPAID')))
  ::  where the payer keeps furum: the prefs, then the directory
  =/  t1  (nones 2 t1)
  =/  t2  (feed:ft a-world:ft t1 (mint-says 200 (q 'q0' 'PAID')))
  =/  t3  (feed:ft a-world:ft t2 (mint-says 200 (q 'q1' 'UNPAID')))
  =/  t4  (feed:ft a-world:ft t3 (poke *from:fiber:nexus [[/ %timer-wake] !>(/wait)]))
  =/  t5  (feed:ft a-world:ft t4 (mint-says 200 (q 'q1' 'PAID')))
  =/  t6  (feed:ft a-world:ft (feed:ft a-world:ft t5 (mint-says 200 keysets-json)) (mint-says 200 keys-json))
  =/  p6  (pay-of t6)
  ;:  weld
    (expect-eq !>([%invoice 'q1' 'lnbc1' (from-unix:chrono:userlib (unm:chrono:userlib exp))]) !>(step:(pay-of t1)))
    %+  expect-eq  !>(`(list *)`~[[%pay %b 'n1' %invoice 'lnbc1' 100 (from-unix:chrono:userlib (unm:chrono:userlib exp))]])
      !>((turn (pokes:ft t1 [/furum %msg]) tail))
    (expect-eq !>(2) !>((lent (asked t3))))
    (expect-eq !>(%invoice) !>(-.step:(pay-of t3)))
    ?>  ?=(%minting -.step.p6)
    (expect-eq !>(~[4 32 64]) !>((sort (turn outs.step.p6 |=(o=out:ca amount.o)) lth)))
  ==
::
::  a withdrawal: its proofs out of the wallet first; the mint says they
::  are unspent, so the melt goes, with our blank outputs; paid, its
::  change is ours. Refused, with its proofs still unspent, they come
::  back; pending, it is waited on
::
++  test-pay-melt
  =/  ps=(list cashu-proof)  ~[[64 '00ab' 's1' '02aa'] [64 '00ab' 's2' '02bb']]
  =/  outs  (new-outs:ca ~[1 1] '00ab' 9)
  =/  ys  (turn ps |=(c=cashu-proof (proof-y:ca secret.c)))
  =/  st  |=(v=@t (pairs:enjs:format ~[['states' [%a (turn ys |=(y=@t (pairs:enjs:format ~[['Y' s+y] ['state' s+v]])))]]]))
  =/  t0  (pay-run [%melting 'q9' ps the-keys outs])
  =/  spent  (feed:ft a-world:ft t0 (poke *from:fiber:nexus [[/furum %done] !>(`(unit deny)`~)]))
  =/  t2  (feed:ft a-world:ft spent (mint-says 200 (st 'UNSPENT')))
  =/  change  (pairs:enjs:format ~[['quote' s+'q9'] ['state' s+'PAID'] ['change' [%a ~[(sig (snag 0 outs))]]]])
  =/  paid  (feed:ft a-world:ft t2 (mint-says 200 change))
  =/  refused  (feed:ft a-world:ft (feed:ft a-world:ft t2 (mint-says 400 (j '{"detail":"no route"}'))) (mint-says 200 (st 'UNSPENT')))
  =/  pending  (feed:ft a-world:ft t2 (mint-says 200 (pairs:enjs:format ~[['quote' s+'q9'] ['state' s+'PENDING']])))
  ;:  weld
    %+  expect-eq  !>(`(list [road:tarball *])`~[[(rf 1 / %'main.sig') [%spend %x]]])
      !>((pokes:ft t0 [/furum %ask]))
    (expect-eq !>(~) !>((asked t0)))
    (expect-eq !>((build-checkstate-request:ca ys)) !>((last-body spent)))
    (expect-eq !>((build-melt-request:ca 'q9' ps (out-reqs:ca outs))) !>((last-body t2)))
    (expect-eq !>([%done ~[(proof-of (snag 0 outs))]]) !>(step:(pay-of paid)))
    (expect-eq !>([%failed 'no route' ps]) !>(step:(pay-of refused)))
    (expect-eq !>(%melting) !>(-.step:(pay-of pending)))
    %+  expect-eq  !>(`(list *)`~[[/wait (add now ~s10)]])
      !>((skim (turn (pokes:ft pending [/ %timer-set]) tail) |=(a=* ?=([[%wait ~] *] a))))
  ==
::
::  the writer takes a payment only for a paid board, from a mint it
::  trusts, worth the price, and at most three at a time from a ship; a
::  refusal is the payer's answer, under its nonce
::
++  test-start-pay
  =/  card  |=(m=(unit @t) (file [%2 *board-info `[100 ~d30 m]]))
  =/  three  (as-ball (my ~[[/a [%1 a-pay]] [/c [%1 a-pay]] [/d [%1 a-pay]]]))
  =/  reads
    |=  [c=view:nexus live=ball:tarball]
    |=  r=road:tarball
    ^-  view:nexus
    ?:  =(r (rf 0 /boards/b/pub %card))  c
    ?:  =(r (rv 0 /pay))  [%ball *wave:nexus live]
    [%none ~]
  =/  tok  |=(n=@ud (en:json:html (pairs:enjs:format ~[['inputs' (j (crip "[\{\"amount\":{(a-co:co n)},\"id\":\"00ab\",\"secret\":\"s\",\"C\":\"02\"}]"))]])))
  =/  pay-by
    |=  [a=action c=view:nexus live=ball:tarball]
    %^  serve  10
      %^  feed:ft  a-world:ft  writer
      (poke *from:fiber:nexus [[/furum %op] !>([%from ~nec [/furum %msg] [%act a]])])
    (reads c live)
  =/  answer
    |=  t=trail:ft
    %+  murn  (made-files t)
    |=  [r=road:tarball n=*]
    ?.  ?=([%| @ %& [%outbox ~] @] r)  ~
    `n
  =/  good  (pay-by [%submit-payment %b 'http://m/' (tok 128) 'n1'] (card `'http://m') *ball:tarball)
  =/  made-pay
    %+  murn  (made-files good)
    |=  [r=road:tarball n=*]
    ?.  ?=([%| @ %& [%pay ~] @] r)  ~
    `n
  =/  pays
    |=  t=trail:ft
    (murn (made-files t) |=([r=road:tarball *] ?.(?=([%| @ %& [%pay ~] @] r) ~ `r)))
  ;:  weld
    %+  expect-eq
      !>(`(list *)`~[[%1 [~nec %b 'n1' 'http://m' 100 ~d30 %swap (j (crip "[\{\"amount\":128,\"id\":\"00ab\",\"secret\":\"s\",\"C\":\"02\"}]"))]]])
      !>(made-pay)
    ::  named for the payer and its nonce, so an ask sent twice is one
    %+  expect-eq  !>(~[(rf 0 /pay (crip ((x-co:co 16) (end [3 8] (sham [~nec 'n1'])))))])
      !>(`(list road:tarball)`(pays good))
    ::  a token worth the price exactly will do
    %+  expect-eq  !>(1)
      !>((lent (pays (pay-by [%submit-payment %b 'http://m' (tok 100) 'n1'] (card `'http://m') *ball:tarball))))
    %+  expect-eq  !>(`(list *)`~[[~nec %pay %b 'n1' %failed 'the token is worth less than the price']])
      !>((answer (pay-by [%submit-payment %b 'http://m' (tok 99) 'n1'] (card `'http://m') *ball:tarball)))
    %+  expect-eq  !>(`(list *)`~[[~nec %pay %b 'n1' %failed 'this board takes no ecash from that mint']])
      !>((answer (pay-by [%submit-payment %b 'http://evil' (tok 128) 'n1'] (card `'http://m') *ball:tarball)))
    %+  expect-eq  !>(`(list *)`~[[~nec %pay %b 'n1' %failed 'this board is free']])
      !>((answer (pay-by [%submit-payment %b 'http://m' (tok 128) 'n1'] (file [%2 *board-info ~]) *ball:tarball)))
    %+  expect-eq  !>(`(list *)`~[[~nec %pay %b 'n1' %failed 'three payments are already under way; wait for one to finish']])
      !>((answer (pay-by [%submit-payment %b 'http://m' (tok 128) 'n1'] (card `'http://m') three)))
    %+  expect-eq  !>(`(list *)`~[[~nec %pay %b 'n2' %failed 'this board takes no Lightning: it names no mint']])
      !>((answer (pay-by [%request-lightning-invoice %b 'n2'] (card ~) *ball:tarball)))
    ::  a withdrawal is the host's
    %+  expect-eq  !>(`(list *)`~[[~nec %note '~zod refused your change' 'only the host withdraws' ~ ~]])
      !>((answer (pay-by [%melt-to-lightning %b 'http://m' 'lnbc1'] (card `'http://m') *ball:tarball)))
  ==
::
::  the host withdraws only from a mint its board's wallet holds proofs
::  from, and one withdrawal at a time
::
++  test-start-melt
  =/  melt
    |=  [mint=@t live=ball:tarball]
    =/  t
      %^  serve  10
        %^  feed:ft  a-world:ft  writer
        (poke *from:fiber:nexus [[/furum %ask] !>([%act ~zod %melt-to-lightning %b mint 'lnbc1'])])
      |=  r=road:tarball
      ^-  view:nexus
      ?:  =(r (rf 0 /boards/b/pub %card))  (file [%2 *board-info `[100 ~d30 `'http://m']])
      ?:  =(r (rf 0 /wallets %b))  (file [%1 (my ~[['http://m' ~[[64 '00ab' 's1' '02aa']]]])])
      ?:  =(r (rv 0 /pay))  [%ball *wave:nexus live]
      [%none ~]
    :-  (turn (pokes:ft t [/furum %done]) tail)
    (murn (made-files t) |=([r=road:tarball n=*] ?.(?=([%| @ %& [%pay ~] @] r) ~ `n)))
  =/  under-way  (as-ball (my ~[[/a [%1 =/(p a-pay p(who ~zod, step [%melt 'lnbc0']))]]]))
  ::  what doesn't count: another board's withdrawal, a payer's payment
  ::  for this board, our own that has finished
  =/  one  |=(q=pay (as-ball (my ~[[/a [%1 q]]])))
  =/  q  a-pay
  =/  others
    :~  (one q(who ~zod, name %c, step [%melt 'x']))
        (one q(who ~nec, step [%quote ~]))
        (one q(who ~zod, step [%done ~]))
    ==
  ;:  weld
    %+  expect-eq  !>(~[1 1 1])
      !>((turn others |=(l=ball:tarball (lent +:(melt 'http://m' l)))))
    %+  expect-eq  !>([`(list *)`~[~] `(list *)`~[[%1 [~zod %b '' 'http://m' 0 ~s0 %melt 'lnbc1']]]])
      !>((melt 'http://m/' *ball:tarball))
    %+  expect-eq  !>([`(list *)`~[`[400 'the wallet holds nothing from that mint']] `(list *)`~])
      !>((melt 'http://other' *ball:tarball))
    %+  expect-eq  !>([`(list *)`~[`[409 'a withdrawal from this board is under way']] `(list *)`~])
      !>((melt 'http://m' under-way))
  ==
::
::  a finished payment: its proofs into the board's wallet, kept with
::  every version; its grub culled; the payer's access from when its last
::  runs out, and word of it. A wallet that won't read is never written
::  over, and the payment waits
::
++  test-settle
  =/  got=(list cashu-proof)  ~[[64 '00ab' 's1' '02aa']]
  =/  brd=board
    =|  b=board
    b(name.info %b, host.info ~zod, payment `[100 ~d30 `'http://m'])
  =/  until  (add now ~d35)
  =/  reads
    |=  wallet=view:nexus
    |=  r=road:tarball
    ^-  view:nexus
    ?:  =(r (rf 0 /pay %x))  (file [%1 =/(p a-pay p(step [%done got]))])
    ?:  =(r (rf 0 /wallets %b))  wallet
    ?:  =(r (rf 0 /members %b))  (file [%1 (my ~[[~nec (add now ~d5)]])])
    ?:  =(r (rv 0 /boards/b))  [%ball *wave:nexus (as-ball (grubs:fb brd))]
    [%none ~]
  =/  settle
    |=  wallet=view:nexus
    =/  t
      %^  serve  40
        (feed:ft a-world:ft writer (poke *from:fiber:nexus [[/furum %op] !>([%settle %x])]))
      (reads wallet)
    (serve 40 (gone t) (reads wallet))
  =/  t  (settle [%none ~])
  =/  bad  (settle (file 'garbage'))
  =/  wallets
    %+  murn  darts.t
    |=  d=dart:nexus
    ?.  ?=([%node * * %make * * %| *] d)  ~
    ?.  =(road.d (rf 0 /wallets %b))  ~
    `[gain.load.d q.bask.p.make.load.d]
  =/  culls  |=(t=trail:ft (murn darts.t |=(d=dart:nexus ?.(?=([%node * * %cull *] d) ~ `road.d))))
  ;:  weld
    (expect-eq !>(`(list [? *])`~[[& [%1 (my ~[['http://m' got]])]]]) !>(wallets))
    (expect-eq !>(%.y) !>((lien (culls t) |=(r=road:tarball =(r (rf 0 /pay %x))))))
    %+  expect-eq  !>(`(list *)`~[[%1 (my ~[[~nec until]])]])
      !>((murn (made-files t) |=([r=road:tarball n=*] ?.(=(r (rf 0 /members %b)) ~ `n))))
    ::  the note that the payer may read the board, and the payment's answer
    %+  expect-eq
      !>  `(list *)`~[[~nec %note 'You can read a paid board' '~zod let you read b' `'/apps/furum/b/~zod/b' (sy ~[%payments])] [~nec %pay %b 'n1' %paid until]]
    !>((murn (made-files t) |=([r=road:tarball n=*] ?.(?=([%| @ %& [%outbox ~] @] r) ~ `n))))
    (expect-eq !>(%.n) !>((lien (culls bad) |=(r=road:tarball =(r (rf 0 /pay %x))))))
  ==
::
::  a host's word on a payment we made is kept under its nonce, and only
::  from the host we paid
::
++  test-take-pay
  =/  word
    |=  [src=@p name=@tas]
    %^  serve  4
      %^  feed:ft  a-world:ft  writer
      (poke *from:fiber:nexus [[/furum %op] !>([%from src [/furum %msg] [%pay name 'n1' %paid ~2026.2.1]])])
    |=  r=road:tarball
    ?:  =(r (rf 0 / %payments))  (file [%1 (my ~[['n1' [~bus %b now %asked |]]])])
    [%none ~]
  =/  kept
    |=  t=trail:ft
    (murn (made-files t) |=([r=road:tarball n=*] ?.(=(r (rf 0 / %payments)) ~ `n)))
  ;:  weld
    %+  expect-eq  !>(`(list *)`~[[%1 (my ~[['n1' [~bus %b now %paid ~2026.2.1]]])]])
      !>((kept (word ~bus %b)))
    (expect-eq !>(~) !>((kept (word ~nec %b))))
    (expect-eq !>(~) !>((kept (word ~bus %c))))
  ==
::
::  a withdrawal's proofs leave the board's wallet before it is sent,
::  and a wallet that won't read is never written over
::
++  test-spend
  =/  ps=(list cashu-proof)  ~[[64 '00ab' 's1' '02aa'] [64 '00ab' 's2' '02bb']]
  =/  other=cashu-proof  [8 '00ab' 's3' '02cc']
  =/  spend
    |=  wallet=view:nexus
    %^  serve  10
      (feed:ft a-world:ft writer (poke *from:fiber:nexus [[/furum %ask] !>([%spend %x])]))
    |=  r=road:tarball
    ^-  view:nexus
    ?:  =(r (rf 0 /pay %x))  (file [%1 =/(p a-pay p(who ~zod, step [%melting 'q' ps ~ ~]))])
    ?:  =(r (rf 0 /wallets %b))  wallet
    [%none ~]
  =/  t  (spend (file [%1 (my ~[['http://m' (snoc ps other)]])]))
  =/  bad  (spend (file 'garbage'))
  ;:  weld
    %+  expect-eq  !>(`(list *)`~[[%1 (my ~[['http://m' ~[other]]])]])
      !>((murn (made-files t) |=([r=road:tarball n=*] ?.(=(r (rf 0 /wallets %b)) ~ `n))))
    (expect-eq !>(`(list *)`~[~]) !>((turn (pokes:ft t [/furum %done]) tail)))
    (expect-eq !>(`(list *)`~[`[500 'unreadable: wallet']]) !>((turn (pokes:ft bad [/furum %done]) tail)))
    (expect-eq !>(~) !>((murn (made-files bad) |=([r=road:tarball n=*] ?.(=(r (rf 0 /wallets %b)) ~ `n)))))
  ==
::
::  a payment we make is kept under its nonce, asked for; those a week
::  old go
::
++  test-paying
  =/  old  (sub now ~d7)
  =/  t
    %^  serve  4
      (feed:ft a-world:ft writer (poke *from:fiber:nexus [[/furum %op] !>([%paying ~bus %b 'n3' &])]))
    |=  r=road:tarball
    ^-  view:nexus
    ?:  =(r (rf 0 / %payments))
      (file [%1 (my ~[['n1' [~bus %b old %asked |]] ['n2' [~bus %b `@da`+(old) %paid now]]])])
    [%none ~]
  %+  expect-eq
    !>(`(list *)`~[[%1 (my ~[['n2' [~bus %b `@da`+(old) %paid now]] ['n3' [~bus %b now %asked &]]])]])
  !>((murn (made-files t) |=([r=road:tarball n=*] ?.(=(r (rf 0 / %payments)) ~ `n))))
::
::  the edges of a payment: a token worth only the mint's fee fails, and
::  a signed answer counts only as a success whose every signature makes
::  a proof; a refusal, whatever its body, and a short answer are checked
::  with the mint again
::
++  test-pay-edges
  =/  one  (j '[{"amount":1,"id":"00ab","secret":"s1","C":"02aa"}]')
  =/  fee  (feed:ft a-world:ft (feed:ft a-world:ft (pay-run [%swap one]) (mint-says 200 keysets-json)) (mint-says 200 keys-json))
  =/  outs  (new-outs:ca ~[1 2] '00ab' 9)
  =/  none  (mint-says 200 (j '{"outputs":[],"signatures":[]}'))
  =/  t1  (feed:ft a-world:ft (pay-run [%swapping two-proofs the-keys outs]) none)
  ::  a refusal that carries signatures anyway
  =/  refused  (feed:ft a-world:ft t1 (mint-says 400 (pairs:enjs:format ~[['signatures' [%a (turn outs sig)]]])))
  ::  a signature on an amount the keyset has no key for
  =/  odd  (pairs:enjs:format ~[['amount' n+'3'] ['id' s+'00ab'] ['C_' s+'02aa']])
  =/  short  (feed:ft a-world:ft t1 (mint-says 200 (pairs:enjs:format ~[['signatures' [%a ~[(sig (snag 0 outs)) odd]]]])))
  ;:  weld
    (expect-eq !>([%failed 'the token is worth no more than the mint fee' ~]) !>(step:(pay-of fee)))
    (expect-eq !>(%swapping) !>(-.step:(pay-of refused)))
    (expect-eq !>(['POST' '/v1/restore']) !>((rear (asked refused))))
    (expect-eq !>(%swapping) !>(-.step:(pay-of short)))
    (expect-eq !>(['POST' '/v1/restore']) !>((rear (asked short))))
  ==
::
::  an invoice is waited on until its expiry, not past it; and a 300 is
::  no success, so it is taken as it comes rather than checked
::
++  test-pay-expiry
  =/  q  |=(st=@t (pairs:enjs:format ~[['quote' s+'q1'] ['request' s+'lnbc1'] ['state' s+st] ['expiry' ~]]))
  =/  run
    |=  e=@da
    =/  t  (nones 2 (pay-run [%invoice 'q1' 'lnbc1' e]))
    (feed:ft a-world:ft t (mint-says 200 (q 'UNPAID')))
  =/  moved  (feed:ft a-world:ft (feed:ft a-world:ft (pay-run [%swap two-proofs]) (mint-says 200 keysets-json)) (mint-says 300 keysets-json))
  ;:  weld
    (expect-eq !>(%invoice) !>(-.step:(pay-of (run now))))
    (expect-eq !>([%failed 'the invoice ran out unpaid' ~]) !>(step:(pay-of (run (sub now ~s1)))))
    ::  taken, and no keys in it: tried again later
    (expect-eq !>(%swap) !>(-.step:(pay-of moved)))
    %+  expect-eq  !>(`(list *)`~[[/wait (add now ~s15)]])
      !>((skim (turn (pokes:ft moved [/ %timer-set]) tail) |=(a=* ?=([[%wait ~] *] a))))
  ==
::
::  a melt the mint holds pending is asked after until it says: pending
::  again, it waits on; paid, its change is ours; unpaid with its proofs
::  unspent, they come back. A melt the mint doesn't answer about is never
::  given up on
::
++  test-melt-wait
  =/  ps=(list cashu-proof)  ~[[64 '00ab' 's1' '02aa'] [64 '00ab' 's2' '02bb']]
  =/  outs  (new-outs:ca ~[1 1] '00ab' 9)
  =/  ys  (turn ps |=(c=cashu-proof (proof-y:ca secret.c)))
  =/  st  |=(v=@t (pairs:enjs:format ~[['states' [%a (turn ys |=(y=@t (pairs:enjs:format ~[['Y' s+y] ['state' s+v]])))]]]))
  =/  melt  |=(v=@t (pairs:enjs:format ~[['quote' s+'q9'] ['state' s+v]]))
  =/  wake  (poke *from:fiber:nexus [[/ %timer-wake] !>(/wait)])
  =/  t0  (pay-run [%melting 'q9' ps the-keys outs])
  =/  spent  (feed:ft a-world:ft t0 (poke *from:fiber:nexus [[/furum %done] !>(`(unit deny)`~)]))
  =/  waiting  (feed:ft a-world:ft spent (mint-says 200 (st 'PENDING')))
  =/  again  (feed:ft a-world:ft (feed:ft a-world:ft waiting wake) (mint-says 200 (melt 'PENDING')))
  =/  paid  (feed:ft a-world:ft (feed:ft a-world:ft again wake) (mint-says 200 (melt 'PAID')))
  =/  unpaid  (feed:ft a-world:ft (feed:ft a-world:ft waiting wake) (mint-says 200 (melt 'UNPAID')))
  =/  back  (feed:ft a-world:ft unpaid (mint-says 200 (st 'UNSPENT')))
  =/  gone  (feed:ft a-world:ft unpaid (mint-says 200 (st 'SPENT')))
  =/  silent  (feed:ft a-world:ft spent (mint-says 500 (j '{"detail":"down"}')))
  ;:  weld
    (expect-eq !>(['GET' '/v1/melt/quote/bolt11/q9']) !>((rear (asked again))))
    (expect-eq !>(%melting) !>(-.step:(pay-of again)))
    ::  paid with no change in its answer: the change is restored
    (expect-eq !>(['POST' '/v1/restore']) !>((rear (asked paid))))
    (expect-eq !>([%failed 'the Lightning payment failed' ps]) !>(step:(pay-of back)))
    (expect-eq !>(['POST' '/v1/restore']) !>((rear (asked gone))))
    (expect-eq !>(%melting) !>(-.step:(pay-of silent)))
    %+  expect-eq  !>(`(list *)`~[[/wait (add now ~s15)]])
      !>((skim (turn (pokes:ft silent [/ %timer-set]) tail) |=(a=* ?=([[%wait ~] *] a))))
  ==
::
::  a finished payment is handed to the writer; refused while the writer
::  waits after a crash, it is handed over again in a minute, and in ten
::  when the writer kept it
::
++  test-pay-settle
  =/  busy  =/(w a-world:ft w(nack ~[[/furum %ask]]))
  =/  refused  (run:ft busy ((on-file:app [/pay %x] *blot:tarball) ~) !>([%1 =/(p a-pay p(step [%done ~]))]))
  =/  kept
    %^  feed:ft  a-world:ft  (pay-run [%done ~])
    (poke *from:fiber:nexus [[/furum %done] !>(`(unit deny)`[~ 500 'unreadable: wallet; the payment waits'])])
  =/  timers
    |=  t=trail:ft
    (skim (turn (pokes:ft t [/ %timer-set]) tail) |=(a=* ?=([[%wait ~] *] a)))
  ;:  weld
    (expect-eq !>(`(list *)`~[[/wait (add now ~m1)]]) !>((timers refused)))
    (expect-eq !>(`(list *)`~[[/wait (add now ~m10)]]) !>((timers kept)))
  ==
::  ==  theme
::
::  talon's `themes` entry in %settings, as talon writes it
++  dusk-json
  '{"themes":[{"id":"a1","name":"Dusk","dark":true,"primary":"#FBBF24","secondary":"#A5B4FC","tertiary":"#34D399","background":"#0F0D1A","surface":"#1A1625"}],"activeId":"a1"}'
++  scry-says  |=(n=* ^-(intake:ft (poke *from:fiber:nexus [[/ %noun] !>(n)])))
++  guide-run
  (run:ft a-world:ft ((on-file:app [/requests %r1] *blot:tarball) ~) (request:ft ~zod & %'GET' '/apps/furum/guide' ''))
::
::  by default a page follows the theme picked in talon: %settings runs,
::  talon has saved themes there and uses one, and the page draws with
::  it; with no accent there, none. Each scry asks first whether the
::  agent runs and the entry exists: a scry of what isn't there would
::  fail the whole event
::
++  test-look-follows-talon
  =/  t  (answer-peek:ft a-world:ft guide-run [%none ~])
  =/  t  (feed:ft a-world:ft t (scry-says &))
  =/  t  (feed:ft a-world:ft t (scry-says &))
  =/  t  (feed:ft a-world:ft t (scry-says [%entry %s dusk-json]))
  =/  t  (feed:ft a-world:ft t (scry-says |))
  =/  asked  (turn (pokes:ft t [/ %scry-request]) tail)
  =/  [code=@ud body=@t]  (status:ft t)
  ;:  weld
    %+  expect-eq
      !>  ^-  (list *)
      :~  [%noun ~[%gu %settings %$]]
          [%noun /gx/settings/'has-entry'/talon/'ui-prefs'/themes/noun]
          [%noun /gx/settings/entry/talon/'ui-prefs'/themes/noun]
          [%noun /gx/settings/'has-entry'/talon/'ui-prefs'/accent/noun]
      ==
    !>(asked)
    (expect-eq !>(200) !>(code))
    (expect-eq !>(%.y) !>(?=(^ (find "--primary:#fbbf24;" (trip body)))))
    (expect-eq !>(%.y) !>(?=(^ (find "color-scheme:dark;" (trip body)))))
  ==
::
::  turned off, a page asks %settings nothing and draws with furum's own:
::  here the built-in theme, light; and with no %settings running, the
::  same
::
++  test-look-talon-off
  =/  off  [%3 [[%light | [~ ~] [~ %profile ~]] (sy ~[%comments]) ~zod]]
  =/  t  (answer-peek:ft a-world:ft guide-run (file off))
  =/  gone  (feed:ft a-world:ft (answer-peek:ft a-world:ft guide-run [%none ~]) (scry-says |))
  =/  has  |=([t=trail:ft x=tape] ?=(^ (find x (trip body:(status:ft t)))))
  ;:  weld
    (expect-eq !>(~) !>((pokes:ft t [/ %scry-request])))
    (expect-eq !>(%.y) !>((has t "--bg:#f0eee8;")))
    (expect-eq !>(%.n) !>((has t "prefers-color-scheme")))
    (expect-eq !>(1) !>((lent (pokes:ft gone [/ %scry-request]))))
    (expect-eq !>(%.y) !>((has gone "@media (prefers-color-scheme: dark)")))
  ==
::
::  prefs furum kept at %3, before a theme had +more, still read: an own
::  theme of five colours draws, and the tags and registry stand
::
++  test-prefs-3
  =/  dusk  ['a1' 'Dusk' & '#FBBF24' '#A5B4FC' '#34D399' '#0F0D1A' '#1A1625']
  =/  was  [%3 [[%light | [~[dusk] `'a1'] [~ %profile ~]] (sy ~[%comments]) ~zod]]
  =/  t  (answer-peek:ft a-world:ft guide-run (file was))
  =/  body  (trip body:(status:ft t))
  ;:  weld
    (expect-eq !>(%.y) !>(?=(^ (find "--primary:#fbbf24;" body))))
    (expect-eq !>(%.y) !>(?=(^ (find "color-scheme:dark;" body))))
  ==
::
::  the writer keeps theme settings only when they are sane: every theme
::  named with five colours that read, at most fifty, an accent that is
::  a colour
::
++  test-set-looks
  =/  from  `from:fiber:nexus`[1 /requests %r1]
  =/  dusk=theme:th  ['a1' 'Dusk' & '#FBBF24' '#A5B4FC' '#34D399' '#0F0D1A' '#1A1625' *more:th]
  =/  set
    |=  l=*
    =/  t
      %^  serve  4
        (feed:ft a-world:ft writer (poke from [[/furum %ask] !>([%look l])]))
      |=(* [%none ~])
    :-  (turn (pokes:ft t [/furum %done]) tail)
    (murn (made-files t) |=([r=road:tarball n=*] ?.(=(r (rf 0 / %prefs)) ~ `n)))
  =/  good  [%dark & [~[dusk] `'a1'] [`& %custom `'#101541']]
  ;:  weld
    %+  expect-eq
      !>([`(list *)`~[~] `(list *)`~[[%4 good (sy ~[%comments %new-posts %payments]) ~ricsul-bilwyt]]])
      !>((set good))
    %+  expect-eq  !>(`(list *)`~[`[400 'a theme needs a name and five colours']])
      !>(-:(set [%dark & [~[dusk(primary 'red')] ~] [~ %profile ~]]))
    %+  expect-eq  !>(`(list *)`~[`[400 'a theme needs a name and five colours']])
      !>(-:(set [%dark & [~[dusk(name '')] ~] [~ %profile ~]]))
    %+  expect-eq  !>(`(list *)`~[`[400 'at most fifty themes']])
      !>(-:(set [%dark & [(reap 51 dusk) ~] [~ %profile ~]]))
    (expect-eq !>(`(list *)`~[~]) !>(-:(set [%dark & [(reap 50 dusk) ~] [~ %profile ~]])))
    %+  expect-eq  !>(`(list *)`~[`[400 'a theme needs a name and five colours']])
      !>(-:(set [%dark & [~[dusk(id '')] ~] [~ %profile ~]]))
    %+  expect-eq  !>(`(list *)`~[`[400 'that is not a colour']])
      !>(-:(set [%dark & [~ ~] [`& %custom `'blue']]))
  ==
::
::  talon's accent alone (no saved themes) still rules: a custom colour
::  repaints the page, and %contacts is not asked
::
++  test-look-talon-accent
  =/  t  (answer-peek:ft a-world:ft guide-run [%none ~])
  =/  t  (feed:ft a-world:ft t (scry-says &))
  =/  t  (feed:ft a-world:ft t (scry-says |))
  =/  t  (feed:ft a-world:ft t (scry-says &))
  =/  t  (feed:ft a-world:ft t (scry-says [%entry %s '{"enabled":true,"mode":"Custom","customHex":"#101541"}']))
  =/  body  (trip body:(status:ft t))
  ;:  weld
    (expect-eq !>(4) !>((lent (pokes:ft t [/ %scry-request]))))
    (expect-eq !>(%.y) !>(?=(^ (find "--primary:#101541;" body))))
  ==
::
::  an accent set to the profile colour takes it from %contacts, asking
::  first whether %contacts runs; not running, there is none
::
++  test-look-profile-accent
  =/  t  (answer-peek:ft a-world:ft guide-run [%none ~])
  =/  t  (feed:ft a-world:ft t (scry-says &))
  =/  t  (feed:ft a-world:ft t (scry-says |))
  =/  t  (feed:ft a-world:ft t (scry-says &))
  =/  t  (feed:ft a-world:ft t (scry-says [%entry %s '{"enabled":true,"mode":"Profile"}']))
  =/  none  (feed:ft a-world:ft t (scry-says |))
  =/  t  (feed:ft a-world:ft t (scry-says &))
  =/  self  (need (de:json:html '{"color":{"type":"tint","value":"0xff.5050"}}'))
  =/  t  (feed:ft a-world:ft t (poke *from:fiber:nexus [[/ %json] !>(self)]))
  ;:  weld
    %+  expect-eq  !>(~[[%json /gx/contacts/v1/self/json]])
      !>((slag 5 (turn (pokes:ft t [/ %scry-request]) tail)))
    (expect-eq !>(%.y) !>(?=(^ (find "--primary:#ff5050;" (trip body:(status:ft t))))))
    (expect-eq !>(%.y) !>(?=(^ (find "--primary:#cc2020;" (trip body:(status:ft none))))))
  ==
--
