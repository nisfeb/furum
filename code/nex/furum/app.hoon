::  furum: decentralized forums, as a grubbery nexus. The plan, and the
::  reasons for its shape, are in docs/grubbery-migration.md.
::
::  The tree this nexus owns (every persistent path has a row in +on-load):
::    /main.sig         the writer: every mutation goes through it
::    /inbox.sig        the one road another ship may poke (+grant-public)
::    /web.sig          binds /apps/furum; one fiber per request
::    /requests/<id>    the ephemeral request fibers
::    /tr/last          the writer's last outcome
::    /tr/inbox         what other ships poked, newest first, the last 100
::    /rise.json        per fiber, its crashes in a row and its next try
::    tile, link, weir and icon: laid fresh on every load
::
::  ROADS ARE NEXUS-RELATIVE. A desk-installed app cannot learn its own
::  absolute path, so every road is [%| up lane], where up is the number
::  of steps from the calling fiber to the nexus root: 0 for the fibers
::  at the root, 1 for a request fiber at /requests/<id>.
::
::  THE WRITER MUST NOT CRASH. Every refusal is a branch that returns
::  cleanly and writes /tr/last.
::
/<  fr  /lib/furum-rules.hoon
=<  ^-  nexus:nexus
    |%
    ++  on-load
      |=  =ball:tarball
      ^-  bole:tarball
      =/  tile=json
        %-  pairs:enjs:format
        :~  title+s+'Furum'
            info+s+'Decentralized forums for Urbit'
            color+s+'#cc2020'
            image+s+'/grubbery/tiles/icon/furum'
            href+s+'/apps/furum'
        ==
      =/  link=json
        (pairs:enjs:format ~[['name' s+'furum'] ['description' s+'Decentralized forums']])
      %+  spin:loader  ball
      :~  (manifest:loader 0)
          [%over %& [/ %'tile.json'] [[/ %json] tile]]
          [%over %& [/ %'link.json'] [[/ %json] link]]
          [%over %& [/ %'weir.json'] [[/ %json] weir-json]]
          [%over %& [/ %'icon.svg'] [[/ %mime] [~[%image 'svg+xml'] (as-octs:mimes:html icon-svg)]]]
          [%fall %& [/ %'main.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'inbox.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'web.sig'] [[/ %sig] ~]]
          [%fall %| /requests empty-dir:loader]
          [%fall %| /tr empty-dir:loader]
          [%fall %& [/tr %last] [[/ %json] [%o ~]]]
          [%fall %& [/tr %inbox] [[/ %json] [%a ~]]]
          [%fall %& [/ %'rise.json'] [[/ %json] [%o ~]]]
      ==
    ::
    ++  on-file
      |=  [=rail:tarball =blot:tarball]
      ^-  spool:fiber:nexus
      |=  =prod:fiber:nexus
      =/  m  (fiber:fiber:nexus ,~)
      ^-  process:fiber:nexus
      ?+    rail  stay:m
          ::  the writer. It opens the inbox to other ships at every rise:
          ::  the registry takes a grant only from the fiber it registered,
          ::  and drops it when that fiber dies (phase 0, spike B)
          [~ %'main.sig']
        ;<  ~  bind:m  (rise-later prod "%furum writer: failed")
        ;<  ~  bind:m  grant-public
        |-
        ;<  [=from:fiber:nexus =sage:tarball]  bind:m  take-poke-from:io
        ;<  ~  bind:m  (apply from sage)
        $
          ::  the inbox: the sender is the transport's, never the
          ::  payload's. A local poke is ignored. What the writer refuses
          ::  (it is waiting after a crash) is dropped, not retried
          [~ %'inbox.sig']
        ;<  ~  bind:m  (rise-later prod "%furum inbox: failed")
        |-
        ;<  [=from:fiber:nexus =sage:tarball]  bind:m  take-poke-from:io
        =/  src=(unit @p)  (get-poke-src:io from)
        ;<  *  bind:m
          ?~  src  (pure:(fiber:fiber:nexus ,(unit tang)) ~)
          (poke-soft:io (rf 0 / %'main.sig') [[/furum %op] `op`[%inbox u.src p.sage]])
        $
          ::  the HTTP binder. bind-http-self is veto-tolerant: jailed,
          ::  it logs and waits; the approval reload binds for real
          [~ %'web.sig']
        ;<  ~  bind:m  (rise-later prod "%furum web: failed")
        ;<  ~  bind:m  (bind-http-self:io [~ /apps/furum])
        (http-dispatch:io %furum)
          ::  one ephemeral fiber per request. One that crashed ends:
          ::  nothing would poke it awake. The kick first, or a late
          ::  answer queued before it crashes the first step at a reload
          [[%requests ~] @]
        ;<  ~  bind:m  take-kick
        ?^  prod  ((slog leaf+"%furum request: failed" u.prod) (pure:m ~))
        (handle-request name.rail)
      ==
    --
