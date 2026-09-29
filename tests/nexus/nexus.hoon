::  tests for the furum nexus: its fibers driven through +on-file the way
::  grubbery starts them (lib/fiber-test), and the pure rules they use
::
/+  *test, *furum-types, ft=fiber-test, tarball, nexus, fr=furum-rules, fb=furum-board
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
::  the writer risen: its grants and its sweep each list the boards first
++  writer  ^-(trail:ft (nones 2 (start a-world:ft [~ %'main.sig'] ~)))
::  only what a run did after `a`
++  new  |=([a=trail:ft b=trail:ft] ^-(trail:ft b(darts (slag (lent darts.a) darts.b))))
::  answer each read, by what it reads, while the fiber waits on one
::  (at most n)
++  serve
  |=  [n=@ud t=trail:ft f=$-(road:tarball view:nexus)]
  ^-  trail:ft
  ?:  =(0 n)  t
  ?.  ?=(%wait end.t)  t
  ?~  darts.t  t
  ?.  ?=([%node * * %peek *] (rear darts.t))  t
  $(n (dec n), t (answer-peek:ft a-world:ft t (f (rear (peeks:ft t)))))
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
::  the count and a timer is set for the retry. Its own wake brings the
::  writer back up; another timer's does not
::
++  test-crash-waits-then-rises
  =/  t  (start a-world:ft [~ %'main.sig'] `~[leaf+"boom"])
  =/  t  (answer-peek:ft a-world:ft t [%none ~])
  =/  wake  |=(w=wire (poke *from:fiber:nexus [[/ %timer-wake] !>(w)]))
  =/  other  (feed:ft a-world:ft t (wake /other))
  =/  woke  (nones 1 (feed:ft a-world:ft t (wake /rise)))
  ;:  weld
    (expect-eq !>(%wait) !>(end.t))
    (expect-eq !>(~[(rf 0 / %'rise.json')]) !>((made t)))
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
  ::  the rise's two board listings, then the inbox ring
  =/  t  (nones 3 t)
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
  =/  code
    |=  req=vase
    =/  t  (run:ft a-world:ft ((on-file:app [/requests %r1] *blot:tarball) ~) req)
    ::  the one read before answering: the owner's dark mode, or the board
    =?  t  ?=(%wait end.t)  (answer-peek:ft a-world:ft t [%none ~])
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
--
