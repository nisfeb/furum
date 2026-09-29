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
::  the writer opens exactly the inbox to other ships, and asks for it
::  itself: the registry drops a grant from any other fiber (spike B). A
::  grant naming main.sig would let any ship write the boards
::
++  test-writer-grants-the-inbox
  =/  t  (start a-world:ft [~ %'main.sig'] ~)
  ;:  weld
    (expect-eq !>(%wait) !>(end.t))
    %+  expect-eq
      !>  ^-  (list *)
      :~  [%register [~ %'main.sig'] ~]
          [%how /public [~ (sy ~[(rf 0 / %'inbox.sig')]) ~]]
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
  =/  woke  (feed:ft a-world:ft t (wake /rise))
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
      (poke *from:fiber:nexus (op [%inbox ~nec [/foo %bar]]))
    ==
  =/  t  (answer-peek:ft a-world:ft t [%none ~])
  ;:  weld
    (expect-eq !>(%wait) !>(end.t))
    (expect-eq !>(~[(rf 0 /tr %inbox)]) !>((made t)))
  ==
::
::  the writer takes ops only from this nexus's own fibers. A ship's
::  poke and a malformed op are refused into /tr/last, never a crash,
::  and a good op from the inbox lands on its own ring
::
++  test-writer-refuses
  =/  t0  (start a-world:ft [~ %'main.sig'] ~)
  =/  t1  (feed:ft a-world:ft t0 (poke (from-ship ~nec) (op [%inbox ~bus [/ %x]])))
  =/  t2  (feed:ft a-world:ft t1 (poke *from:fiber:nexus (op 'garbage')))
  =/  t3  (feed:ft a-world:ft t2 (poke *from:fiber:nexus [[/ %json] !>(~)]))
  =/  t4  (feed:ft a-world:ft t3 (poke *from:fiber:nexus (op [%inbox ~nec [/foo %bar]])))
  =/  t4  (answer-peek:ft a-world:ft t4 [%none ~])
  ;:  weld
    (expect-eq !>(%wait) !>(end.t4))
    %+  expect-eq
      !>(~[(rf 0 /tr %last) (rf 0 /tr %last) (rf 0 /tr %last) (rf 0 /tr %inbox)])
      !>((made t4))
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
    %+  expect-eq  !>(`(list [road:tarball *])`~[[(rf 0 / %'main.sig') [%inbox ~nec [/foo %bar]]]])
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
  =/  t0  (start a-world:ft [~ %'main.sig'] ~)
  =/  bad  (feed:ft a-world:ft t0 (poke from [[/furum %ask] [%noun 'garbage']]))
  =/  answer
    |=  n=*
    (turn (pokes:ft (feed:ft a-world:ft t0 (poke from [[/furum %ask] [%noun n]])) [/furum %done]) tail)
  =/  mk
    %^  feed:ft  a-world:ft  t0
    %+  poke  from
    [[/furum %ask] !>([%act ~zod %create-board %b 'B' '' %poster])]
  ::  the board, then the rate limits, are read; neither exists yet
  =/  mk  (answer-peek:ft a-world:ft mk [%none ~])
  =/  mk  (answer-peek:ft a-world:ft mk [%none ~])
  ;:  weld
    %+  expect-eq  !>(`(list [road:tarball *])`~[[back `[400 'a malformed op']]])
      !>((pokes:ft bad [/furum %done]))
    ::  another ship's preferences are not the writer's to keep
    %+  expect-eq  !>(`(list *)`~[`[403 'only the owner keeps these preferences']])
      !>((answer [%act ~nec %toggle-dark-mode ~]))
    ::  a name no board may have is refused as a name, not looked up
    %+  expect-eq  !>(`(list *)`~[`[400 'board names may only use a-z, 0-9 and -']])
      !>((answer [%act ~zod %create-board 'Bad Name' 'x' '' %poster]))
    (expect-eq !>(~[(rv 0 /boards/b)]) !>((made mk)))
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
  =/  w  (start a-world:ft [~ %'main.sig'] ~)
  =.  w  (feed:ft a-world:ft w (poke *from:fiber:nexus [[/furum %op] !>([%prune ~])]))
  ::  the listing of /boards, then board b
  =.  w  (answer-peek:ft a-world:ft w [%ball *wave:nexus (as-ball (my ~[[/b/card ~]]))])
  =.  w  (answer-peek:ft a-world:ft w [%ball *wave:nexus (as-ball (grubs:fb brd))])
  ;:  weld
    %+  expect-eq  !>(`(list [road:tarball *])`~[[(rf 0 / %'main.sig') [%prune ~]]])
      !>((pokes:ft woke [/furum %op]))
    %+  expect-eq  !>(`(list *)`~[[/wait ~2026.1.1..06.00.00] [/wait ~2026.1.1..06.00.00]])
      !>((turn (pokes:ft woke [/ %timer-set]) |=([* n=*] n)))
    %+  expect-eq
      !>  ^-  (list [road:tarball *])
      ~[[(rf 0 /boards/b/content/posts %b0) [%1 (my ~[[1 `post-core`[1 ~nec 'new' ~ ~ ~2026.1.1]]])]]]
    !>((made-files w))
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