|%
::  ==  roads
::
++  rf  |=([up=@ud p=path n=@ta] ^-(road:tarball [%| up [%& p n]]))
++  srv  ~(. http-res:io [%| 1 %& ~ %'web.sig'])
::  the tile's icon, which the shell serves from our root. A cord, not a
::  file: the builder imports only [/ %mime] grubs, and a checkout by
::  extension makes an .svg an [/ %svg] one
::
++  icon-svg
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><rect width="32" height="32" rx="6" fill="#cc2020"/><text x="16" y="24" font-family="serif" font-size="26" font-weight="bold" fill="#fff" text-anchor="middle">&#x03DC;</text></svg>'
::  +op: what the writer takes, as a noun under [/furum %op], clammed
::  under mule so a malformed one is refused, never a crash
::
+$  op
  $%  [%inbox src=@p mark=blot:tarball]
  ==
::  ==  the ask
::
::  +weir-json: every system road the nexus reaches, and what refusing it
::  costs. scripts/weir-check.py holds this to the code.
::
++  weir-json
  ^-  json
  =/  line  |=([r=@t w=@t] `json`(pairs:enjs:format ~[['road' s+r] ['why' s+w]]))
  %-  pairs:enjs:format
  :~  :-  'poke'
      :-  %a
      :~  (line '/sys/bowl.sig' 'read the time, our ship and entropy; nothing works without it')
          (line '/sys/eyre/' 'serve furum at /apps/furum')
          (line '/sys/behn/' 'after a crash, wait a while and try again. Refuse this and a part that crashed stays down until a poke wakes it')
          (line '/sys/ames/registry' 'let other ships reach your inbox, to post, comment and vote on your boards. Refuse this and nobody else can use your boards')
      ==
  ==
::  +grant-public: open the inbox to every ship. Sent by the writer
::  itself: the registry keys a grant to the rail that registered, and
::  drops a %how from any other fiber without a word. Jailed (no clock
::  yet) it waits for the approval reload; a refused road is traced, and
::  the boards stay local.
::
++  grant-public
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  clock=(unit @da)  bind:m  soft-now
  ?~  clock  (pure:m ~)
  ;<  reg=(unit tang)  bind:m  (reg-register-at-soft:io [/ %'main.sig'])
  ?^  reg  (trace:io [leaf+"%furum: no registry road; other ships cannot reach the inbox" u.reg])
  ;<  how=(unit tang)  bind:m
    (reg-how-soft:io /public [~ (sy ~[(rf 0 / %'inbox.sig')]) ~])
  ?~  how  (pure:m ~)
  (trace:io [leaf+"%furum: the registry refused the public grant" u.how])
::  ==  the writer
::
::  +apply: one op from a poke. Only this nexus's own fibers may write.
::
++  apply
  |=  [=from:fiber:nexus =sage:tarball]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?^  (get-poke-src:io from)  (refuse 'poke' 'a ship may not write here')
  ?.  =([/furum %op] p.sage)  (refuse 'poke' 'not an op')
  =/  o=(unit op)  (mole |.(;;(op q.q.sage)))
  ?~  o  (refuse 'poke' 'a malformed op')
  ?-  -.u.o
    %inbox  (trace-inbox src.u.o mark.u.o)
  ==
::  +refuse: a refused op, as the writer's last outcome at /tr/last
::
++  refuse
  |=  [what=@t why=@t]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  %+  over:io  (rf 0 /tr %last)
  :-  [/ %json]
  %-  pairs:enjs:format
  :~  ['at' s+(scot %da now)]
      ['op' s+what]
      ['why' s+why]
  ==
::  +trace-inbox: a poke from another ship, on its own ring, so strangers
::  cannot flush the owner's /tr/last
::
++  trace-inbox
  |=  [src=@p mark=blot:tarball]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  ;<  old=json  bind:m  (read-json (rf 0 /tr %inbox))
  =/  row=json
    %-  pairs:enjs:format
    :~  ['at' s+(scot %da now)]
        ['src' s+(scot %p src)]
        ['mark' s+(spat (snoc path.mark name.mark))]
    ==
  (over:io (rf 0 /tr %inbox) [[/ %json] [%a (scag 100 `(list json)`[row ?:(?=([%a *] old) p.old ~)])]])
::  +read-json: a grub as json, ~ when absent or unreadable
::
++  read-json
  |=  =road:tarball
  =/  m  (fiber:fiber:nexus ,json)
  ^-  form:m
  ;<  vw=(unit view:nexus)  bind:m  (peek-soft:io road ~)
  ?.  ?=([~ %file *] vw)  (pure:m ~)
  (pure:m (fall (mole |.(;;(json (sang-noun:tarball sang.u.vw)))) ~))
::  ==  HTTP
::
::  +handle-request: the owner's alone until the boards arrive (phase 2)
::
++  handle-request
  |=  eyre-id=@ta
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  [src=@p req=inbound-request:eyre]  bind:m
    (get-state-as:io ,[src=@p inbound-request:eyre])
  ;<  our=@p  bind:m  get-our:io
  ?.  &(authenticated.req =(src our))
    (send-html eyre-id 403 'Only the owner of this ship may use furum here.')
  =/  site=(list @t)  site:(parse-request-line:server url.request.req)
  ?.  ?&  =(%'GET' method.request.req)
          ?=(?([%apps %furum ~] [%apps %furum %$ ~]) site)
      ==
    (send-html eyre-id 404 'No such page.')
  (send-html eyre-id 200 'Furum is installed. Boards arrive in the next release.')
::
++  send-html
  |=  [eyre-id=@ta code=@ud msg=@t]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  page=@t
    (rap 3 '<!doctype html><meta charset="utf-8"><title>furum</title><p>' msg '</p>' ~)
  %+  send-simple:srv  eyre-id
  [[code ['content-type' 'text/html; charset=utf-8'] ~] `(as-octs:mimes:html page)]
::  ==  after a crash: orrery's +rise-later (version 60), copied whole
::
::  +rise-later: a fiber that crashed goes on after a while by itself,
::  where +rise-wait:io left it down until some poke came, and took that
::  poke's payload as its restart signal. A crash that comes again waits
::  longer, 1, 2, 4 and up to 60 minutes (the count starts over two
::  quiet hours after the last), and only the first two print their
::  whole trace. A poke that comes while it waits is refused at once (a
::  nack) rather than held or dropped.
::
::  rise-later itself never fails: grubbery restarts a failed fiber at
::  once, in the same event, so a failure here would spin the ship. Its
::  clock and timer are soft, on fixed wires (a nonce is itself a
::  bowl.sig poke); with either refused it parks until a poke comes.
::
::  ponytail: fibers that crash in the same moment (a refused weir
::  fails them all) each write rise.json back from what they read, so
::  a row can be lost and that fiber's count starts again at 1; it
::  still waits. A grub per fiber would end it.
::
++  rise-later
  |=  [=prod:fiber:nexus msg=tape]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  ~  bind:m  take-kick
  ::  a clean start takes down any wait an earlier run left set: its wake
  ::  would come to a fiber no longer waiting for it
  ?~  prod
    ;<  *  bind:m  (soft-behn /rise/rest [[/ %timer-rest] `wire`/rise])
    (pure:m ~)
  =/  key=@t  (crip msg)
  ::  what a refused poke fails with; the restart that follows is not a crash
  =/  note=tang  ~[leaf+"{msg}: waiting after a crash; the poke was refused"]
  =/  crash=?  !=(note u.prod)
  ;<  clock=(unit @da)  bind:m  soft-now
  ?~  clock
    %-  ?.(crash same (slog [leaf+"{msg}: no clock (weir?); waiting for a poke" u.prod]))
    (rise-park note)
  =/  now=@da  u.clock
  ;<  log=json  bind:m  (read-json (rf 0 / %'rise.json'))
  =/  plan  (rise-plan:fr (gj:fr log key) crash now)
  ?.  (gth until.plan now)  (pure:m ~)
  ;<  ~  bind:m
    =/  m  (fiber:fiber:nexus ,~)
    ?.  crash  (pure:m ~)
    %-  %-  slog
        ?:  (lte n.plan 2)  [leaf+msg u.prod]
        ~[leaf+"{msg} again ({(a-co:co n.plan)} times running); next try in {(a-co:co (div (sub until.plan now) ~m1))} min"]
    ;<  *  bind:m
      %^  over-as-soft:io  (rf 0 / %'rise.json')
        [[/ %json] (set-key:fr log key (rise-row:fr plan now))]
      [/ %json]
    (pure:m ~)
  ;<  set=?  bind:m
    (soft-behn /rise/set [[/ %timer-set] `[wire @da]`[/rise until.plan]])
  %-  ?:(|(set !crash) same (slog leaf+"{msg}: no timer (weir?); waiting for a poke" ~))
  (rise-park note)
::  +take-kick: the start's kick, taken before anything is sent (rule 9
::  of the crash-loop rules). A reload or a restart queues a null kick
::  behind the inputs already waiting (a timer's wake, news, a late
::  answer), and a first step that sends asserts it was kicked, so a
::  queued input crashed it. Real inputs are held for the steps that wait.
::
++  take-kick
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  |=  input:fiber:nexus
  :+  ~  q.state
  ?~(in [%done ~] [%skip ~])
::  +rise-park: wait for the /rise wake; a poke meanwhile is refused with
::  note (the restart it brings is not a crash, see +rise-later)
::
++  rise-park
  |=  note=tang
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%wait ~]
      [~ %poke * *]
    ?.  =([/ %timer-wake] p.sage.u.in)  [%fail note]
    ?.  ?=([%rise *] !<(path q.sage.u.in))  [%wait ~]
    [%done ~]
  ==
::  +soft-behn: a poke to the timer service, & when it landed. A refusal
::  (a weir without /sys/behn) is | rather than a failure. The wire is
::  fixed: a nonce would ask /sys/bowl.sig for entropy, refusable too.
::
++  soft-behn
  |=  [=wire =bask:tarball]
  =/  m  (fiber:fiber:nexus ,?)
  ^-  form:m
  ;<  ~  bind:m
    (send-dart:io %node wire &+&+[/sys/behn %'main.behn-state'] %poke bask)
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %veto *]  [%done |]
      [~ %pack * *]
    ?.  =(wire wire.u.in)  [%skip ~]
    [%done =(~ err.u.in)]
  ==
::  +soft-now: the time, or ~ when /sys/bowl.sig refuses (+get-time:io
::  fails instead). The answer and its ack come in either order.
::
++  soft-now
  =/  m  (fiber:fiber:nexus ,(unit @da))
  ^-  form:m
  ;<  ~  bind:m
    (send-dart:io %node /rise/now &+&+[/sys %'bowl.sig'] %poke [[/ %bowl-req] %now])
  ;<  first=(unit (each @da ~))  bind:m
    =/  mi  (fiber:fiber:nexus ,(unit (each @da ~)))
    ^-  form:mi
    |=  input:fiber:nexus
    :+  ~  q.state
    ?+  in  [%skip ~]
        ~  [%wait ~]
        [~ %veto *]  [%done ~]
        [~ %pack * *]  ?^(err.u.in [%done ~] [%done `[%| ~]])
        [~ %poke * *]
      ?.  =([/ %time] p.sage.u.in)  [%skip ~]
      [%done `[%& !<(@da q.sage.u.in)]]
    ==
  ?~  first  (pure:m ~)
  ?:  ?=(%| -.u.first)
    ::  acked: now the answer
    |=  input:fiber:nexus
    :+  ~  q.state
    ?+  in  [%skip ~]
        ~  [%wait ~]
        [~ %poke * *]
      ?.  =([/ %time] p.sage.u.in)  [%skip ~]
      [%done `!<(@da q.sage.u.in)]
    ==
  ::  the answer first: take its ack
  ;<  ~  bind:m
    =/  md  (fiber:fiber:nexus ,~)
    ^-  form:md
    |=  input:fiber:nexus
    :+  ~  q.state
    ?+  in  [%skip ~]
        ~  [%wait ~]
        [~ %pack *]  [%done ~]
    ==
  (pure:m `p.u.first)
--
