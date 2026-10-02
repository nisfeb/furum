::  furum: decentralized forums, as a grubbery nexus. The plan, and the
::  reasons for its shape, are in docs/grubbery-migration.md.
::
::  The tree this nexus owns (every persistent path has a row in +on-load):
::    /main.sig            the writer: every mutation goes through it
::    /inbox.sig           the one road another ship may poke (+grant-public):
::                         actions on our boards, registry actions, notes
::    /web.sig             binds /apps/furum; one fiber per request
::    /prune.sig           the auto-prune tick, on a 6-hour grid
::    /sweep.sig           wakes the writer when a member's time runs out
::    /dir.sig             keeps this ship's copy of the registry's directory
::    /requests/<id>       the ephemeral request fibers
::    /outbox/<id>         one message to another ship, and its fiber
::    /boards/<name>/…     one board we host, in the grubs lib/furum-board names:
::                         pub/ anyone reads; content/ too, or its members
::    /members/<name>      who may read a paid board, and until when
::    /pay/<id>            one payment under way, and its fiber
::    /wallets/<name>      a board's ecash, by mint, with every version kept
::    /payments            the payments this ship made to other ships' boards
::    /sweep               when a member next runs out
::    /follows/<host>/<name>  a board on another ship we read; its follower
::    /gone/<host>/<name>  when its host last said it has no such board
::    /cache/<host>/<name>/…  that board's mirror, the same grubs
::    /feed                the boards in the home feed
::    /prefs  /seen  /limits  the theme, push tags, the registry ship; what
::                         you last read; rate limits
::    /notes               notifications, newest first, the last 50
::    /registry            the directory, on the ship that keeps it (public)
::    /directory           this ship's copy of it
::    /grant.json          the shell's record of our grant, with our own path
::    /tr/last  /tr/inbox  the writer's last refusal; what other ships poked
::    /tr/dir              why the registry's directory last failed to read
::    /tr/fault            each fault a person should act on, said once (+alarm)
::    /rise.json           per fiber, its crashes in a row and its next try
::    tile, link, weir and icon: laid fresh on every load
::
::  ROADS ARE NEXUS-RELATIVE. A desk-installed app cannot learn its own
::  absolute path, so every road is [%| up lane], where up is the number
::  of steps from the calling fiber to the nexus root: 0 for the fibers
::  at the root, 1 for a request or outbox fiber, 2 for a follower.
::
::  THE WRITER MUST NOT CRASH. Every refusal is a branch that returns
::  cleanly and writes /tr/last. A request that must see its write asks
::  ([/furum %ask]) and the writer answers it once the tree has changed.
::
/<  *   /lib/furum-types.hoon
/<  fr  /lib/furum-rules.hoon
/<  fl  /lib/furum.hoon
/<  fb  /lib/furum-board.hoon
/<  fg  /lib/furum-registry.hoon
/<  ca  /lib/cashu.hoon
/<  th  /lib/furum-theme.hoon
::  the logo, the single source of the tile's icon and the favicon
/<  icon  icon.svg
=<  ^-  nexus:nexus
    |%
    ++  on-load
      |=  =ball:tarball
      ^-  bole:tarball
      =/  tile=json
        %-  pairs:enjs:format
        :~  title+s+'Furum'
            info+s+'Decentralized forums for Urbit'
            color+s+'#101541'
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
          [%over %& [/ %'icon.svg'] [[/ %mime] [/image/'svg+xml' +.icon]]]
          [%fall %& [/ %'main.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'inbox.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'web.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'prune.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'dir.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'sweep.sig'] [[/ %sig] ~]]
          [%fall %| /members empty-dir:loader]
          [%fall %| /pay empty-dir:loader]
          [%fall %| /wallets empty-dir:loader]
          [%fall %& [/ %payments] [[/ %noun] [%1 ~]]]
          [%fall %& [/ %sweep] [[/ %noun] [%1 ~]]]
          [%fall %| /requests empty-dir:loader]
          [%fall %| /outbox empty-dir:loader]
          [%fall %| /boards empty-dir:loader]
          [%fall %| /follows empty-dir:loader]
          [%fall %| /gone empty-dir:loader]
          [%fall %| /cache empty-dir:loader]
          [%fall %& [/ %feed] [[/ %noun] [%1 ~]]]
          [%fall %& [/ %prefs] [[/ %noun] [%4 default-prefs]]]
          [%fall %& [/ %notes] [[/ %noun] [%1 ~]]]
          [%fall %& [/ %registry] [[/ %noun] [%1 *registry-store]]]
          [%fall %& [/ %directory] [[/ %noun] [%1 *registry-store]]]
          [%stay %& [/ %'grant.json']]
          [%fall %& [/ %seen] [[/ %noun] [%1 ~ ~]]]
          [%fall %& [/ %limits] [[/ %noun] [%1 ~]]]
          [%fall %| /tr empty-dir:loader]
          [%fall %& [/tr %last] [[/ %json] [%o ~]]]
          [%fall %& [/tr %inbox] [[/ %json] [%a ~]]]
          [%fall %& [/tr %dir] [[/ %noun] [%1 ~]]]
          [%fall %& [/tr %fault] [[/ %noun] [%1 ~]]]
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
          ::  and drops it when that fiber dies (phase 0, spike B). An ask
          ::  is answered once it is applied, refused or not
          [~ %'main.sig']
        ;<  ~  bind:m  (rise-later 0 prod %writer "%furum writer: failed")
        ::  jailed (no clock yet), the approval reload does this
        ;<  clock=(unit @da)  bind:m  soft-now
        ;<  ~  bind:m  ?~(clock (pure:m ~) ;<(~ bind:m grant-public sweep-all))
        ;<  ~  bind:m  ?~(clock (pure:m ~) check-grant)
        |-
        ;<  [=from:fiber:nexus =sage:tarball]  bind:m  take-poke-from:io
        ;<  res=(unit deny)  bind:m  (apply from sage)
        ;<  ~  bind:m
          ?.  =([/furum %ask] p.sage)  (pure:m ~)
          ;<  *  bind:m  (poke-soft:io [%| p.from %& q.from] [[/furum %done] res])
          (pure:m ~)
        $
          ::  the inbox: the sender is the transport's, never the
          ::  payload's. A local poke is ignored. What the writer refuses
          ::  (it is waiting after a crash) is dropped, not retried
          [~ %'inbox.sig']
        ;<  ~  bind:m  (rise-later 0 prod %inbox "%furum inbox: failed")
        |-
        ;<  [=from:fiber:nexus =sage:tarball]  bind:m  take-poke-from:io
        =/  src=(unit @p)  (get-poke-src:io from)
        ;<  *  bind:m
          ?~  src  (pure:(fiber:fiber:nexus ,(unit tang)) ~)
          (poke-soft:io (rf 0 / %'main.sig') [[/furum %op] `op`[%from u.src p.sage q.q.sage]])
        $
          ::  the HTTP binder. bind-http-self is veto-tolerant: jailed,
          ::  it logs and waits; the approval reload binds for real
          [~ %'web.sig']
        ;<  ~  bind:m  (rise-later 0 prod %web "%furum web: failed")
        ;<  ~  bind:m  (bind-http-self:io [~ /apps/furum])
        (http-dispatch:io %furum)
          ::  auto-prune: at each slot of the 6-hour grid, the writer
          ::  prunes every board that asks for it
          [~ %'prune.sig']
        ;<  ~  bind:m  (rise-later 0 prod %prune "%furum prune: failed")
        |-
        ;<  now=@da  bind:m  get-time:io
        ;<  ~  bind:m  (sleep:io (sub (prune-at:fr now) now))
        ;<  *  bind:m  (poke-soft:io (rf 0 / %'main.sig') [[/furum %op] `op`[%prune ~]])
        $
          ::  the sweeper: when a member's time runs out, the writer
          ::  takes the ship out of the board's group
          [~ %'sweep.sig']
        ;<  ~  bind:m  (rise-later 0 prod %sweep "%furum sweep: failed")
        ;<  *  bind:m  (keep-soft:io /s (rf 0 / %sweep) ~ ~s30)
        sweeper
          ::  this ship's copy of the registry's directory
          [~ %'dir.sig']
        ;<  ~  bind:m  (rise-later 0 prod %directory "%furum directory: failed")
        (read-registry 0)
          ::  a follower: the mirror of one board on another ship
          [[%follows @ ~] @]
        ;<  ~  bind:m  (rise-later 2 prod %follower "%furum follower {(trip i.t.path.rail)}/{(trip name.rail)}: failed")
        ;<  our=@p  bind:m  get-our:io
        =/  host=(unit @p)  (slaw %p i.t.path.rail)
        ?:  |(?=(~ host) =(`our host))  (pure:m ~)
        (follow u.host name.rail 0)
          ::  one message to another ship. One that crashed is dropped:
          ::  sent again it could arrive twice
          [[%outbox ~] @]
        ;<  ~  bind:m  take-kick
        ?^  prod  (tell [%sent name.rail])
        (send-out name.rail)
          ::  one payment, carried on from the step its grub holds
          [[%pay ~] @]
        ;<  ~  bind:m  (rise-later 1 prod %payment "%furum payment: failed")
        (run-pay name.rail)
          ::  one ephemeral fiber per request. One that crashed ends:
          ::  nothing would poke it awake. The kick first, or a late
          ::  answer queued before it crashes the first step at a reload
          [[%requests ~] @]
        ;<  ~  bind:m  take-kick
        ?^  prod  (alarm 1 %crash-request 2 (say-crash %request) ~)
        (handle-request name.rail)
      ==
    --
|%
::  ==  roads
::
++  rf  |=([up=@ud p=path n=@ta] ^-(road:tarball [%| up [%& p n]]))
++  rv  |=([up=@ud p=path] ^-(road:tarball [%| up [%| p]]))
++  srv  ~(. http-res:io [%| 1 %& ~ %'web.sig'])
::  +op: what the writer takes, as a noun under [/furum %op] or, to be
::  answered, [/furum %ask]; clammed under mule, so a malformed one is
::  refused and never a crash
::
+$  op
  $%  [%from src=@p mark=blot:tarball noun=*]
      [%act who=@p =action]
      [%seen host=@p name=board-name pid=(unit post-id)]
      [%prune ~]
      [%watch host=@p name=board-name]
      [%gone host=@p name=board-name]
      [%sent name=@ta]
      [%prefs tags=(unit (set term)) registry=(unit @p)]
      [%reg who=@p here=path act=registry-action]
      [%sweep ~]
      [%settle id=@ta]
      [%spend id=@ta]
      [%paying host=@p name=board-name nonce=@t ln=?]
      [%look =looks]
  ==
::  your preferences: the theme, which notes push to your browsers, and
::  the ship whose directory you read
::
+$  prefs  [=looks tags=(set term) registry=@p]
::  the theme: light, dark or the device's; whether talon's theme settings
::  rule (on unless turned off); furum's own saved themes and accent
+$  looks  [mode=mode:th talon=? own=themes:th accent=accent:th]
::  prefs as %3 kept them, before a theme could set more than five colours
+$  prefs-3
  $:  looks=[mode=mode:th talon=? own=[list=(list theme-5:th) active=(unit @t)] accent=accent:th]
      tags=(set term)
      registry=@p
  ==
++  default-looks  `looks`[%system & [~ ~] [~ %profile ~]]
++  default-prefs  `prefs`[default-looks (sy ~[%comments %new-posts %payments]) ~ricsul-bilwyt]
+$  seen  [boards=(map [@p board-name] @da) posts=(map [@p board-name post-id] @da)]
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
          (line '/sys/behn/' 'auto-prune boards on schedule, and after a crash wait a while and try again. Refuse this and neither happens')
          (line '/sys/ames/registry' 'let other ships reach your inbox, to post, comment and vote on your boards. Refuse this and nobody else can use your boards')
          (line '/sys/ames/ships/' 'post, comment and vote on boards other ships host, register your boards in the directory, and tell people when someone answers them. Refuse this and furum only works on your own boards')
          (line '/sys/push/' 'show notifications in your browser. Refuse this and they still collect on the notifications page')
          (line '/sys/iris/' 'take payment for paid boards, from the Cashu mint each one names. Refuse this and nobody can pay for your boards')
          (line '/sys/scry/' 'follow the theme you picked in talon (its settings in %settings) and your %contacts profile colour. Refuse this and furum uses its own theme settings')
      ==
      :-  'make'
      :-  %a
      :~  (line '/sys/ames/usergroups/' 'keep a group for each paid board: its members and moderators, the ships that may read it. Refuse this and a paid board stays closed to everyone but you')
      ==
      :-  'peek'
      :-  %a
      :~  (line '/sys/ames/ships/' 'read boards other ships host, keep them current, and read the board directory. Refuse this and you see only your own boards')
      ==
  ==
::  +grant-public: open the inbox to every ship, and let every ship read
::  the registry (empty but where we keep it), each board's pub/, and a
::  free board's content/. The set is complete each time: the registry
::  replaces what we granted before. Sent by the writer
::  itself: the registry keys a grant to the rail that registered, and
::  drops a %how from any other fiber without a word. A refused road is
::  kept at /tr/fault and said once (+alarm), and the boards stay local.
::
++  grant-public
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  reg=(unit tang)  bind:m  (reg-register-at-soft:io [/ %'main.sig'])
  ?^  reg  (alarm-ungranted 0 %inbox 'poke' '/sys/ames/registry' say-inbox)
  ;<  names=(list @ta)  bind:m  (board-names 0)
  ;<  open=(list road:tarball)  bind:m  (public-roads names)
  ;<  how=(unit tang)  bind:m
    %+  reg-how-soft:io  /public
    [~ (sy ~[(rf 0 / %'inbox.sig')]) (silt [(rf 0 / %registry) open])]
  ?~  how  (pure:m ~)
  (alarm-ungranted 0 %inbox 'poke' '/sys/ames/registry' say-inbox)
::  ==  the writer
::
::  +apply: one op from a poke, answered with why it was refused, or ~.
::  Only this nexus's own fibers may write.
::
++  apply
  |=  [=from:fiber:nexus =sage:tarball]
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ?^  (get-poke-src:io from)  (refuse 403 'a ship may not write here')
  ?.  |(=([/furum %op] p.sage) =([/furum %ask] p.sage))  (refuse 400 'not an op')
  =/  o=(unit op)  (mole |.(;;(op q.q.sage)))
  ?~  o  (refuse 400 'a malformed op')
  ?-    -.u.o
      %from   ;<(~ bind:m (from-ship +.u.o) (pure:m ~))
      %seen   ;<(~ bind:m (write-seen +.u.o) (pure:m ~))
      %prune  ;<(~ bind:m prune-all (pure:m ~))
      %watch  ;<(~ bind:m (watch +.u.o) (pure:m ~))
      %gone   ;<(~ bind:m (give-up +.u.o) (pure:m ~))
      %prefs  ;<(~ bind:m (set-prefs +.u.o) (pure:m ~))
      %sent   ;<(* bind:m (cull-soft:io (rf 0 /outbox name.u.o)) (pure:m ~))
      %act    (do-act who.u.o action.u.o)
      %reg    (do-reg +.u.o)
      %sweep  ;<(~ bind:m sweep-all (pure:m ~))
      %settle  (settle id.u.o)
      %spend   (spend id.u.o)
      %paying  ;<(~ bind:m (paying +.u.o) (pure:m ~))
      %look    (set-looks looks.u.o)
  ==
::  +refuse: a refused op, as the writer's last outcome at /tr/last
::
++  refuse
  |=  d=deny
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  ;<  ~  bind:m
    %+  over:io  (rf 0 /tr %last)
    :-  [/ %json]
    %-  pairs:enjs:format
    :~  ['at' s+(scot %da now)]
        ['code' (numb:enjs:format code.d)]
        ['why' s+why.d]
    ==
  (pure:m `d)
::  +do-act: one user action, by `who`
::
++  do-act
  |=  [who=@p =action]
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ?:  ?=(?(%toggle-dark-mode %follow-board %unfollow-board %mark-notifications-read) -.action)
    ?.  =(who our)  (refuse 403 'only the owner keeps these preferences')
    ?-    -.action
        %toggle-dark-mode         ;<(~ bind:m toggle-dark (pure:m ~))
        %mark-notifications-read  ;<(~ bind:m read-all-notes (pure:m ~))
    ::  the feed, and for another ship's board its mirror too
        %follow-board
      ?.  (valid-board-name:fl name.action)  (refuse 404 'board not found')
      ;<  ~  bind:m  (feed-put [host name]:action &)
      ?:  =(our host.action)  (pure:m ~)
      ;<(~ bind:m (watch [host name]:action) (pure:m ~))
    ::
        %unfollow-board  ;<(~ bind:m (feed-put [host name]:action |) (pure:m ~))
    ==
  ?:  ?=(?(%submit-payment %request-lightning-invoice %melt-to-lightning) -.action)
    (start-pay who action)
  =/  name=(unit board-name)  (board-of action)
  ?~  name  (refuse 501 'not in this release of furum')
  ::  a name no board can have is never made into a path
  ?.  (valid-board-name:fl u.name)
    ?:  ?=(%create-board -.action)  (refuse 400 'board names may only use a-z, 0-9 and -')
    (refuse 404 'board not found')
  ;<  now=@da  bind:m  get-time:io
  ;<  old=(map path *)  bind:m  (read-grubs 0 u.name)
  ::  who paid is kept apart from the board; unreadable, it is refused
  ::  rather than written back empty
  ;<  mem=(each (map @p @da) @t)  bind:m  (read-members 0 u.name)
  ?:  ?=(%| -.mem)  (refuse 500 p.mem)
  =/  have=(each (unit board) @t)
    ?:  =(~ old)  &+~
    =/  r  (load:fb ~(tap by old))
    ?:(?=(%| -.r) r &+`p.r(paid p.mem))
  ?:  ?=(%| -.have)  (refuse 500 p.have)
  ;<  lim=limits  bind:m  read-limits
  =/  r  (act:fb who our now action p.have lim)
  ?:  ?=(%| -.r)  (refuse p.r)
  ;<  ~  bind:m  (store u.name old brd.p.r)
  ;<  ~  bind:m  (store-members u.name p.mem brd.p.r)
  ;<  ~  bind:m
    ?:  =(lim lim.p.r)  (pure:(fiber:fiber:nexus ,~) ~)
    (over:io (rf 0 / %limits) [[/ %noun] [%1 lim.p.r]])
  ;<  ~  bind:m
    ?.  ?=(?(%create-board %delete-board %set-payment %grant-paid %revoke-paid %set-role %remove-role) -.action)
      (pure:(fiber:fiber:nexus ,~) ~)
    (sync-access u.name p.have brd.p.r)
  ::  and whoever it concerns hears of it
  =/  notes=(list note-out)  ?~(brd.p.r ~ (notes-for:fb who action u.brd.p.r))
  |-  ^-  form:m
  ?~  notes  (pure:m ~)
  ;<  ~  bind:m  (note-to i.notes)
  $(notes t.notes)
::  +board-of: the board an action is on, when it is a board action this
::  release carries
::
++  board-of
  |=  =action
  ^-  (unit board-name)
  ?+  -.action  ~
    %create-board     `name.action
    %delete-board     `name.action
    %edit-board-info  `name.action
    %set-public       `name.action
    %set-prune        `name.action
    %pin-post         `name.action
    %set-sidebar      `name.action
    %set-role         `name.action
    %remove-role      `name.action
    %new-post         `name.action
    %delete-post      `name.action
    %edit-post        `name.action
    %new-comment      `name.action
    %delete-comment   `name.action
    %upvote           `name.action
    %downvote         `name.action
    %remove-vote      `name.action
    %set-payment      `name.action
    %grant-paid       `name.action
    %revoke-paid      `name.action
  ==
::  +store: a board's grubs brought from `old` to `new`: a new board is
::  made whole, a deleted one culled whole, and otherwise only the grubs
::  that changed are written and the ones emptied culled.
::  ponytail: +grubs splits the whole board on every write, O(board); a
::  split of only the touched buckets if big boards write slowly
::
++  store
  |=  [name=board-name old=(map path *) new=(unit board)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  dir=path  /boards/[name]
  ?~  new
    ?:  =(~ old)  (pure:m ~)
    (cull:io (rv 0 dir))
  =/  gs=(map path *)  (grubs:fb u.new)
  ?:  =(~ old)  (make:io (rv 0 dir) &+(board-bole gs))
  =/  put=(list [path *])
    (skip ~(tap by gs) |=([p=path v=*] =(`v (~(get by old) p))))
  =/  gone=(list path)
    (skip ~(tap in ~(key by old)) |=(p=path (~(has by gs) p)))
  ;<  ~  bind:m
    |-  ^-  form:m
    ?~  put  (pure:m ~)
    ;<  ~  bind:m  (over:io (rf 0 (weld dir (snip -.i.put)) (rear -.i.put)) [[/ %noun] +.i.put])
    $(put t.put)
  |-  ^-  form:m
  ?~  gone  (pure:m ~)
  ;<  ~  bind:m  (cull:io (rf 0 (weld dir (snip i.gone)) (rear i.gone)))
  $(gone t.gone)
::  +board-bole: a new board's directory, its bucket directories made
::  empty so every later write has a parent
::
++  board-bole
  |=  gs=(map path *)
  ^-  bole:tarball
  =/  dirs=(map path (map @ta *))
    (my ~[[/content/posts ~] [/content/threads ~] [/content/votes ~]])
  =.  dirs
    %+  roll  ~(tap by gs)
    |=  [[p=path v=*] =_dirs]
    (~(put by dirs) (snip p) (~(put by (~(gut by dirs) (snip p) ~)) (rear p) v))
  %+  roll  ~(tap by dirs)
  |=  [[d=path fs=(map @ta *)] b=bole:tarball]
  %+  ~(put of b)  d
  [~ ~ | (~(run by fs) |=(v=* [[[/ %noun] v] |]))]
::  +prune-all: each board that asks for it loses the posts +prunable
::  names; a board that won't load is left alone
::
++  prune-all
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  ;<  names=(list @ta)  bind:m  (board-names 0)
  |-  ^-  form:m
  ?~  names  (pure:m ~)
  ;<  old=(map path *)  bind:m  (read-grubs 0 i.names)
  =/  r  (load:fb ~(tap by old))
  ?.  ?=(%& -.r)  $(names t.names)
  =*  brd  p.r
  ?~  prune.brd  $(names t.names)
  =/  ids=(list post-id)  (prunable:fr brd u.prune.brd now)
  ?~  ids  $(names t.names)
  ;<  ~  bind:m  (store i.names old `(drop-posts:fb brd ids))
  $(names t.names)
::
::  +toggle-dark: the old light/dark switch, as a mode
::
++  toggle-dark
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs 0)
  =.  mode.looks.pf  ?:(=(%dark mode.looks.pf) %light %dark)
  (over:io (rf 0 / %prefs) [[/ %noun] [%4 pf]])
::
++  set-prefs
  |=  [tags=(unit (set term)) registry=(unit @p)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs 0)
  =?  tags.pf  ?=(^ tags)  u.tags
  =?  registry.pf  ?=(^ registry)  u.registry
  (over:io (rf 0 / %prefs) [[/ %noun] [%4 pf]])
::  +set-looks: the theme settings, when they are sane: at most fifty
::  themes, each with a name and five colours that read
::
++  set-looks
  |=  l=looks
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ?:  (gth (lent list.own.l) 50)  (refuse 400 'at most fifty themes')
  =/  good
    |=  t=theme:th
    ?&  (sane-text:fr id.t 64)
        (sane-text:fr name.t 100)
        (levy `(list @t)`~[primary.t secondary.t tertiary.t background.t surface.t] |=(h=@t !=(~ (parse:th h))))
    ==
  ?.  (levy list.own.l good)  (refuse 400 'a theme needs a name and five colours')
  ?:  &(?=(^ hex.accent.l) =(~ (parse:th u.hex.accent.l)))  (refuse 400 'that is not a colour')
  ;<  pf=prefs  bind:m  (read-prefs 0)
  ;<  ~  bind:m  (over:io (rf 0 / %prefs) [[/ %noun] [%4 pf(looks l)]])
  (pure:m ~)
::
++  feed-put
  |=  [key=[@p board-name] add=?]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  f=(set [@p board-name])  bind:m  (read-feed 0)
  =/  g  ?:(add (~(put in f) key) (~(del in f) key))
  ?:  =(f g)  (pure:m ~)
  (over:io (rf 0 / %feed) [[/ %noun] [%1 g]])
::  +watch: mirror a board on another ship, unless we do already. The
::  follows grub is never rewritten: its fiber is the follower.
::
++  watch
  |=  [host=@p name=board-name]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?.  (valid-board-name:fl name)  (pure:m ~)
  ;<  our=@p  bind:m  get-our:io
  ?:  =(our host)  (pure:m ~)
  ;<  n=(unit *)  bind:m  (read-noun (rf 0 /follows/(scot %p host) name))
  ?^  n  (pure:m ~)
  (over:io (rf 0 /follows/(scot %p host) name) [[/ %noun] [%1 ~]])
::  +give-up: its host has no such board. Stop following it, drop any
::  copy we kept, and say when, so its page says so instead of loading.
::
::  ponytail: /gone keeps one grub per board ever found missing; only the
::  owner's own visits make them. Prune them if that ever adds up.
::
++  give-up
  |=  [host=@p name=board-name]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  ;<  ~  bind:m  (over:io (rf 0 /gone/(scot %p host) name) [[/ %noun] [%1 now]])
  ;<  *  bind:m  (cull-soft:io (rf 0 /follows/(scot %p host) name))
  ;<  *  bind:m  (cull-soft:io (rv 0 /cache/(scot %p host)/[name]))
  (pure:m ~)
::  ==  from other ships
::
::  +from-ship: a poke another ship made to our inbox. Traced on its own
::  ring; then an action on a board we host, applied as that ship's (a
::  refusal is told back to it), a registry action if we keep the
::  registry, or a note for our owner
::
++  from-ship
  |=  [src=@p mark=blot:tarball noun=*]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  ~  bind:m  (trace-inbox src mark)
  ?.  =([/furum %msg] mark)  (pure:m ~)
  ?~  g=(mole |.(;;(msg noun)))  (pure:m ~)
  ?-    -.u.g
      %note  (take-note src +.u.g)
      %pay   (take-pay src +.u.g)
  ::  a payment refused is told as its answer, which its page waits on
      %act
    ;<  res=(unit deny)  bind:m  (do-act src action.u.g)
    ?~  res  (pure:m ~)
    =*  a  action.u.g
    ?:  ?=(%submit-payment -.a)  (mail src [%pay name.a nonce.a %failed why.u.res])
    ?:  ?=(%request-lightning-invoice -.a)  (mail src [%pay name.a nonce.a %failed why.u.res])
    ;<  our=@p  bind:m  get-our:io
    =/  at=(unit @t)
      ?~  b=(board-of action.u.g)  ~
      `(crip "/apps/furum/b/{(scow %p our)}/{(trip u.b)}")
    (note-to [src (crip "{(scow %p our)} refused your change") why.u.res at ~])
  ::
      %reg
    ;<  res=(unit deny)  bind:m  (do-reg src here.u.g registry-action.u.g)
    ?~  res  (pure:m ~)
    ;<  our=@p  bind:m  get-our:io
    (note-to [src (crip "the directory on {(scow %p our)} refused your change") why.u.res ~ ~])
  ==
::  +take-note: a note from another ship, kept only from a ship whose
::  boards we read. Our own notes never come this way (+note-to).
::
++  take-note
  |=  [src=@p title=@t body=@t url=(unit @t) tags=(set term)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  vw=(unit view:nexus)  bind:m  (peek-soft:io (rv 0 /follows/(scot %p src)) ~)
  ?.  ?=([~ %ball *] vw)  (pure:m ~)
  ;<  ~  bind:m  (keep-note title body url tags)
  ::  a note from a host about one of its boards we follow (it let us
  ::  in) has that board's follower ask for its content again
  =/  at=(unit path)  (biff url |=(u=@t (rush u stap)))
  ?.  ?=([~ %apps %furum %b @ @ ~] at)  (pure:m ~)
  ?.  =(`src (slaw %p i.t.t.t.u.at))  (pure:m ~)
  ;<  *  bind:m  (poke-soft:io (rf 0 /follows/(scot %p src) i.t.t.t.t.u.at) [[/furum %op] ~])
  (pure:m ~)
::  +note-to: a note for someone: kept here if it is for us, else sent
::  through the outbox
::
++  note-to
  |=  n=note-out
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ?:  =(our to.n)  (keep-note title.n body.n url.n tags.n)
  (mail to.n [%note title.n body.n url.n tags.n])
::  +mail: a message to another ship, through the outbox
::
++  mail
  |=  [to=@p =msg]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  eny=@uvJ  bind:m  get-entropy:io
  (over:io (rf 0 /outbox (scot %uv (end [3 8] eny))) [[/ %noun] `[@p ^msg]`[to msg]])
::  +keep-note: a note on the notifications page, and in the browser when
::  its kind is one the owner wants pushed. Its link must be one the
::  pages may follow.
::
++  keep-note
  |=  [title=@t body=@t url=(unit @t) tags=(set term)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  =/  t=@t  (crip (scag 200 (trip title)))
  =/  b=@t  (crip (scag 500 (trip body)))
  =/  u=(unit @t)  ?~(url ~ ?.((safe-url:fl u.url) ~ url))
  ;<  old=(list notification)  bind:m  (read-notes 0)
  ;<  ~  bind:m
    (over:io (rf 0 / %notes) [[/ %noun] [%1 `(list notification)`[[t b u now |] (scag 49 old)]]])
  ;<  pf=prefs  bind:m  (read-prefs 0)
  ?:  =(~ (~(int in tags) tags.pf))  (pure:m ~)
  (push-soft t b u)
::
++  read-all-notes
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  old=(list notification)  bind:m  (read-notes 0)
  (over:io (rf 0 / %notes) [[/ %noun] [%1 (turn old |=(n=notification n(read &)))]])
::  +push-soft: a notification to our own browsers. Refused (no push
::  road), the note is still on the page.
::
++  push-soft
  |=  [title=@t body=@t url=(unit @t)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ;<  eny=@uvJ  bind:m  get-entropy:io
  ;<  *  bind:m
    %+  poke-soft:io  push-road:io
    [[/ %push-action] [%send [(sy ~[our]) ~ ~ [title body ~ url ~]] eny]]
  (pure:m ~)
::  +do-reg: a registry action, when this ship keeps the registry
::
++  do-reg
  |=  [who=@p here=path act=registry-action]
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ;<  pf=prefs  bind:m  (read-prefs 0)
  ?.  =(our registry.pf)  (refuse 404 'this ship keeps no directory')
  ;<  st=registry-store  bind:m  (read-store (rf 0 / %registry))
  =/  r  (reg-act:fg who our here act st)
  ?:  ?=(%| -.r)  (refuse p.r)
  ;<  ~  bind:m
    ?:  =(st p.r)  (pure:(fiber:fiber:nexus ,~) ~)
    (over:io (rf 0 / %registry) [[/ %noun] [%1 p.r]])
  (pure:m ~)
::
++  write-seen
  |=  [host=@p name=board-name pid=(unit post-id)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  ;<  s=seen  bind:m  (read-seen 0)
  =.  s
    ?~  pid  s(boards (~(put by boards.s) [host name] now))
    s(posts (~(put by posts.s) [host name u.pid] now))
  (over:io (rf 0 / %seen) [[/ %noun] [%1 s]])
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
::  ==  payments
::
::  One grub per payment, /pay/<id>, and its fiber (+run-pay). The grub
::  holds the step the payment is on, and a step is written before the
::  request it leads to, so a restart (a reload, a crash, a ship coming
::  back) carries on from where the payment stood. What a mint may have
::  done already is asked before anything is done again: its signatures
::  on our outputs (NUT-09 restore), for a swap or a mint; whether a
::  melt's proofs are spent (NUT-07 checkstate), for a withdrawal. The
::  writer turns a finished payment into wallet proofs and access, then
::  culls the grub, which ends its fiber.
::
::  (its shape, $pay, is in lib/furum-types)
::
::  +start-pay: a payment asked for, made a pay grub. A paid board takes
::  ecash only from a mint it trusts (+mint-accepted), Lightning only
::  through the mint it names, and a ship has three payments under way
::  at most. A withdrawal is the host's, one per board at a time.
::
++  start-pay
  |=  [who=@p =action]
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ?>  ?=(?(%submit-payment %request-lightning-invoice %melt-to-lightning) -.action)
  ?.  (valid-board-name:fl name.action)  (refuse 404 'board not found')
  ;<  our=@p  bind:m  get-our:io
  ;<  a=(unit board)  bind:m  (read-access name.action)
  ?~  a  (refuse 404 'board not found')
  ;<  live=(list pay)  bind:m  (read-pays 0)
  ?:  ?=(%melt-to-lightning -.action)
    ?.  =(who our)  (refuse 403 'only the host withdraws')
    ::  only a withdrawal is ever at %melt or %melting
    ?:  (lien live |=(q=pay &(=(name.action name.q) ?=(?(%melt %melting) -.step.q))))
      (refuse 409 'a withdrawal from this board is under way')
    ?.  (sane-text:fr invoice.action 2.000)  (refuse 400 'that is not a Lightning invoice')
    =/  mint=@t  (crip (clean-mint-url:ca mint.action))
    ;<  w=(each (map @t (list cashu-proof)) @t)  bind:m  (read-wallet 0 name.action)
    ?:  |(?=(%| -.w) =(~ (~(gut by p.w) mint ~)))
      (refuse 400 'the wallet holds nothing from that mint')
    (new-pay [our name.action '' mint 0 ~s0 %melt invoice.action])
  ?>  ?=(?(%submit-payment %request-lightning-invoice) -.action)
  ?~  pc=payment.u.a  (refuse 400 'this board is free')
  ?:  =(who our)  (refuse 400 'you host this board')
  =/  nonce=@t  ?:(?=(%submit-payment -.action) nonce.action nonce.action)
  ?.  (sane-text:fr nonce 128)  (refuse 400 'a bad payment nonce')
  ?:  (gte (lent (skim live |=(q=pay =(who who.q)))) 3)
    (refuse 429 'three payments are already under way; wait for one to finish')
  ?:  ?=(%request-lightning-invoice -.action)
    ?~  mint.u.pc  (refuse 400 'this board takes no Lightning: it names no mint')
    %-  new-pay
    [who name.action nonce (crip (clean-mint-url:ca u.mint.u.pc)) price.u.pc interval.u.pc %quote ~]
  ?>  ?=(%submit-payment -.action)
  ?.  (mint-accepted:fl u.pc mint.action)  (refuse 400 'this board takes no ecash from that mint')
  ?~  i=(token-inputs:ca tokens.action)  (refuse 400 'that is not a cashu token')
  ?:  (lth total.u.i price.u.pc)  (refuse 402 'the token is worth less than the price')
  %-  new-pay
  [who name.action nonce (crip (clean-mint-url:ca mint.action)) price.u.pc interval.u.pc %swap inputs.u.i]
::  +new-pay: its grub, named for the payer and its nonce, so an ask
::  that comes twice is one payment
::
++  new-pay
  |=  p=pay
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ;<  eny=@uvJ  bind:m  get-entropy:io
  =/  id=@ta  (crip ((x-co:co 16) (end [3 8] ?:(=('' nonce.p) eny (sham [who.p nonce.p])))))
  ;<  n=(unit *)  bind:m  (read-noun (rf 0 /pay id))
  ?^  n  (refuse 409 'that payment is already under way')
  ;<  ~  bind:m  (over:io (rf 0 /pay id) [[/ %noun] [%1 p]])
  (pure:m ~)
::  +settle: a finished payment. Its proofs go to the board's wallet
::  first, then the grub is culled, so it is settled once; then the
::  payer has its access, from when its last runs out or from now, and
::  word of it or of why it failed. A withdrawal's outcome is a note.
::
++  settle
  |=  id=@ta
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf 0 /pay id))
  ?~  g=(mole |.(;;([%1 pay] (need n))))  (pure:m ~)
  =/  p=pay  +.u.g
  =*  s  step.p
  ?.  ?=(?(%done %failed) -.s)  (pure:m ~)
  ;<  ok=?  bind:m  (wallet-change name.p mint.p ?:(?=(%done -.s) got.s back.s) |)
  ?.  ok  (refuse 500 'unreadable: wallet; the payment waits')
  ;<  ~  bind:m  (cull:io (rf 0 /pay id))
  ;<  our=@p  bind:m  get-our:io
  =/  at=(unit @t)  `(crip "/apps/furum/b/{(scow %p our)}/{(trip name.p)}/mod")
  =/  tag  (sy ~[%payments])
  ?:  =(our who.p)
    ;<  ~  bind:m
      ?:  ?=(%failed -.s)  (keep-note 'A withdrawal failed' why.s at tag)
      (keep-note 'A withdrawal was paid' (crip "{(a-co:co (sats got.s))} sats came back as change") at tag)
    (pure:m ~)
  ?:  ?=(%failed -.s)
    ;<  ~  bind:m  (mail who.p [%pay name.p nonce.p %failed why.s])
    (pure:m ~)
  ;<  now=@da  bind:m  get-time:io
  ;<  mem=(each (map @p @da) @t)  bind:m  (read-members 0 name.p)
  =/  until=@da  (add interval.p ?.(?=(%& -.mem) now (max now (~(gut by p.mem) who.p now))))
  ;<  res=(unit deny)  bind:m  (do-act our [%grant-paid name.p who.p until])
  ?^  res
    ;<  ~  bind:m  (mail who.p [%pay name.p nonce.p %failed why.u.res])
    (pure:m ~)
  ;<  ~  bind:m  (mail who.p [%pay name.p nonce.p %paid until])
  ;<  ~  bind:m
    %^  keep-note  'New paid subscriber'
      (crip "{(scow %p who.p)} paid {(a-co:co (sats got.s))} sats for {(trip name.p)}")
    [at tag]
  (pure:m ~)
::  +spend: a withdrawal's proofs out of the wallet, before it is sent
::
++  spend
  |=  id=@ta
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf 0 /pay id))
  ?~  g=(mole |.(;;([%1 pay] (need n))))  (refuse 404 'no such payment')
  =/  p=pay  +.u.g
  ?.  ?=(%melting -.step.p)  (refuse 400 'no withdrawal under way')
  ;<  ok=?  bind:m  (wallet-change name.p mint.p proofs.step.p &)
  ?.  ok  (refuse 500 'unreadable: wallet')
  (pure:m ~)
::  +wallet-change: proofs into a board's wallet (by secret, so twice is
::  once), or out of it. Every version is kept (gain): the record of each
::  payment in and out. A wallet that won't read is never written over:
::  | then, and the payment waits.
::
++  wallet-change
  |=  [name=board-name mint=@t ps=(list cashu-proof) take=?]
  =/  m  (fiber:fiber:nexus ,?)
  ^-  form:m
  ?:  =(~ ps)  (pure:m &)
  ;<  w=(each (map @t (list cashu-proof)) @t)  bind:m  (read-wallet 0 name)
  ?:  ?=(%| -.w)  (pure:m |)
  =/  old=(list cashu-proof)  (~(gut by p.w) mint ~)
  =/  these=(set @t)  (silt (turn ps |=(c=cashu-proof secret.c)))
  =/  rest  (skip old |=(c=cashu-proof (~(has in these) secret.c)))
  =/  new=(list cashu-proof)  ?:(take rest (weld rest ps))
  ?:  =(new old)  (pure:m &)
  ;<  ~  bind:m  (over-gained (rf 0 /wallets name) [[/ %noun] [%1 (~(put by p.w) mint new)]])
  (pure:m &)
::
++  over-gained
  |=  [=road:tarball =bask:tarball]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  =wire  bind:m  (nonce:io /make)
  ;<  ~  bind:m  (send-dart:io %node wire road %make %.y %.y |+[bask ~])
  (take-made:io wire)
::
++  sats  |=(ps=(list cashu-proof) ^-(@ud (roll (turn ps |=(c=cashu-proof amount.c)) add)))
::  ==  paying another ship's board
::
::  /payments holds each payment this ship made, under the nonce it gave
::  it, as its host last told of it. A week on, it is dropped.
::
+$  payment  [host=@p name=board-name at=@da view=pay-view]
::
++  paying
  |=  [host=@p name=board-name nonce=@t ln=?]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  ;<  ps=(map @t payment)  bind:m  (read-payments 0)
  =/  kept  (malt (skim ~(tap by ps) |=([@t e=payment] (gth (add at.e ~d7) now))))
  (over:io (rf 0 / %payments) [[/ %noun] [%1 (~(put by kept) nonce [host name now %asked ln])]])
::  +take-pay: a host's word on a payment we made to it
::
++  take-pay
  |=  [src=@p name=board-name nonce=@t view=pay-view]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  ps=(map @t payment)  bind:m  (read-payments 0)
  ?~  e=(~(get by ps) nonce)  (pure:m ~)
  ?.  &(=(src host.u.e) =(name name.u.e))  (pure:m ~)
  (over:io (rf 0 / %payments) [[/ %noun] [%1 (~(put by ps) nonce u.e(view view))]])
::  ==  the payment fiber
::
++  run-pay
  |=  id=@ta
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  n=*  bind:m  (get-state-as:io ,*)
  ?~  g=(mole |.(;;([%1 pay] n)))
    (alarm 1 %payment 3 (say-payment id) ~)
  (pay-step id +.u.g 0)
::  +pay-go: a payment on to its next step, kept first
::
++  pay-go
  |=  [id=@ta p=pay]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  ~  bind:m  (replace:io [%1 p])
  (pay-step id p 0)
::  +pay-retry: a mint that didn't answer is asked again after fifteen
::  seconds, then twice as long each time, up to ten minutes. Before
::  anything is paid or sent it gives up after a hundred tries; with an
::  invoice out, or outputs out for signing, after about a week; a melt
::  never, since until the mint says, its proofs may be spent.
::
++  pay-retry
  |=  [id=@ta p=pay tries=@ud]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  most=@ud  ?+(-.step.p 100 ?(%invoice %swapping %minting) 1.000, %melting 0)
  ?:  &(!=(0 most) (gte tries most))
    (pay-go id p(step [%failed 'the mint did not answer' ~]))
  ;<  ~  bind:m  (sleep:io (min ~m10 (mul ~s15 (bex (min tries 6)))))
  (pay-step id p +(tries))
::  +pay-step: what a payment does from the step it is on
::
++  pay-step
  |=  [id=@ta p=pay tries=@ud]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =*  s  step.p
  ?-    -.s
      ?(%done %failed)  (pay-settle id)
  ::  ecash in hand: our outputs for all of it less the mint's fee
      %swap
    ;<  k=(unit mint-keys)  bind:m  (read-keys mint.p)
    ?~  k  (pay-retry id p tries)
    ?~  i=(inputs-sum:ca inputs.s)  (pay-go id p(step [%failed 'that is not a cashu token' ~]))
    =/  fee=@ud  (input-fee:ca ks.u.k ids.u.i)
    ?:  (lte total.u.i fee)  (pay-go id p(step [%failed 'the token is worth no more than the mint fee' ~]))
    ;<  eny=@uvJ  bind:m  get-entropy:io
    =/  outs  (new-outs:ca (split-amount:ca (sub total.u.i fee)) kid.u.k eny)
    (pay-go id p(step [%swapping inputs.s keys.u.k outs]))
  ::
      %swapping
    %:  pay-sign  id  p  tries  keys.s  outs.s  "/v1/swap"
      (build-swap-request:ca inputs.s (out-reqs:ca outs.s))
    ==
  ::  an invoice asked for: the mint's quote, whose invoice the payer pays
      %quote
    ;<  a=(unit [code=@ud jon=json])  bind:m
      %:  mint-call  mint.p  "/v1/mint/quote/bolt11"
        `(build-mint-quote-request:ca price.p 'sat')
        |=(j=json (is-new-quote:ca j ~))
      ==
    ?~  a  (pay-retry id p tries)
    ?~  q=(parse-mint-quote:ca jon.u.a)  (pay-go id p(step [%failed (mint-why jon.u.a) ~]))
    ;<  now=@da  bind:m  get-time:io
    =/  exp=@da  ?:(=(0 expiry.u.q) (add now ~h1) (from-unix:chrono:userlib expiry.u.q))
    (pay-go id p(step [%invoice quote.u.q request.u.q exp]))
  ::  the invoice with the payer (told again after a restart), and the
  ::  mint asked every five seconds until it is paid or runs out
      %invoice
    ;<  ~  bind:m  (deliver 1 who.p [%pay name.p nonce.p %invoice bolt11.s price.p expiry.s])
    |-
    ;<  a=(unit [code=@ud jon=json])  bind:m
      (mint-call mint.p "/v1/mint/quote/bolt11/{(trip quote.s)}" ~ |=(j=json (is-quote:ca j quote.s)))
    =/  q  ?~(a ~ (parse-mint-quote:ca jon.u.a))
    ?:  ?=([~ * * %'PAID' *] q)
      ;<  k=(unit mint-keys)  bind:m  (read-keys mint.p)
      ?~  k  (pay-retry id p tries)
      ;<  eny=@uvJ  bind:m  get-entropy:io
      =/  outs  (new-outs:ca (split-amount:ca price.p) kid.u.k eny)
      (pay-go id p(step [%minting quote.s keys.u.k outs]))
    ?:  ?=([~ * * %'ISSUED' *] q)  (pay-go id p(step [%failed 'the mint issued it already' ~]))
    ;<  now=@da  bind:m  get-time:io
    ?:  (gth now expiry.s)  (pay-go id p(step [%failed 'the invoice ran out unpaid' ~]))
    ;<  ~  bind:m  (sleep:io ~s5)
    $
  ::
      %minting
    %:  pay-sign  id  p  tries  keys.s  outs.s  "/v1/mint/bolt11"
      (build-mint-request:ca quote.s (out-reqs:ca outs.s))
    ==
  ::  a withdrawal: the mint's quote for the invoice, then proofs enough
  ::  for it, its fee reserve and the fee for spending them, and blank
  ::  outputs for the change (NUT-08)
      %melt
    ;<  k=(unit mint-keys)  bind:m  (read-keys mint.p)
    ?~  k  (pay-retry id p tries)
    ;<  a=(unit [code=@ud jon=json])  bind:m
      %:  mint-call  mint.p  "/v1/melt/quote/bolt11"
        `(build-melt-quote-request:ca invoice.s 'sat')
        |=(j=json (is-new-quote:ca j `invoice.s))
      ==
    ?~  a  (pay-retry id p tries)
    ?~  q=(parse-melt-quote:ca jon.u.a)  (pay-go id p(step [%failed (mint-why jon.u.a) ~]))
    ;<  w=(each (map @t (list cashu-proof)) @t)  bind:m  (read-wallet 1 name.p)
    =/  have=(list cashu-proof)  ?:(?=(%| -.w) ~ (~(gut by p.w) mint.p ~))
    ?~  sel=(select-proofs:ca have (add amount.u.q fee-reserve.u.q) ks.u.k)
      (pay-go id p(step [%failed 'the wallet holds too little for that invoice and its fees' ~]))
    ;<  eny=@uvJ  bind:m  get-entropy:io
    =/  outs  (new-outs:ca (reap (blank-count:ca (sub (sats u.sel) amount.u.q)) 1) kid.u.k eny)
    (pay-go id p(step [%melting quote.u.q u.sel keys.u.k outs]))
  ::  the melt: its proofs out of the wallet (again after a restart; it
  ::  changes nothing then), and what the mint says of them decides. All
  ::  unspent, it is sent; pending, it is waited on; spent, it was paid.
      %melting
    ;<  res=(unit deny)  bind:m  (ask [%spend id])
    ?^  res  (pay-retry id p tries)
    ;<  v=(unit @t)  bind:m  (melt-state mint.p proofs.s)
    ?~  v  (pay-retry id p tries)
    ?:  =('SPENT' u.v)  (melt-paid id p tries ~)
    ?:  =('PENDING' u.v)  (melt-wait id p)
    ;<  a=(unit [code=@ud jon=json])  bind:m
      %:  mint-call  mint.p  "/v1/melt/bolt11"
        `(build-melt-request:ca quote.s proofs.s (out-reqs:ca outs.s))
        |=(j=json (is-quote:ca j quote.s))
      ==
    ?~  a  (pay-retry id p tries)
    =/  r  (parse-melt-response:ca jon.u.a)
    ?:  ?=([~ * %&] r)  (melt-paid id p tries `jon.u.a)
    ?:  ?=([~ %'PENDING' *] r)  (melt-wait id p)
    ;<  v=(unit @t)  bind:m  (melt-state mint.p proofs.s)
    ?~  v  (pay-retry id p tries)
    ?:  =('SPENT' u.v)  (melt-paid id p tries ~)
    ?:  =('PENDING' u.v)  (melt-wait id p)
    (pay-go id p(step [%failed (mint-why jon.u.a) proofs.s]))
  ==
::  +pay-sign: our outputs for the mint to sign, by a swap or a mint.
::  What it signed before a restart is restored rather than asked for
::  twice; refused, what it signed is still ours, and only nothing is a
::  failure.
::
++  pay-sign
  |=  [id=@ta p=pay tries=@ud keys=(map @ud @t) outs=(list out:ca) url=tape body=json]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  r=(unit (list cashu-proof))  bind:m  (restore mint.p outs keys)
  ?~  r  (pay-retry id p tries)
  ?^  u.r  (pay-go id p(step [%done u.r]))
  ;<  a=(unit [code=@ud jon=json])  bind:m
    (mint-call mint.p url `body |=(j=json (is-sigs:ca j (lent outs))))
  ?~  a  (pay-retry id p tries)
  =/  got=(list cashu-proof)  (outs-proofs:ca outs (parse-swap-response:ca jon.u.a) keys)
  ?:  &(=(200 code.u.a) =((lent got) (lent outs)))
    (pay-go id p(step [%done got]))
  ;<  r=(unit (list cashu-proof))  bind:m  (restore mint.p outs keys)
  ?~  r  (pay-retry id p tries)
  ?^  u.r  (pay-go id p(step [%done u.r]))
  (pay-go id p(step [%failed (mint-why jon.u.a) ~]))
::  +melt-paid: a melt the mint paid. Its change is on our blank outputs,
::  in its answer or, without one, restored.
::
++  melt-paid
  |=  [id=@ta p=pay tries=@ud jon=(unit json)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?>  ?=(%melting -.step.p)
  =*  s  step.p
  =/  got=(list cashu-proof)
    ?~(jon ~ (outs-proofs:ca outs.s (parse-melt-change:ca u.jon) keys.s))
  ?^  got  (pay-go id p(step [%done got]))
  ;<  r=(unit (list cashu-proof))  bind:m  (restore mint.p outs.s keys.s)
  ?~  r  (pay-retry id p tries)
  (pay-go id p(step [%done u.r]))
::  +melt-wait: a melt the mint holds pending, asked after every ten
::  seconds for five minutes, then every minute, until it is paid or
::  unpaid. Unpaid, its proofs come back when the mint says they are
::  unspent.
::
++  melt-wait
  |=  [id=@ta p=pay]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?>  ?=(%melting -.step.p)
  =*  s  step.p
  =|  n=@ud
  |-
  ;<  ~  bind:m  (sleep:io ?:((lth n 30) ~s10 ~m1))
  ;<  a=(unit [code=@ud jon=json])  bind:m
    (mint-call mint.p "/v1/melt/quote/bolt11/{(trip quote.s)}" ~ |=(j=json (is-quote:ca j quote.s)))
  =/  r  ?~(a ~ (parse-melt-response:ca jon.u.a))
  ?:  &(?=([~ * %&] r) ?=(^ a))  (melt-paid id p 0 `jon.u.a)
  ?.  ?=([~ %'UNPAID' *] r)  $(n +(n))
  ;<  v=(unit @t)  bind:m  (melt-state mint.p proofs.s)
  ?:  =(`'UNSPENT' v)  (pay-go id p(step [%failed 'the Lightning payment failed' proofs.s]))
  ?:  =(`'SPENT' v)  (melt-paid id p 0 ~)
  $(n +(n))
::  +pay-settle: a finished payment handed to the writer, which culls its
::  grub and so ends this fiber. Refused (the writer waits after a crash,
::  or can't read the wallet), it is handed over again later.
::
++  pay-settle
  |=  id=@ta
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  res=(unit deny)  bind:m  (ask [%settle id])
  ;<  ~  bind:m  (sleep:io ?:(?=([~ %503 *] res) ~m1 ~m10))
  (pay-settle id)
::  ==  talking to a mint
::
+$  mint-keys  [ks=(list keyset:ca) kid=@t keys=(map @ud @t)]
::  +read-keys: a mint's keysets, and the one it signs new sat outputs
::  under, with its keys
::
++  read-keys
  |=  mint=@t
  =/  m  (fiber:fiber:nexus ,(unit mint-keys))
  ^-  form:m
  ;<  a=(unit [code=@ud jon=json])  bind:m  (mint-call mint "/v1/keysets" ~ is-keysets:ca)
  =/  ks=(list keyset:ca)  ?~(a ~ (parse-keysets:ca jon.u.a))
  ?~  act=(active-sat:ca ks)  (pure:m ~)
  ;<  b=(unit [code=@ud jon=json])  bind:m
    (mint-call mint "/v1/keys/{(trip id.u.act)}" ~ |=(j=json (is-keys:ca j id.u.act)))
  ?~  b  (pure:m ~)
  ?~  keys=(parse-keys:ca jon.u.b)  (pure:m ~)
  (pure:m `[ks id.u.act u.keys])
::  +restore: the proofs a mint's record of our outputs makes (NUT-09):
::  ~ when it didn't answer; none when it signed none of them, or keeps
::  no such record
::
++  restore
  |=  [mint=@t outs=(list out:ca) keys=(map @ud @t)]
  =/  m  (fiber:fiber:nexus ,(unit (list cashu-proof)))
  ^-  form:m
  ;<  a=(unit [code=@ud jon=json])  bind:m
    %:  mint-call  mint  "/v1/restore"
      `(build-restore-request:ca (out-reqs:ca outs))
      |=(j=json (is-restore:ca j outs))
    ==
  ?~  a  (pure:m ~)
  (pure:m `(restored-proofs:ca outs (fall (parse-restore:ca jon.u.a) ~) keys))
::  +melt-state: what a mint says of a melt's proofs (NUT-07), ~ when it
::  doesn't say of all of them
::
++  melt-state
  |=  [mint=@t ps=(list cashu-proof)]
  =/  m  (fiber:fiber:nexus ,(unit @t))
  ^-  form:m
  =/  ys=(list @t)  (turn ps |=(c=cashu-proof (proof-y:ca secret.c)))
  ;<  a=(unit [code=@ud jon=json])  bind:m
    %:  mint-call  mint  "/v1/checkstate"
      `(build-checkstate-request:ca ys)
      |=(j=json (is-states:ca j (silt ys)))
    ==
  ?~  a  (pure:m ~)
  ?~  st=(parse-checkstate:ca jon.u.a)  (pure:m ~)
  (pure:m (verdict:ca u.st (lent ps)))
::  +mint-why: what a mint said of a refusal, for whoever reads it
::
++  mint-why
  |=  jon=json
  ^-  @t
  =/  d  ?.(?=([%o *] jon) ~ (~(get by p.jon) 'detail'))
  ?.  ?=([~ %s *] d)  'the mint refused it'
  (crip (scag 200 (trip p.u.d)))
::  +mint-call: one request to a mint: its status and json (null when
::  the body isn't json), or ~ when it didn't answer in a minute or we
::  may not reach it. Answers come back by fiber, not by request, so an
::  answer to an earlier one (sent before a restart, or given up on) may
::  come first: a success is taken only when it names what we asked
::  (want), and a failure, which names nothing, as it comes. Every step
::  checks what the mint did before it concludes a failure.
::
++  mint-call
  |=  [mint=@t pax=tape body=(unit json) want=$-(json ?)]
  =/  m  (fiber:fiber:nexus ,(unit [code=@ud jon=json]))
  ^-  form:m
  =/  url=@t  (crip (weld (clean-mint-url:ca mint) pax))
  =/  =request:http
    ?~  body  [%'GET' url ~ ~]
    [%'POST' url ~[['content-type' 'application/json']] `(as-octs:mimes:html (en:json:html u.body))]
  ;<  err=(unit ?(%ours %theirs))  bind:m
    (poke-ours &+&+[/sys/iris %'main.iris-state'] [[/ %iris-request] request])
  ?:  ?=([~ %ours] err)
    ;<  ~  bind:m  (alarm-ungranted 1 %iris 'poke' '/sys/iris/' say-iris)
    (pure:m ~)
  ?^  err  (pure:m ~)
  ((with-timeout:io ,[code=@ud jon=json]) /mint ~m1 (take-response want))
::  +take-response: the answer to our request; a chunk of one, a cancel
::  (it names no request) or another request's answer is let go
::
++  take-response
  |=  want=$-(json ?)
  =/  m  (fiber:fiber:nexus ,[code=@ud jon=json])
  ^-  form:m
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %poke * *]
    ?.  =([/ %http-response] p.sage.u.in)  [%skip ~]
    =/  r  (mole |.(!<(client-response:iris q.sage.u.in)))
    ?.  ?=([~ %finished *] r)  [%wait ~]
    =/  code=@ud  status-code.response-header.u.r
    =/  jon=json  ?~(full-file.u.r ~ (fall (de:json:html q.data.u.full-file.u.r) ~))
    ?:  &((gte code 200) (lth code 300) !(want jon))  [%wait ~]
    [%done code jon]
  ==
::  ==  who may read what
::
::  +public-roads: what every ship may read of the boards we host
::  (+open-paths), as roads
::
++  public-roads
  |=  names=(list @ta)
  =/  m  (fiber:fiber:nexus ,(list road:tarball))
  ^-  form:m
  =|  boards=(list [@ta ?])
  |-  ^-  form:m
  ?~  names  (pure:m (turn (open-paths:fr boards) |=(p=path (rv 0 p))))
  ;<  a=(unit board)  bind:m  (read-access i.names)
  ::  a board whose card won't read counts as paid: closed, not open
  $(names t.names, boards [[i.names |(?=(~ a) ?=(^ payment.u.a))] boards])
::  +sync-access: after an action that may change who reads what. A board
::  made or gone, or turned paid or free, changes the public set; any of
::  them may change a paid board's group.
::
++  sync-access
  |=  [name=board-name old=(unit board) new=(unit board)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  was=?  ?~(old | ?=(^ payment.u.old))
  =/  is=?  ?~(new | ?=(^ payment.u.new))
  ;<  ~  bind:m  ?.(&(was !is) (pure:m ~) (drop-group name))
  ;<  ~  bind:m
    ?:  &(=(was is) =(?=(~ old) ?=(~ new)))  (pure:m ~)
    grant-public
  sweep-all
::  +sweep-all: every paid board's group made to hold its moderators and
::  the members whose time hasn't run out, and when the next one will;
::  run at each rise (a registrant's grants don't outlive it), after an
::  action that changes who may read, and when a member runs out
::
++  sweep-all
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  ;<  names=(list @ta)  bind:m  (board-names 0)
  =|  next=(unit @da)
  |-  ^-  form:m
  ?~  names  (over:io (rf 0 / %sweep) [[/ %noun] [%1 next]])
  ;<  a=(unit board)  bind:m  (read-access i.names)
  ?.  &(?=(^ a) ?=(^ payment.u.a))  $(names t.names)
  ;<  ~  bind:m  (set-group i.names (group-ships:fr u.a now))
  =/  n=(unit @da)  (next-expiry:fr u.a now)
  $(names t.names, next ?~(n next ?~(next n `(min u.n u.next))))
::  +read-access: what decides who reads a board: its price, its roles
::  and its members; ~ without a card or with members that won't read
::
++  read-access
  |=  name=@ta
  =/  m  (fiber:fiber:nexus ,(unit board))
  ^-  form:m
  ;<  c=(unit *)  bind:m  (read-noun (rf 0 /boards/[name]/pub %card))
  ;<  r=(unit *)  bind:m  (read-noun (rf 0 /boards/[name]/pub %roles))
  ;<  mem=(each (map @p @da) @t)  bind:m  (read-members 0 name)
  ?~  c  (pure:m ~)
  ?:  ?=(%| -.mem)  (pure:m ~)
  =|  b=board
  %-  pure:m
  :-  ~
  %=  b
    payment  (fall (mole |.(+>:;;([%2 board-info (unit payment-config)] u.c))) ~)
    roles    (fall (mole |.(+:;;([%1 (map @p role)] (need r)))) ~)
    paid     p.mem
  ==
::  +read-members: who paid for a board, until when; none when there is
::  no record, and why when the record won't read
::
++  read-members
  |=  [up=@ud name=@ta]
  =/  m  (fiber:fiber:nexus ,(each (map @p @da) @t))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up /members name))
  ?~  n  (pure:m &+~)
  ?~  v=(mole |.(+:;;([%1 (map @p @da)] u.n)))  (pure:m |+'unreadable: members')
  (pure:m &+u.v)
::
++  store-members
  |=  [name=board-name old=(map @p @da) new=(unit board)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?~  new
    ;<  *  bind:m  (cull-soft:io (rf 0 /members name))
    (pure:m ~)
  ?:  =(old paid.u.new)  (pure:m ~)
  (over:io (rf 0 /members name) [[/ %noun] [%1 paid.u.new]])
::  +set-group: a paid board's usergroup: its ships written, then its
::  weir sent through the registry, which recomputes every peer's weir
::  at once (a written group waits for each peer's next contact). A ship
::  that refused the usergroup road keeps paid boards closed.
::
++  grp  |=(name=@ta ^-(@ta (crip "furum-{(trip name)}")))
++  grp-dir  |=(name=@ta ^-(path /sys/ames/usergroups/(crip "{(trip (grp name))}.grp")))
::
++  set-group
  |=  [name=@ta ships=(set @p)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  gdir=path  (grp-dir name)
  ;<  *  bind:m  (write-soft [%& %| gdir] &+empty-dir:loader |)
  ;<  ok=?  bind:m  (write-soft [%& %& gdir %'who.ships'] |+[[[/ %ships] ships] ~] &)
  ?.  ok  (alarm-ungranted 0 %groups 'make' '/sys/ames/usergroups/' say-groups)
  ;<  how=(unit tang)  bind:m
    (reg-how-soft:io /[(grp name)] [~ ~ (sy ~[(rv 0 /boards/[name]/content)])])
  ?~  how  (pure:m ~)
  (alarm-ungranted 0 %groups 'poke' '/sys/ames/registry' say-groups)
::  +drop-group: a board no longer paid, or gone: its grant taken back,
::  then its group
::
++  drop-group
  |=  name=@ta
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  *  bind:m  (reg-how-soft:io /[(grp name)] [~ ~ ~])
  ;<  *  bind:m  (cull-soft:io [%& %| (grp-dir name)])
  (pure:m ~)
::  +write-soft: a make that answers | when refused, where make-soft:io
::  fails the fiber on a veto
::
++  write-soft
  |=  [=road:tarball =make:nexus force=?]
  =/  m  (fiber:fiber:nexus ,?)
  ^-  form:m
  ;<  =wire  bind:m  (nonce:io /make)
  ;<  ~  bind:m  (send-dart:io %node wire road %make force %.n make)
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %veto *]  [%done |]
      [~ %made * *]
    ?.  =(wire wire.u.in)  [%skip ~]
    [%done =(~ err.u.in)]
  ==
::  ==  the sweeper
::
::  It keeps /sweep, which the writer rewrites with the next time a
::  member runs out, sleeps until then, and asks the writer to sweep. A
::  writer that won't take the ask (waiting after a crash) is asked again
::  in a minute, never at once.
::
++  sweeper
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf 0 / %sweep))
  =/  next=(unit @da)  (fall (mole |.(+:;;([%1 (unit @da)] (need n)))) ~)
  ;<  now=@da  bind:m  get-time:io
  ?:  &(?=(^ next) (lte u.next now))
    ;<  err=(unit tang)  bind:m  (poke-soft:io (rf 0 / %'main.sig') [[/furum %ask] `op`[%sweep ~]])
    ?^  err
      ;<  ~  bind:m  (sleep:io ~m1)
      sweeper
    ;<  *  bind:m  ((with-timeout:io (unit deny)) /sa ~m1 take-done)
    sweeper
  ;<  ~  bind:m  ?~(next (pure:m ~) (set-timer:io /sw u.next))
  ;<  ~  bind:m  take-sweep
  ;<  ~  bind:m  ?~(next (pure:m ~) (cancel-timer:io /sw))
  sweeper
::  +take-sweep: /sweep changed, or its time came
::
++  take-sweep
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %news * *]
    ?.  =(/s wire.u.in)  [%skip ~]
    [%done ~]
      [~ %poke * *]
    ?.  =([/ %timer-wake] p.sage.u.in)  [%skip ~]
    ?.  =(/sw (fall (mole |.(!<(path q.sage.u.in))) /))  [%skip ~]
    [%done ~]
  ==
::  ==  reading the tree; `up` is the reader's depth below the nexus root
::
::  +read-grubs: a board directory's grubs by path, ~ when there is none
::
++  read-grubs
  |=  [up=@ud name=board-name]
  (read-dir up /boards/[name])
::
++  read-dir
  |=  [up=@ud dir=path]
  =/  m  (fiber:fiber:nexus ,(map path *))
  ^-  form:m
  ;<  vw=view:nexus  bind:m  (peek:io (rv up dir) ~)
  ?.  ?=(%ball -.vw)  (pure:m ~)
  (pure:m (ball-grubs ball.vw))
::
++  ball-grubs
  |=  b=ball:tarball
  ^-  (map path *)
  %-  ~(gas by *(map path *))
  %+  turn  ~(tap ba:tarball b)
  |=  [=rail:tarball =sang:tarball]
  [(snoc path.rail name.rail) (sang-noun:tarball sang)]
::  +board-names: the boards this ship hosts
::
++  board-names
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,(list @ta))
  ^-  form:m
  ;<  vw=view:nexus  bind:m  (peek-shallow:io (rv up /boards) ~)
  ?.  ?=(%ball -.vw)  (pure:m ~)
  (pure:m ~(tap in ~(key by dir.ball.vw)))
::  +read-noun: a grub's noun, ~ when absent; the reader clams it
::
++  read-noun
  |=  =road:tarball
  =/  m  (fiber:fiber:nexus ,(unit *))
  ^-  form:m
  ;<  vw=(unit view:nexus)  bind:m  (peek-soft:io road ~)
  ?.  ?=([~ %file *] vw)  (pure:m ~)
  (pure:m `(sang-noun:tarball sang.u.vw))
::
::  +read-prefs: the owner's preferences. An earlier release's dark-mode
::  flag carries over as the mode: dark, or else the device's.
::
++  read-prefs
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,prefs)
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up / %prefs))
  ?~  n  (pure:m default-prefs)
  ?^  p=(mole |.(+:;;([%4 prefs] u.n)))  (pure:m u.p)
  ::  %3: furum's own themes had five colours and no +more
  ?^  q=(mole |.(+:;;([%3 prefs-3] u.n)))
    =*  o  looks.u.q
    (pure:m [[mode.o talon.o [(turn list.own.o widen:th) active.own.o] accent.o] tags.u.q registry.u.q])
  =/  dp=prefs  default-prefs
  =/  was  |=(d=? dp(mode.looks ?:(d %dark %system)))
  ?^  o=(mole |.(+:;;([%2 dark=? tags=(set term) registry=@p] u.n)))
    =/  p=prefs  (was dark.u.o)
    (pure:m p(tags tags.u.o, registry registry.u.o))
  ?^  d=(mole |.(+:;;([%1 ?] u.n)))  (pure:m (was u.d))
  (pure:m default-prefs)
::  +read-look: what a page draws with. When talon's theme settings rule
::  and talon has saved some, its themes and accent; else furum's own.
::  The mode is always furum's: talon keeps its own per device.
::
++  read-look
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,look:th)
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs up)
  =*  l  looks.pf
  ;<  tal=(unit [themes:th accent:th])  bind:m
    ?.  talon.l  (pure:(fiber:fiber:nexus ,(unit [themes:th accent:th])) ~)
    talon-settings
  =/  [ts=themes:th ac=accent:th]  (fall tal [own.l accent.l])
  ;<  pro=(unit @ux)  bind:m
    ?.  &(=(`& on.ac) ?=(%profile how.ac))  (pure:(fiber:fiber:nexus ,(unit @ux)) ~)
    profile-color
  (pure:m (draw:th mode.l (active:th ts) (accent-color:th ac pro)))
::  a page drawn before any preference is read (a guest's refusal)
++  plain-look  (draw:th %system ~ ~)
::  +talon-settings: talon's saved themes and accent, from %settings
::  (desk talon, bucket ui-prefs, each entry a JSON cord); ~ when
::  %settings doesn't run here, or holds neither
::
++  talon-settings
  =/  m  (fiber:fiber:nexus ,(unit [themes:th accent:th]))
  ^-  form:m
  ;<  up=(unit vase)  bind:m  (scry %noun ~[%gu %settings %$])
  ?.  (running up)  (pure:m ~)
  ;<  t=(unit @t)  bind:m  (talon-entry 'themes')
  ;<  a=(unit @t)  bind:m  (talon-entry 'accent')
  =/  ts=(unit themes:th)  ?~(t ~ (talon-themes:th u.t))
  =/  ac=(unit accent:th)  ?~(a ~ (talon-accent:th u.a))
  ?:  &(?=(~ ts) ?=(~ ac))  (pure:m ~)
  (pure:m `[(fall ts [~ ~]) (fall ac [~ %profile ~])])
::
++  talon-entry
  |=  key=@t
  =/  m  (fiber:fiber:nexus ,(unit @t))
  ^-  form:m
  =/  at=path  /talon/'ui-prefs'/[key]/noun
  ;<  has=(unit vase)  bind:m  (scry %noun (weld /gx/settings/'has-entry' at))
  ?.  (running has)  (pure:m ~)
  ;<  e=(unit vase)  bind:m  (scry %noun (weld /gx/settings/entry at))
  ?~  e  (pure:m ~)
  (pure:m (bind (mole |.(;;([%entry %s @t] q.u.e))) |=([* * t=@t] t)))
::  +profile-color: the colour on our %contacts profile, when %contacts
::  runs here and has one
::
++  profile-color
  =/  m  (fiber:fiber:nexus ,(unit @ux))
  ^-  form:m
  ;<  up=(unit vase)  bind:m  (scry %noun ~[%gu %contacts %$])
  ?.  (running up)  (pure:m ~)
  ;<  j=(unit vase)  bind:m  (scry %json /gx/contacts/v1/self/json)
  ?~  j  (pure:m ~)
  (pure:m (biff (mole |.(!<(json u.j))) profile-color:th))
::
++  running  |=(u=(unit vase) =([~ &] (bind u |=(v=vase q.v))))
::  +scry: a scry of this ship's agents through /sys/scry, its answer
::  under a mark we keep; ~ when the road is refused. Ask only for what
::  the agent surely answers (hence %gu and has-entry first): the
::  service catches no failure, and a failed scry takes the whole event
::  down, the page request with it.
::  ponytail: %contacts' /v1/self is taken on trust; a %contacts without
::  it fails the page for an accent set to the profile colour
::
++  scry
  |=  [mark=@tas pax=path]
  =/  m  (fiber:fiber:nexus ,(unit vase))
  ^-  form:m
  ;<  err=(unit tang)  bind:m
    (poke-soft:io &+&+[/sys/scry %'main.sig'] [[/ %scry-request] [mark pax]])
  ?^  err  (pure:m ~)
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %poke * *]
    ?.  =([/ mark] p.sage.u.in)  [%skip ~]
    [%done `q.sage.u.in]
  ==
::
++  read-notes
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,(list notification))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up / %notes))
  (pure:m (fall (mole |.(+:;;([%1 (list notification)] (need n)))) ~))
::
++  read-feed
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,(set [@p board-name]))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up / %feed))
  (pure:m (fall (mole |.(+:;;([%1 (set [@p board-name])] (need n)))) ~))
::
++  read-seen
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,seen)
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up / %seen))
  (pure:m (fall (mole |.(+:;;([%1 seen] (need n)))) *seen))
::
++  read-limits
  =/  m  (fiber:fiber:nexus ,limits)
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf 0 / %limits))
  (pure:m (fall (mole |.(+:;;([%1 limits] (need n)))) ~))
::  +read-wallet: a board's ecash by mint; none when there is no wallet,
::  and why when it won't read
::
++  read-wallet
  |=  [up=@ud name=@ta]
  =/  m  (fiber:fiber:nexus ,(each (map @t (list cashu-proof)) @t))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up /wallets name))
  ?~  n  (pure:m &+~)
  ?~  v=(mole |.(+:;;([%1 (map @t (list cashu-proof))] u.n)))  (pure:m |+'unreadable: wallet')
  (pure:m &+u.v)
::  +read-pays: the payments under way; one that won't read is left out
::
++  read-pays
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,(list pay))
  ^-  form:m
  ;<  gs=(map path *)  bind:m  (read-dir up /pay)
  (pure:m (murn ~(val by gs) |=(n=* (bind (mole |.(;;([%1 pay] n))) tail))))
::
++  read-payments
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,(map @t payment))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up / %payments))
  (pure:m (fall (mole |.(+:;;([%1 (map @t payment)] (need n)))) ~))
::  +read-json: a grub as json, ~ when absent or unreadable
::
++  read-json
  |=  =road:tarball
  =/  m  (fiber:fiber:nexus ,json)
  ^-  form:m
  ;<  vw=(unit view:nexus)  bind:m  (peek-soft:io road ~)
  ?.  ?=([~ %file *] vw)  (pure:m ~)
  (pure:m (fall (mole |.(;;(json (sang-noun:tarball sang.u.vw)))) ~))
::  ==  other ships
::
::  where furum is installed when nothing says otherwise: a desk install
::
++  standard-install  `path`/apps/'shell.shell'/desks/'furum.desk'/desk/data/'furum.furum_app'
::  +remote: a path under another ship's furum
::
++  remote
  |=  [host=@p base=path pax=path]
  ^-  path
  :(weld /sys/ames/ships/(scot %p host)/root base pax)
::  +install-of: where `host` keeps furum, as the directory says; the
::  standard desk path when it doesn't
::
++  install-of
  |=  [up=@ud host=@p]
  =/  m  (fiber:fiber:nexus ,path)
  ^-  form:m
  ;<  st=registry-store  bind:m  (read-directory up)
  (pure:m (~(gut by hosts.st) host standard-install))
::  +read-directory: the directory as this ship knows it: its own when it
::  keeps the registry, else its copy of the registry's
::
++  read-directory
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,registry-store)
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ;<  pf=prefs  bind:m  (read-prefs up)
  (read-store (rf up / ?:(=(our registry.pf) %registry %directory)))
::
++  read-store
  |=  =road:tarball
  =/  m  (fiber:fiber:nexus ,registry-store)
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun road)
  (pure:m (fall (mole |.(+:;;([%1 registry-store] (need n)))) *registry-store))
::  +read-here: this install's own path, from the grant the shell wrote
::  on approval; the standard one before
::
++  read-here
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,path)
  ^-  form:m
  ;<  j=json  bind:m  (read-json (rf up / %'grant.json'))
  =/  h=(unit path)
    ?.  ?=([%o *] j)  ~
    =/  v  (~(get by p.j) 'here')
    ?.  ?=([~ %s *] v)  ~
    (rush p.u.v stap)
  (pure:m (fall h standard-install))
::  +wave-files: a kept directory's version map, flat: each file's path
::  under it and its version
::
++  wave-files
  |=  [pre=path w=wave:nexus]
  ^-  (map path cass:clay)
  =/  here=(map path cass:clay)
    ?~  fil.w  ~
    (malt (turn ~(tap by file.u.fil.w) |=([n=@ta c=cass:clay] [(snoc pre n) c])))
  %+  roll  ~(tap by dir.w)
  |=  [[n=@ta k=wave:nexus] acc=_here]
  (~(uni by acc) (wave-files (snoc pre n) k))
::  ==  the follower: one per board on another ship this ship reads
::
::  It keeps the host's board and mirrors it into cache/<host>/<name>,
::  the same grubs in the same places, so a page reads a mirror with the
::  loader a hosted board uses. It alone writes its mirror.
::
::  A board is two keeps. pub/ (card, roles, conf) is anyone's; a keep
::  that fails is tried again after 1, 2, 4 and up to 60 minutes.
::  content/ is anyone's on a free board and its members' on a paid one:
::  refused, the mirror loses its content and marks the board closed to
::  us (/access), and the page shows the paywall.
::
::  Each part starts as a whole copy; then each wave brings only the
::  grubs whose version moved. Every ten minutes it copies again: a host
::  that drops a reader never says so. Content closed to us is not asked
::  for again until we may have been let in (see below).
::
+$  fev
  $%  [%news part=?(%pub %content) =wave:nexus]
      [%fell part=?(%pub %content)]
      [%wake ~]
      [%sync ~]
  ==
::
++  follow
  |=  [host=@p name=board-name tries=@ud]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  base=path  bind:m  (install-of 2 host)
  =/  there=path  (remote host base /boards/[name])
  =/  mine=path  /cache/(scot %p host)/[name]
  ::  at first contact, and once a board has been out of reach for three
  ::  hours, ask its host for pub/ itself (+ask-pub)
  ;<  have=(map path *)  bind:m  (read-dir 2 mine)
  ;<  pub=?(%open %ours %theirs %quiet)  bind:m
    ?.  |(&(=(0 tries) =(~ have)) (gte tries 8))
      (pure:(fiber:fiber:nexus ,?(%open %ours %theirs %quiet)) %open)
    (ask-pub there)
  ?:  ?=(%theirs pub)
    ;<  *  bind:m  (poke-soft:io (rf 2 / %'main.sig') [[/furum %op] `op`[%gone host name]])
    (pure:m ~)
  ;<  w=(unit wave:nexus)  bind:m  (keep-soft:io /fp [%& %| (weld there /pub)] ~ ~s30)
  ?~  w
    ;<  ~  bind:m  (sleep:io (min ~h1 (mul ~m1 (bex (min tries 6)))))
    (follow host name +(tries))
  ;<  ~  bind:m  (sync-part there mine /pub)
  ::  content we know is closed to us is not asked for: the host refuses,
  ::  and both ships' kernels print the refusal. It is asked again when
  ::  we may have been let in: the host says so (+take-note), or the
  ::  owner asks (the paid page, resubscribe): a local poke, %sync
  ;<  shut=?  bind:m  (closed mine)
  ;<  c=(unit wave:nexus)  bind:m
    ?:  shut  (pure:(fiber:fiber:nexus ,(unit wave:nexus)) ~)
    (open-content there mine)
  =/  lp=(map path cass:clay)  (wave-files /pub u.w)
  =/  lc=(map path cass:clay)  ?~(c ~ (wave-files /content u.c))
  =/  kept=?  ?=(^ c)
  |-
  ;<  now=@da  bind:m  get-time:io
  ;<  ~  bind:m  (set-timer:io /hb (add now ~m10))
  ;<  e=fev  bind:m  take-fev
  ;<  ~  bind:m  (cancel-timer:io /hb)
  ?-    -.e
      %news
    ?:  ?=(%pub part.e)
      =/  next  (wave-files /pub wave.e)
      ;<  ~  bind:m  (sync-changed there mine lp next)
      $(lp next)
    =/  next  (wave-files /content wave.e)
    ;<  ~  bind:m  (sync-changed there mine lc next)
    $(lc next)
  ::
      %fell
    ?:  ?=(%pub part.e)  (follow host name 0)
    $(kept |, lc ~)
  ::
      ?(%wake %sync)
    ;<  ~  bind:m  (sync-part there mine /pub)
    ?:  kept
      ;<  ok=?  bind:m  (read-content there mine)
      $(kept ok, lc ?:(ok lc ~))
    ?:  ?=(%wake -.e)  $
    ;<  c=(unit wave:nexus)  bind:m  (open-content there mine)
    $(kept ?=(^ c), lc ?~(c ~ (wave-files /content u.c)))
  ==
::  +ask-pub: a read of a board's pub/, which every hosted board opens
::  to every ship, and what came of it: %open; %ours, our own weir
::  refused it (a veto intake; +check-grant reports a missing road);
::  %theirs, the host's weir refused it (a %veto view), so the host has
::  no such board; %quiet, no answer. The
::  follower asks only at first contact, when we hold no copy, and once
::  a board has been out of reach for three hours: a host mid-restart
::  refuses for a moment, never for hours.
::
++  ask-pub
  |=  there=path
  =/  m  (fiber:fiber:nexus ,?(%open %ours %theirs %quiet))
  ^-  form:m
  ;<  vw=(unit (unit view:nexus))  bind:m
    ((with-timeout:io (unit view:nexus)) /nb ~s30 (peek-soft:io [%& %| (weld there /pub)] ~))
  ?~  vw  (pure:m %quiet)
  ?~  u.vw  (pure:m %ours)
  ?:  ?=([%veto *] u.u.vw)  (pure:m %theirs)
  (pure:m %open)
::  +closed: whether our copy says the board's content is closed to us
::
++  closed
  |=  mine=path
  =/  m  (fiber:fiber:nexus ,?)
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf 2 mine %access))
  (pure:m =([~ [%1 |]] n))
::  +take-fev: what a follower waits for: news or a fell on either keep,
::  its heartbeat, or a local poke asking it to look again now
::
++  take-fev
  =/  m  (fiber:fiber:nexus ,fev)
  ^-  form:m
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %news * *]
    ?:  =(/fp wire.u.in)  [%done %news %pub wave.u.in]
    ?:  =(/fc wire.u.in)  [%done %news %content wave.u.in]
    [%skip ~]
      [~ %fell *]
    ?:  =(/fp wire.u.in)  [%done %fell %pub]
    ?:  =(/fc wire.u.in)  [%done %fell %content]
    [%skip ~]
      [~ %poke * *]
    ?.  =([/ %timer-wake] p.sage.u.in)  [%done %sync ~]
    ?.  =(/hb (fall (mole |.(!<(path q.sage.u.in))) /))  [%skip ~]
    [%done %wake ~]
  ==
::  +open-content: read a board's content if we may, and keep it
::
++  open-content
  |=  [there=path mine=path]
  =/  m  (fiber:fiber:nexus ,(unit wave:nexus))
  ^-  form:m
  ;<  ok=?  bind:m  (read-content there mine)
  ?.  ok  (pure:m ~)
  (keep-soft:io /fc [%& %| (weld there /content)] ~ ~s30)
::  +read-content: a board's content copied whole, or, refused, the
::  mirror's content gone and the board marked closed to us. A host that
::  doesn't answer leaves the mirror as it was.
::
++  read-content
  |=  [there=path mine=path]
  =/  m  (fiber:fiber:nexus ,?)
  ^-  form:m
  ;<  vw=(unit (unit view:nexus))  bind:m
    ((with-timeout:io (unit view:nexus)) /c ~s60 (peek-soft:io [%& %| (weld there /content)] ~))
  ?~  vw  (pure:m |)
  ?.  ?=([~ %ball *] u.vw)
    ;<  *  bind:m  (cull-soft:io (rv 2 (weld mine /content)))
    ;<  ~  bind:m  (over:io (rf 2 mine %access) [[/ %noun] [%1 |]])
    (pure:m |)
  ;<  ~  bind:m  (mirror-part mine /content (ball-grubs ball.u.u.vw))
  ;<  ~  bind:m  (over:io (rf 2 mine %access) [[/ %noun] [%1 &]])
  (pure:m &)
::  +sync-part: one part of the board (pub/ or content/) copied whole
::
++  sync-part
  |=  [there=path mine=path part=path]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  vw=(unit (unit view:nexus))  bind:m
    ((with-timeout:io (unit view:nexus)) /all ~s60 (peek-soft:io [%& %| (weld there part)] ~))
  ?.  ?=([~ ~ %ball *] vw)  (pure:m ~)
  (mirror-part mine part (ball-grubs ball.u.u.vw))
::
++  mirror-part
  |=  [mine=path part=path got=(map path *)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  have=(map path *)  bind:m  (read-dir 2 (weld mine part))
  =/  pre  |=(g=(map path *) (malt (turn ~(tap by g) |=([p=path v=*] [(weld part p) v]))))
  (mirror mine (pre have) (pre got))
::  +sync-changed: only the grubs whose version moved, read one by one
::
++  sync-changed
  |=  [there=path mine=path last=(map path cass:clay) next=(map path cass:clay)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  moved=(list path)
    %-  content-first
    (skip ~(tap in ~(key by next)) |=(p=path =((~(get by last) p) (~(get by next) p))))
  =/  gone=(list path)
    (skip ~(tap in ~(key by last)) |=(p=path (~(has by next) p)))
  ;<  ~  bind:m
    |-  ^-  form:m
    ?~  moved  (pure:m ~)
    ;<  vw=(unit (unit view:nexus))  bind:m
      %+  (with-timeout:io (unit view:nexus))  /one
      [~s30 (peek-soft:io [%& %& (weld there (snip i.moved)) (rear i.moved)] ~)]
    ;<  ~  bind:m
      ?.  ?=([~ ~ %file *] vw)  (pure:m ~)
      %+  over:io  (rf 2 (weld mine (snip i.moved)) (rear i.moved))
      [[/ %noun] (sang-noun:tarball sang.u.u.vw)]
    $(moved t.moved)
  |-  ^-  form:m
  ?~  gone  (pure:m ~)
  ;<  *  bind:m  (cull-soft:io (rf 2 (weld mine (snip i.gone)) (rear i.gone)))
  $(gone t.gone)
::  +mirror: a mirror brought from what it holds to what the host holds
::
++  mirror
  |=  [mine=path have=(map path *) theirs=(map path *)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  put=(list path)
    (content-first (skip ~(tap in ~(key by theirs)) |=(p=path =((~(get by theirs) p) (~(get by have) p)))))
  =/  gone=(list path)
    (skip ~(tap in ~(key by have)) |=(p=path (~(has by theirs) p)))
  ;<  ~  bind:m
    |-  ^-  form:m
    ?~  put  (pure:m ~)
    ;<  ~  bind:m  (over:io (rf 2 (weld mine (snip i.put)) (rear i.put)) [[/ %noun] (~(got by theirs) i.put)])
    $(put t.put)
  |-  ^-  form:m
  ?~  gone  (pure:m ~)
  ;<  *  bind:m  (cull-soft:io (rf 2 (weld mine (snip i.gone)) (rear i.gone)))
  $(gone t.gone)
::  +content-first: a board's posts, threads and votes before its card,
::  roles and conf. A page that waits for our mirror to change (after
::  we post to another ship's board) then sees the post itself, not only
::  the counter a new post also moves.
::
++  content-first
  |=  ps=(list path)
  ^-  (list path)
  =/  c  |=(p=path ?=([%content *] p))
  (weld (skim ps c) (skip ps c))
::  ==  the directory reader: this ship's copy of the registry's
::
::  On the ship that keeps the registry it has nothing to do. Elsewhere
::  it keeps the registry's grub and copies it to /directory on each
::  change, and every hour regardless. It follows the registry pref: a
::  local poke (the admin page, after a change) makes it look again.
::  A read that fails says why at /tr/dir, for the directory page, and
::  is tried again in a minute, then two, and so on up to the hour.
::
++  read-registry
  |=  tries=@ud
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ;<  pf=prefs  bind:m  (read-prefs 0)
  ?:  =(our registry.pf)
    ;<  *  bind:m  take-poke-from:io
    (read-registry 0)
  ;<  base=path  bind:m  (install-of 0 registry.pf)
  =/  there=path  (remote registry.pf base /)
  ;<  w=(unit wave:nexus)  bind:m  (keep-soft:io /r [%& %& there %registry] ~ ~s30)
  |-
  ;<  vw=(unit (unit view:nexus))  bind:m
    ((with-timeout:io (unit view:nexus)) /reg ~s30 (peek-soft:io [%& %& there %registry] ~))
  =/  why=(unit @t)  (dir-fault vw)
  ::  said once: a registry setting that names a ship with no directory.
  ::  Our own weir refusing is +check-grant's to say; no answer, the
  ::  registry's refusal and a lost answer are for the directory page
  ;<  ~  bind:m
    ?.  &(?=(^ why) ?=([~ ~ *] vw) !?=([~ ~ ?(%veto %miss) *] vw))  (pure:m ~)
    (alarm 0 %registry 3 (say-registry registry.pf) ~)
  ;<  ~  bind:m
    ?^  why  (pure:m ~)
    ?>  ?=([~ ~ %file *] vw)
    (over:io (rf 0 / %directory) [[/ %noun] (sang-noun:tarball sang.u.u.vw)])
  ;<  now=@da  bind:m  get-time:io
  ;<  ~  bind:m  (dir-trace ?~(why ~ `[registry.pf u.why now]))
  =/  wait=@dr  ?~(why ~h1 (min ~h1 (mul ~m1 (bex (min tries 6)))))
  =/  next=@ud  ?~(why 0 +(tries))
  ;<  ~  bind:m  (set-timer:io /rh (add now wait))
  ;<  e=?(%news %again)  bind:m  take-reg
  ;<  ~  bind:m  (cancel-timer:io /rh)
  ?:  ?=(%again e)  (read-registry next)
  $(tries next)
::  +dir-fault: why a read of the registry's grub gave no directory, or ~
::  when it gave one: the registry did not answer in time; our own weir
::  refused the read (a veto intake, so peek-soft's ~); the registry's
::  weir refused it (a %veto view); the answer was lost; it has none; or
::  it keeps one this furum can't read
::
++  dir-fault
  |=  vw=(unit (unit view:nexus))
  ^-  (unit @t)
  ?~  vw  `'it did not answer in time'
  ?~  u.vw
    `'this ship does not let furum read other ships. On grubbery\'s permissions page, allow furum /sys/ames/ships/ under "may read"'
  ?:  ?=([%veto *] u.u.vw)  `'it refused to let this ship read it'
  ?:  ?=([%miss *] u.u.vw)  `'the answer was lost on the way'
  ?.  ?=([%file *] u.u.vw)  `'it keeps no directory'
  ?~  (mole |.(;;([%1 registry-store] (sang-noun:tarball sang.u.u.vw))))
    `'it keeps one this version of furum cannot read'
  ~
::  +dir-trace: /tr/dir, only when it changes: the ship whose directory
::  would not read, why, and when; ~ once it reads
::
++  dir-trace
  |=  t=(unit [who=@p why=@t at=@da])
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  old=(unit [who=@p why=@t at=@da])  bind:m  (read-dir-trace 0)
  ?:  &(?=(~ t) ?=(~ old))  (pure:m ~)
  ;<  ~  bind:m  ?.(&(?=(~ t) ?=(^ old)) (pure:m ~) (clear 0 %registry))
  (over:io (rf 0 /tr %dir) [[/ %noun] [%1 t]])
::
++  read-dir-trace
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,(unit [who=@p why=@t at=@da]))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up /tr %dir))
  (pure:m (biff n |=(v=* (biff (mole |.(;;([%1 (unit [@p @t @da])] v))) tail))))
::  +take-reg: news of the registry, or a reason to look again: the hour
::  is up, or a local poke says the registry may have changed
::
++  take-reg
  =/  m  (fiber:fiber:nexus ,?(%news %again))
  ^-  form:m
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %news * *]
    ?.  =(/r wire.u.in)  [%skip ~]
    [%done %news]
      [~ %poke * *]
    ?.  =([/ %timer-wake] p.sage.u.in)  [%done %again]
    ?.  =(/rh (fall (mole |.(!<(path q.sage.u.in))) /))  [%skip ~]
    [%done %again]
  ==
::  ==  the outbox: one fiber per message to another ship
::
::  The writer never waits on another ship. It makes a grub here with
::  the message; this fiber sends it, waits at most thirty seconds for
::  the host to take it, and asks the writer to cull it. A message not
::  taken in time is still on its way: ames keeps trying.
::
++  send-out
  |=  name=@ta
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  o=[to=@p =msg]  bind:m  (get-state-as:io ,[to=@p =msg])
  ;<  ~  bind:m  (deliver 1 to.o msg.o)
  (tell [%sent name])
::  +deliver: a message to another ship's inbox, from a fiber `up` below
::  the root, waiting thirty seconds at most for it to be taken
::
++  deliver
  |=  [up=@ud to=@p =msg]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  base=path  bind:m  (install-of up to)
  ;<  *  bind:m
    %+  (with-timeout:io (unit tang))  /o
    [~s30 (poke-soft:io [%& %& (remote to base /) %'inbox.sig'] [[/furum %msg] msg])]
  (pure:m ~)
::  ==  HTTP
::
::  what a request fiber knows about its request
::
+$  ctx  [id=@ta our=@p now=@da =look:th site=(list @t) args=(map @t @t)]
::
::  +handle-request: one request. The manifest, service worker, icons and
::  about page are anyone's, and so is a public board; the rest is the
::  owner's, and a form posted from another site is refused, since eyre's
::  session cookie has no SameSite.
::
++  handle-request
  |=  id=@ta
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  [src=@p req=inbound-request:eyre]  bind:m
    (get-state-as:io ,[src=@p inbound-request:eyre])
  ;<  our=@p  bind:m  get-our:io
  ;<  now=@da  bind:m  get-time:io
  =/  [pax=(list @t) args=(map @t @t)]  (parse-request-url:fl url.request.req)
  =/  site=(list @t)  ?.(?=([%apps %furum *] pax) pax t.t.pax)
  =?  site  &(!=(~ site) =('' (rear site)))  (snip site)
  =/  get=?  =('GET' method.request.req)
  ?:  &(get ?=(?([%manifest ~] [%sw ~] [%icon ~] [%favicon ~]) site))
    (send-asset id site)
  ?:  &(get ?=([%about ~] site))  (send-page id 200 (render-about:fl our))
  ?.  &(authenticated.req =(src our))
    ?.  &(get ?=([%b @ @ *] site))
      (send-page id 403 (render-error:fl "not authenticated" plain-look))
    ;<  =look:th  bind:m  (read-look 1)
    (serve-public [id our now look site args])
  ;<  =look:th  bind:m  (read-look 1)
  =/  c=ctx  [id our now look site args]
  ?:  get  (serve-get c)
  ?.  =('POST' method.request.req)  (err c 405 "method not allowed")
  ?:  (cross-site:fr header-list.request.req)  (err c 403 "cross-site request refused")
  (serve-post c body.request.req header-list.request.req)
::  +serve-public: a public board and its posts, to anyone. A board
::  that isn't public, or doesn't exist, answers alike.
::
++  serve-public
  |=  c=ctx
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  denied  (send-page id.c 403 (render-error:fl "not authenticated" look.c))
  ?.  ?=([%b @ @ ?(~ [@ ~])] site.c)  denied
  ?.  =(`our.c (slaw %p i.t.site.c))  denied
  ;<  b=(each (unit board) @t)  bind:m  (read-board our.c i.t.t.site.c)
  ?.  ?=([%& ~ *] b)  denied
  =/  brd=board  u.p.b
  ?.  &(public.info.brd ?=(~ payment.brd))  denied
  ?~  t.t.t.site.c
    %^  send-page  id.c  200
    %:  render-board:fl  our.c  info.brd  ~(val by posts.brd)  our.c  now.c
      %.n  %.n  look.c  (parse-sort:fl args.c)  %.n  (parse-page:fl args.c)  pinned.brd  ~  sidebar.brd
    ==
  ?~  pid=(parse-id:fl i.t.t.t.site.c)  (send-page id.c 404 (render-error:fl "post not found" look.c))
  ?~  pst=(~(get by posts.brd) u.pid)  (send-page id.c 404 (render-error:fl "post not found" look.c))
  %^  send-page  id.c  200
  %:  render-post-page:fl  our.c  info.brd  u.pst  (~(gut by comments.brd) u.pid ~)
    our.c  now.c  %.n  %.n  look.c  pinned.brd  ~
  ==
::  +serve-get: the owner's pages
::
++  serve-get
  |=  c=ctx
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?+    site.c  (err c 404 "page not found")
      ~                  (serve-home c)
      [%curated ~]       (serve-home c)
      [%tag @ ~]         (serve-home c)
      [%b @ @ *]         (serve-board c)
      [%registry ~]      (redirect id.c "/apps/furum/admin")
      [%guide ~]         (send-page id.c 200 (render-guide:fl look.c))
      [%theme ~]         (serve-theme c)
      [%create ~]        (send-page id.c 200 (render-create:fl look.c))
  ::  no %storage road yet: the upload button says S3 is not set up
      [%s3-config ~]     (send-json id.c [%o ~])
  ::
      [%notifications ~]
    ;<  notes=(list notification)  bind:m  (read-notes 1)
    (send-page id.c 200 (render-notifications:fl notes now.c look.c))
  ::
      [%notif-count ~]
    ;<  notes=(list notification)  bind:m  (read-notes 1)
    =/  n=@ud  (lent (skip notes |=(n=notification read.n)))
    (send-json id.c (pairs:enjs:format ~[['count' (numb:enjs:format n)]]))
  ::
      [%push-prefs ~]
    ;<  pf=prefs  bind:m  (read-prefs 1)
    (send-json id.c [%a (turn ~(tap in tags.pf) |=(t=term s+t))])
  ::
      [%admin ~]
    ;<  all=(list [board-name board])  bind:m  all-boards
    ;<  pf=prefs  bind:m  (read-prefs 1)
    ;<  st=registry-store  bind:m  (read-directory 1)
    ;<  mirrors=(list [@p board-name board])  bind:m  all-mirrors
    %^  send-page  id.c  200
    %:  render-admin:fl  our.c  look.c  all  =(our.c registry.pf)
      ~(val by dir.st)  admins.st
      (turn mirrors |=([h=@p n=board-name *] [h n]))
      %+  turn  mirrors
      |=  [h=@p n=board-name b=board]
      [h n info.b roles.b posts.b comments.b pinned.b sidebar.b payment.b ~]
      (~(gut by args.c) 'msg' '')  registry.pf
    ==
  ::
      [%share ~]
    ;<  all=(list [board-name board])  bind:m  all-boards
    ;<  mirrors=(list [@p board-name board])  bind:m  all-mirrors
    =/  arg  |=(k=@t (~(gut by args.c) k ''))
    %^  send-page  id.c  200
    %:  render-share:fl
      %+  weld  (turn all |=([n=board-name *] [our.c n]))
      (turn mirrors |=([h=@p n=board-name *] [h n]))
      (arg 'title')  (arg 'url')  (arg 'text')  look.c
    ==
  ==
::  +serve-home: the feed of followed boards, or the directory
::
++  serve-home
  |=  c=ctx
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  all=(list [board-name board])  bind:m  all-boards
  ;<  mirrors=(list [@p board-name board])  bind:m  all-mirrors
  ;<  s=seen  bind:m  (read-seen 1)
  =/  known=(map [@p board-name] board)
    %-  malt
    %+  weld  (turn all |=([n=board-name b=board] [[our.c n] b]))
    (turn mirrors |=([h=@p n=board-name b=board] [[h n] b]))
  ?:  &(?=(~ site.c) =('feed' (~(gut by args.c) 'view' 'feed')))
    ;<  fol=(set [@p board-name])  bind:m  (read-feed 1)
    =/  pg=@ud  (parse-page:fl args.c)
    =/  feed=(list [host=@p board-name=board-name =post])
      %-  zing
      %+  turn  ~(tap in fol)
      |=  [host=@p name=board-name]
      ^-  (list [host=@p board-name=board-name =post])
      ?~  b=(~(get by known) [host name])  ~
      %+  turn  (scag (mul pg per-page:fl) (sort-posts-by-new:fl ~(val by posts.u.b)))
      |=(p=post [host name p])
    (send-page id.c 200 (render-feed:fl feed our.c now.c look.c pg boards.s))
  ;<  st=registry-store  bind:m  (read-directory 1)
  ;<  pf=prefs  bind:m  (read-prefs 1)
  ;<  dt=(unit [who=@p why=@t at=@da])  bind:m  (read-dir-trace 1)
  =/  reg=?  =(our.c registry.pf)
  =/  note=tape
    ?:  |(reg ?=(~ dt))  ""
    "Couldn't read the directory on {(scow %p who.u.dt)} {(time-ago:fl now.c at.u.dt)}: {(trip why.u.dt)}. furum keeps trying; until then this list may be out of date."
  =/  entries=(list directory-entry)  ~(val by dir.st)
  =/  tags=(set @tas)  (roll entries |=([e=directory-entry a=(set @tas)] (~(uni in a) tags.e)))
  =/  bwn=(set [@p board-name])
    %-  silt
    %+  murn  ~(tap by known)
    |=  [k=[@p board-name] b=board]
    ?~  last=(~(get by boards.s) k)  ~
    =/  newest  (roll (turn ~(val by posts.b) |=(p=post created.p)) max)
    ?.((gth newest u.last) ~ `k)
  ?+    site.c
      (send-page id.c 200 (render-home:fl entries %all ~ tags reg look.c bwn note))
      [%curated ~]
    =/  cur  (skim entries |=(e=directory-entry curated.e))
    (send-page id.c 200 (render-home:fl cur %curated ~ tags reg look.c bwn note))
  ::
      [%tag @ ~]
    =/  tag=@tas  ;;(@tas i.t.site.c)
    =/  tagged  (skim entries |=(e=directory-entry (~(has in tags.e) tag)))
    (send-page id.c 200 (render-home:fl tagged %tag `tag tags reg look.c bwn note))
  ==
::  +serve-theme: the theme page: talon's theme settings as %settings
::  holds them, furum's own, and a theme being made or edited
::
++  serve-theme
  |=  c=ctx
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs 1)
  =*  l  looks.pf
  ;<  tal=(unit [themes:th accent:th])  bind:m  talon-settings
  ;<  pro=(unit @ux)  bind:m  profile-color
  ;<  eny=@uvJ  bind:m  get-entropy:io
  =/  edit=(unit theme:th)
    =/  e  (~(get by args.c) 'edit')
    ?~  e  ~
    ?.  =('new' u.e)
      =/  hit  (skim list.own.l |=(t=theme:th =(id.t u.e)))
      ?~(hit ~ `i.hit)
    ::  a new theme starts from the built-in one, light
    `[(crip ((x-co:co 12) (end [3 6] eny))) '' | '#cc2020' '#8b1a1a' '#cc8020' '#f0eee8' '#f6f0e8' *more:th]
  %^  send-page  id.c  200
  %:  render-theme:fl  look.c  mode.l  talon.l  tal  own.l  accent.l  pro  edit
    (~(gut by args.c) 'msg' '')
  ==
::  +theme-post: a change on the theme page, made to the saved settings
::
++  theme-post
  |=  [c=ctx what=@t f=$-(@t @t)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs 1)
  =/  l=looks  looks.pf
  =/  own=themes:th  own.l
  =/  new=(unit looks)
    ?+    what  ~
        %mode
      =/  md  (f 'mode')
      ?.  ?=(?(%system %light %dark) md)  ~
      `l(mode md)
    ::
        %talon  `l(talon =('on' (f 'on')))
    ::
        %use
      =/  id  (f 'id')
      ?:  =('' id)  `l(active.own ~)
      ?.  (lien list.own |=(t=theme:th =(id.t id)))  ~
      `l(active.own `id)
    ::
        %save
      =/  t=theme:th
        :*  (f 'id')  (f 'name')  =('dark' (f 'dark'))
            (f 'primary')  (f 'secondary')  (f 'tertiary')  (f 'background')  (f 'surface')
            ::  furum's own editor sets the five; +more is talon's to set
            *more:th
        ==
      =/  rest  (skip list.own |=(o=theme:th =(id.o id.t)))
      `l(own [(snoc rest t) `id.t])
    ::
        %delete
      =/  id  (f 'id')
      =/  rest  (skip list.own |=(o=theme:th =(id.o id)))
      `l(own [rest ?:(=(`id active.own) ~ active.own)])
    ::
        %accent
      ?:  !=('' (f 'set'))  `l(accent [`& %custom `(f 'hex')])
      =/  how  (f 'how')
      ?:  =('profile' how)  `l(accent [`& %profile hex.accent.l])
      ?:  =('custom' how)  `l(accent [`& %custom `(f 'hex')])
      `l(on.accent `|)
    ==
  ?~  new  (err c 400 "that is not a theme setting")
  ;<  res=(unit deny)  bind:m  (ask [%look u.new])
  ?~  res  (redirect id.c "/apps/furum/theme")
  (err c code.u.res (trip why.u.res))
::  +serve-board: a board and the pages under it: one this ship hosts,
::  or its mirror of one another ship hosts. The first visit to another
::  ship's board starts its follower and waits on the copy.
::
++  serve-board
  |=  c=ctx
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?.  ?=([%b @ @ *] site.c)  (err c 404 "page not found")
  ?~  host=(slaw %p i.t.site.c)  (err c 404 "board not found")
  =/  name=board-name  i.t.t.site.c
  =/  rest=(list @t)  t.t.t.site.c
  =/  local=?  =(u.host our.c)
  ?:  ?=([%submit ~] rest)  (send-page id.c 200 (render-submit:fl u.host name look.c))
  ;<  b=(each (unit board) @t)  bind:m  (read-board u.host name)
  ?:  ?=(%| -.b)  (err c 500 (trip p.b))
  ?~  p.b
    ?:  |(local !(valid-board-name:fl name))  (err c 404 "board not found")
    ::  its host said lately it has no such board; after a minute, ask again
    ;<  g=(unit *)  bind:m  (read-noun (rf 1 /gone/(scot %p u.host) name))
    =/  when=(unit @da)  (biff g |=(v=* (bind (mole |.(;;([%1 @da] v))) tail)))
    ?:  &(?=(^ when) (lth now.c (add u.when ~m1)))
      (err c 404 "{(scow %p u.host)} has no board named {(trip name)}")
    ;<  ~  bind:m  (tell [%watch u.host name])
    (send-page id.c 200 (render-loading:fl (weld "/apps/furum" (trip (spat site.c))) look.c))
  ::  who paid is kept apart from a board we host; the mod page lists them
  ;<  mem=(each (map @p @da) @t)  bind:m
    ?.  local  (pure:(fiber:fiber:nexus ,(each (map @p @da) @t)) &+~)
    (read-members 1 name)
  =/  brd=board  u.p.b(paid ?:(?=(%& -.mem) p.mem ~))
  =/  mod=?  (is-mod:fr our.c brd)
  ::  another ship's paid board that is closed to us: its paywall
  ;<  closed=?  bind:m
    ?:  |(local ?=(~ payment.brd))  (pure:(fiber:fiber:nexus ,?) |)
    ;<  n=(unit *)  bind:(fiber:fiber:nexus ,?)  (read-noun (rf 1 /cache/(scot %p u.host)/[name] %access))
    (pure:(fiber:fiber:nexus ,?) !=(`[%1 &] n))
  ?:  ?=([%payment @ ~] rest)  (serve-payment c u.host name brd i.t.rest closed)
  ?:  &(closed ?=(^ payment.brd))
    (send-page id.c 200 (render-paywall:fl u.host info.brd u.payment.brd ~ look.c %.n))
  ?+    rest  (err c 404 "page not found")
      ~
    ;<  s=seen  bind:m  (read-seen 1)
    ;<  fol=(set [@p board-name])  bind:m  (read-feed 1)
    ;<  ~  bind:m  (tell [%seen u.host name ~])
    %^  send-page  id.c  200
    %:  render-board:fl  u.host  info.brd  ~(val by posts.brd)  our.c  now.c
      mod  %.y  look.c  (parse-sort:fl args.c)  (~(has in fol) [u.host name])
      (parse-page:fl args.c)  pinned.brd  (~(get by boards.s) [u.host name])  sidebar.brd
    ==
  ::
  ::  the host's wallet, as json to keep somewhere safe
      [%mod %backup-proofs ~]
    ?.  &(local mod)  (err c 403 "only the host keeps the wallet")
    ;<  w=(each (map @t (list cashu-proof)) @t)  bind:m  (read-wallet 1 name)
    ?:  ?=(%| -.w)  (err c 500 (trip p.w))
    %+  send-json  id.c
    :-  %a
    %-  zing
    %+  turn  ~(tap by p.w)
    |=  [mint=@t ps=(list cashu-proof)]
    %+  turn  ps
    |=  q=cashu-proof
    %-  pairs:enjs:format
    :~  ['mint' s+mint]
        ['amount' (numb:enjs:format amount.q)]
        ['id' s+id.q]
        ['secret' s+secret.q]
        ['C' s+c.q]
    ==
  ::  a board we host shows its wallet, and a withdrawal under way
      [%mod ~]
    ?.  mod  (err c 403 "not a moderator")
    ;<  w=(each (map @t (list cashu-proof)) @t)  bind:m
      ?.  local  (pure:(fiber:fiber:nexus ,(each (map @t (list cashu-proof)) @t)) &+~)
      (read-wallet 1 name)
    ;<  live=(list pay)  bind:m  ?.(local (pure:(fiber:fiber:nexus ,(list pay)) ~) (read-pays 1))
    =/  melting=?
      (lien live |=(q=pay &(=(name name.q) ?=(?(%melt %melting) -.step.q))))
    %^  send-page  id.c  200
    %:  render-mod:fl  u.host  info.brd  roles.brd  local  look.c  sidebar.brd  payment.brd
      ?:(?=(%& -.w) p.w ~)  melting  (~(gut by args.c) 'saved' '')  paid.brd  now.c  prune.brd
    ==
  ::
      [@ %edit ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    ?~  pst=(~(get by posts.brd) u.pid)  (err c 404 "post not found")
    ?.  =(our.c author.u.pst)  (err c 403 "only the author can edit this post")
    (send-page id.c 200 (render-edit-post:fl u.host name u.pst look.c))
  ::
      [@ ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    ?~  pst=(~(get by posts.brd) u.pid)  (err c 404 "post not found")
    ;<  s=seen  bind:m  (read-seen 1)
    ;<  ~  bind:m  (tell [%seen u.host name `u.pid])
    %^  send-page  id.c  200
    %:  render-post-page:fl  u.host  info.brd  u.pst  (~(gut by comments.brd) u.pid ~)
      our.c  now.c  mod  %.y  look.c  pinned.brd  (~(get by posts.s) [u.host name u.pid])
    ==
  ==
::  +serve-post: the owner's forms. Most are an action: applied by our
::  writer before the redirect on a board we host, sent to the host's
::  inbox on another ship's.
::
++  serve-post
  |=  [c=ctx body=(unit octs) headers=(list [key=@t value=@t])]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  form=(map @t @t)  (parse-form:fl body)
  =/  f  |=(k=@t (~(gut by form) k ''))
  =/  back=tape  (trip (fall (get-header:http 'referer' headers) '/apps/furum'))
  =/  admin  |=(a=registry-action (reg-then c a "/apps/furum/admin"))
  ?+    site.c  (err c 404 "not found")
      [%dark-mode ~]            (ask-then c [%toggle-dark-mode ~] back)
      [%theme @ ~]              (theme-post c i.t.site.c f)
      [%notifications %read ~]  (ask-then c [%mark-notifications-read ~] "/apps/furum/notifications")
      [%b @ @ *]                (serve-board-post c f back)
      [%admin %refresh-registry ~]  (redirect id.c "/apps/furum/admin")
  ::
      [%create ~]
    =/  name=@t  (crip (cass (trip (f 'name'))))
    =/  =role  ?:(=('reader' (f 'default-role')) %reader %poster)
    ;<  res=(unit deny)  bind:m  (ask [%act our.c %create-board name (f 'title') (f 'description') role])
    ?^  res  (err c code.u.res (trip why.u.res))
    ;<  *  bind:m  (register c [%register name (f 'title') (f 'description')])
    (redirect id.c "/apps/furum/b/{(scow %p our.c)}/{(trip name)}")
  ::
      [%push-prefs ~]
    =/  j=json  (fall (de:json:html ?~(body '' q.u.body)) ~)
    =/  arr=(list json)
      ?.  ?=([%o *] j)  ~
      =/  a  (~(get by p.j) 'tags')
      ?.  ?=([~ %a *] a)  ~
      p.u.a
    =/  tags=(set term)  (silt (murn arr |=(t=json ?.(?=([%s *] t) ~ (slaw %tas p.t)))))
    ;<  *  bind:m  (ask [%prefs `tags ~])
    (send-json id.c (pairs:enjs:format ~[['ok' b+&]]))
  ::
      [%admin %registry-ship ~]
    ?~  who=(slaw %p (f 'who'))  (err c 400 "that is not a ship name")
    ;<  *  bind:m  (ask [%prefs ~ `u.who])
    ::  the directory reader looks again
    ;<  *  bind:m
      ((with-timeout:io (unit tang)) /dir ~s5 (poke-soft:io (rf 1 / %'dir.sig') [[/furum %op] ~]))
    (redirect id.c "/apps/furum/admin")
  ::
      [%admin %resub ~]
    ?~  host=(slaw %p (f 'host'))  (err c 400 "that is not a ship name")
    =/  name=@t  (f 'name')
    ?.  (valid-board-name:fl name)  (err c 404 "board not found")
    ;<  *  bind:m
      %+  (with-timeout:io (unit tang))  /resub
      [~s5 (poke-soft:io (rf 1 /follows/(scot %p u.host) name) [[/furum %op] ~])]
    (redirect id.c "/apps/furum/admin?msg=resubscribed")
  ::
      [%registry %add-admin ~]
    ?~  who=(slaw %p (f 'who'))  (err c 400 "that is not a ship name")
    (admin [%add-registry-admin u.who])
      [%registry %remove-admin ~]
    ?~  who=(slaw %p (f 'who'))  (err c 400 "that is not a ship name")
    (admin [%remove-registry-admin u.who])
      [%registry %tag ~]     (admin [%tag-board (cass-term (f 'name')) (cass-term (f 'tag'))])
      [%registry %untag ~]   (admin [%untag-board (cass-term (f 'name')) (cass-term (f 'tag'))])
      [%registry %curate ~]  (admin [%curate-board (cass-term (f 'name')) =('true' (f 'curated'))])
  ==
::
++  cass-term  |=(t=@t ^-(@tas (crip (cass (trip t)))))
::  +serve-board-post: the forms under a board
::
++  serve-board-post
  |=  [c=ctx f=$-(@t @t) back=tape]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?.  ?=([%b @ @ *] site.c)  (err c 404 "not found")
  ?~  host=(slaw %p i.t.site.c)  (err c 404 "board not found")
  =/  name=board-name  i.t.t.site.c
  =/  rest=(list @t)  t.t.t.site.c
  =/  local=?  =(u.host our.c)
  =/  base=tape  "/apps/furum/b/{(scow %p u.host)}/{(trip name)}"
  ?:  ?=([%follow ~] rest)    (ask-then c [%follow-board u.host name] base)
  ?:  ?=([%unfollow ~] rest)  (ask-then c [%unfollow-board u.host name] base)
  ::  paying for another ship's board
  ?:  ?=(?([%pay ~] [%pay-lightning ~]) rest)
    ?:  local  (err c 400 "you host this board")
    (pay-then c u.host name ?=([%pay-lightning ~] rest) f)
  ::  what only the host may change
  ?:  &(!local ?=([%mod ?(%prune %edit-info %public %delete %register %payment %grant %revoke %melt) ~] rest))
    (err c 403 "only the board's host can change that")
  ?:  ?=([%mod %melt ~] rest)
    (ask-then c [%melt-to-lightning name (f 'mint') (f 'invoice')] "{base}/mod")
  ?:  ?=([%mod %register ~] rest)
    ;<  b=(each (unit board) @t)  bind:m  (read-board our.c name)
    ?.  ?=([%& ~ *] b)  (err c 404 "board not found")
    =*  info  info.u.p.b
    ;<  *  bind:m  (register c [%register name title.info description.info])
    (redirect id.c "{base}/mod?saved=registered")
  ::  a new title or description goes to the directory too, as the
  ::  board now holds it (every board is registered when it is made)
  ?:  ?=([%mod %edit-info ~] rest)
    ;<  res=(unit deny)  bind:m  (ask [%act our.c %edit-board-info name (f 'title') (f 'description')])
    ?^  res  (err c code.u.res (trip why.u.res))
    ;<  b=(each (unit board) @t)  bind:m  (read-board our.c name)
    ;<  *  bind:m
      ?.  ?=([%& ~ *] b)  (pure:(fiber:fiber:nexus ,(unit deny)) ~)
      (register c [%register name title.info.u.p.b description.info.u.p.b])
    (redirect id.c "{base}/mod")
  ?:  ?=([%mod %delete ~] rest)
    ;<  res=(unit deny)  bind:m  (ask [%act our.c %delete-board name])
    ?^  res  (err c code.u.res (trip why.u.res))
    ;<  *  bind:m  (register c [%unregister name])
    (redirect id.c "/apps/furum")
  ?:  ?=([%mod %public ~] rest)
    ;<  b=(each (unit board) @t)  bind:m  (read-board our.c name)
    ?.  ?=([%& ~ *] b)  (err c 404 "board not found")
    (ask-then c [%set-public name !public.info.u.p.b] "{base}/mod")
  =/  r  (form-action name rest f back base now.c)
  ?:  ?=(%| -.r)  (err c code.p.r why.p.r)
  ?:  local  (ask-then c p.r)
  (send-then c u.host name p.r)
::  +form-action: the action a board's form asks for, and where the
::  browser goes after it
::
++  form-action
  |=  [name=board-name rest=(list @t) f=$-(@t @t) back=tape base=tape now=@da]
  ^-  (each [=action to=tape] [code=@ud why=tape])
  =/  txt  |=(k=@t ?:(=('' (f k)) ~ `(f k)))
  =/  num  |=([k=@t d=@ud] (fall (rush (f k) dum:ag) d))
  =/  pid  ?.(?=([@ *] rest) ~ (parse-id:fl i.rest))
  =/  post  |=(p=@ud "{base}/{(a-co:co p)}")
  ?+    rest  |+[404 "not found"]
      [%submit ~]   &+[[%new-post name (f 'title') (txt 'url') (txt 'body')] base]
      [%sidebar ~]  &+[[%set-sidebar name (f 'sidebar')] "{base}/mod"]
  ::
      [%vote ~]
    ?~  t=(parse-vote-target:fl (f 'target'))  |+[400 "invalid vote target"]
    =/  d=@t  (f 'dir')
    :+  %&
      ?:  =('up' d)  [%upvote name u.t]
      ?:  =('down' d)  [%downvote name u.t]
      [%remove-vote name u.t]
    back
  ::
      [%mod %prune ~]
    :+  %&
      :+  %set-prune  name
      ?.  =('on' (f 'prune-enabled'))  ~
      `[(num 'min-score' 2) (mul ~d1 (num 'after-days' 7))]
    "{base}/mod"
  ::
      [%mod %role ~]
    ?~  who=(slaw %p (f 'who'))  |+[400 "that is not a ship name"]
    =/  r=@t  (f 'role')
    &+[[%set-role name u.who ?:(=('mod' r) %mod ?:(=('poster' r) %poster %reader))] "{base}/mod"]
  ::
      [%mod %remove-role ~]
    ?~  who=(slaw %p (f 'who'))  |+[400 "that is not a ship name"]
    &+[[%remove-role name u.who] "{base}/mod"]
  ::  a price makes the board paid; unticked, free again. Minutes, when
  ::  given, are the period instead of days (a short one, to try it)
      [%mod %payment ~]
    =/  mint=@t  (f 'mint-url')
    =/  for=@dr
      ?:  =('' (f 'minutes'))  (mul ~d1 (max 1 (num 'interval' 30)))
      (mul ~m1 (max 1 (num 'minutes' 1)))
    :+  %&
      :+  %set-payment  name
      ?.  =('on' (f 'enabled'))  ~
      `[(num 'price' 0) for ?:(=('' mint) ~ `mint)]
    "{base}/mod?saved=payment"
  ::
      [%mod %grant ~]
    ?~  who=(slaw %p (f 'who'))  |+[400 "that is not a ship name"]
    ::  minutes, for a short trial, when given; else days
    =/  for=@dr
      ?:  =('' (f 'minutes'))  (mul ~d1 (max 1 (num 'days' 30)))
      (mul ~m1 (max 1 (num 'minutes' 1)))
    &+[[%grant-paid name u.who (add now for)] "{base}/mod"]
  ::
      [%mod %revoke ~]
    ?~  who=(slaw %p (f 'who'))  |+[400 "that is not a ship name"]
    &+[[%revoke-paid name u.who] "{base}/mod"]
  ::
      [@ %edit ~]
    ?~  pid  |+[404 "post not found"]
    &+[[%edit-post name u.pid (f 'title') (txt 'body')] (post u.pid)]
  ::
      [@ %comment ~]
    ?~  pid  |+[404 "post not found"]
    =/  parent=(unit comment-id)  ?:(=('' (f 'parent')) ~ (parse-id:fl (f 'parent')))
    &+[[%new-comment name u.pid parent (f 'body')] (post u.pid)]
  ::
      [@ %delete ~]
    ?~  pid  |+[404 "post not found"]
    &+[[%delete-post name u.pid] base]
  ::
      [@ %delete-comment ~]
    ?~  pid  |+[404 "post not found"]
    ?~  cid=(parse-id:fl (f 'comment-id'))  |+[400 "invalid comment"]
    &+[[%delete-comment name u.pid u.cid] (post u.pid)]
  ::
      [@ %pin ~]
    ?~  pid  |+[404 "post not found"]
    &+[[%pin-post name u.pid =('true' (f 'pinned'))] base]
  ==
::  ==  talking to the writer, and to other ships
::
::  +ask-then: one action, applied, then the redirect; a refusal is an
::  error page with the writer's reason
::
++  ask-then
  |=  [c=ctx =action to=tape]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  res=(unit deny)  bind:m  (ask [%act our.c action])
  ?~  res  (redirect id.c to)
  (err c code.u.res (trip why.u.res))
::  +send-then: an action on another ship's board, to its host's inbox,
::  then the redirect once our mirror has changed (five seconds at
::  most). A refusal comes back later as a note.
::
++  send-then
  |=  [c=ctx host=@p name=board-name =action to=tape]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  base=path  bind:m  (install-of 1 host)
  ::  watch the mirror before sending, so a change that lands fast is seen
  ;<  w=(unit wave:nexus)  bind:m
    (keep-soft:io /mine (rv 1 /cache/(scot %p host)/[name]) ~ ~s5)
  ;<  res=(unit (unit tang))  bind:m
    %+  (with-timeout:io (unit tang))  /send
    [~s15 (poke-soft:io [%& %& (remote host base /) %'inbox.sig'] [[/furum %msg] `msg`[%act action]])]
  ?~  res  (err c 504 "{(scow %p host)} did not answer; your change goes when it is back")
  ?^  u.res  (err c 502 "{(scow %p host)} would not take it: it may not run this furum")
  ;<  *  bind:m
    ?~  w  (pure:(fiber:fiber:nexus ,(unit wave:nexus)) ~)
    ((with-timeout:io wave:nexus) /seen ~s5 (take-news:io /mine))
  (redirect id.c to)
::  +pay-then: a payment for another ship's board: kept in /payments
::  under a fresh nonce, asked of its host, then its page, which follows
::  the host's answers
::
++  pay-then
  |=  [c=ctx host=@p name=board-name ln=? f=$-(@t @t)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  eny=@uvJ  bind:m  get-entropy:io
  =/  nonce=@t  (crip ((x-co:co 16) (end [3 8] eny)))
  ;<  res=(unit deny)  bind:m  (ask [%paying host name nonce ln])
  ?^  res  (err c code.u.res (trip why.u.res))
  =/  =action
    ?:  ln  [%request-lightning-invoice name nonce]
    [%submit-payment name (f 'mint') (f 'tokens') nonce]
  ;<  base=path  bind:m  (install-of 1 host)
  ;<  sent=(unit (unit tang))  bind:m
    %+  (with-timeout:io (unit tang))  /send
    [~s15 (poke-soft:io [%& %& (remote host base /) %'inbox.sig'] [[/furum %msg] `msg`[%act action]])]
  ?~  sent  (err c 504 "{(scow %p host)} did not answer; try again when it is back")
  ?^  u.sent  (err c 502 "{(scow %p host)} would not take it: it may not run this furum")
  (redirect id.c "/apps/furum/b/{(scow %p host)}/{(trip name)}/payment/{(trip nonce)}")
::  +serve-payment: how a payment we made is going, by its host's last
::  word: the paywall waiting, the invoice to pay, the board once it
::  opens to us, or why it failed
::
++  serve-payment
  |=  [c=ctx host=@p name=board-name brd=board nonce=@t closed=?]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  ps=(map @t payment)  bind:m  (read-payments 1)
  =/  base=tape  "/apps/furum/b/{(scow %p host)}/{(trip name)}"
  ?~  e=(~(get by ps) nonce)  (err c 404 "payment not found")
  ?.  &(=(host host.u.e) =(name name.u.e))  (err c 404 "payment not found")
  ?~  payment.brd  (redirect id.c base)
  =*  pc  u.payment.brd
  =*  v  view.u.e
  ?-    -.v
      %failed   (err c 402 "the payment failed: {(trip why.v)}")
      %invoice  (send-page id.c 200 (render-lightning-invoice:fl host info.brd pc `bolt11.v look.c))
      %asked
    ?:  ln.v  (send-page id.c 200 (render-lightning-invoice:fl host info.brd pc ~ look.c))
    (send-page id.c 200 (render-paywall:fl host info.brd pc ~ look.c &))
  ::  paid: our copy of the board looks again, until it opens to us
      %paid
    ?.  closed  (redirect id.c base)
    ;<  *  bind:m
      %+  (with-timeout:io (unit tang))  /resync
      [~s5 (poke-soft:io (rf 1 /follows/(scot %p host) name) [[/furum %op] ~])]
    (send-page id.c 200 (render-paywall:fl host info.brd pc ~ look.c &))
  ==
::  +reg-then: a registry action of ours, then the redirect
::
++  reg-then
  |=  [c=ctx act=registry-action to=tape]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  res=(unit deny)  bind:m  (register c act)
  ?~  res  (redirect id.c to)
  (err c code.u.res (trip why.u.res))
::  +register: a registry action of ours: to our writer when we keep
::  the registry, else to the registry's inbox, where any refusal comes
::  back as a note
::
++  register
  |=  [c=ctx act=registry-action]
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs 1)
  ;<  here=path  bind:m  (read-here 1)
  ?:  =(our.c registry.pf)  (ask [%reg our.c here act])
  ;<  base=path  bind:m  (install-of 1 registry.pf)
  ;<  *  bind:m
    %+  (with-timeout:io (unit tang))  /reg
    [~s15 (poke-soft:io [%& %& (remote registry.pf base /) %'inbox.sig'] [[/furum %msg] `msg`[%reg here act]])]
  (pure:m ~)
::  +ask: an op the writer answers once applied. A writer waiting after a
::  crash refuses the poke at once; one that never answers times out.
::
++  ask
  |=  =op
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  ;<  err=(unit tang)  bind:m  (poke-soft:io (rf 1 / %'main.sig') [[/furum %ask] op])
  ?^  err  (pure:m `[503 'furum is recovering from a crash; try again in a minute'])
  ;<  res=(unit (unit deny))  bind:m  ((with-timeout:io (unit deny)) /ask ~s30 take-done)
  ?~  res  (pure:m `[504 'furum took too long to answer; try again'])
  (pure:m u.res)
::
++  take-done
  =/  m  (fiber:fiber:nexus ,(unit deny))
  ^-  form:m
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %poke * *]
    ?.  =([/furum %done] p.sage.u.in)  [%skip ~]
    [%done (fall (mole |.(;;((unit deny) q.q.sage.u.in))) `[500 'the writer answered nonsense'])]
  ==
::  +tell: an op nobody waits on (a page view's seen mark)
::
++  tell
  |=  =op
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  *  bind:m  (poke-soft:io (rf 1 / %'main.sig') [[/furum %op] op])
  (pure:m ~)
::  ==  reads for pages
::
::  +read-board: a board by host and name: ours, or our mirror of
::  another ship's. ~ when there is none, or why it won't load.
::
++  read-board
  |=  [host=@p name=@t]
  =/  m  (fiber:fiber:nexus ,(each (unit board) @t))
  ^-  form:m
  ?.  (valid-board-name:fl name)  (pure:m &+~)
  ;<  our=@p  bind:m  get-our:io
  ;<  gs=(map path *)  bind:m
    (read-dir 1 ?:(=(our host) /boards/[name] /cache/(scot %p host)/[name]))
  ?:  =(~ gs)  (pure:m &+~)
  =/  r  (load:fb ~(tap by gs))
  ?:  ?=(%| -.r)  (pure:m r)
  (pure:m &+`p.r)
::  +all-boards: every board this ship hosts, in one read; one that won't
::  load is left out
::
++  all-boards
  =/  m  (fiber:fiber:nexus ,(list [board-name board]))
  ^-  form:m
  ;<  vw=view:nexus  bind:m  (peek:io (rv 1 /boards) ~)
  ?.  ?=(%ball -.vw)  (pure:m ~)
  %-  pure:m
  %+  murn  ~(tap by dir.ball.vw)
  |=  [n=@ta b=ball:tarball]
  =/  r  (load:fb ~(tap by (ball-grubs b)))
  ?.(?=(%& -.r) ~ `[`board-name`n p.r])
::  +all-mirrors: every other ship's board we keep a copy of, in one read
::
++  all-mirrors
  =/  m  (fiber:fiber:nexus ,(list [@p board-name board]))
  ^-  form:m
  ;<  vw=view:nexus  bind:m  (peek:io (rv 1 /cache) ~)
  ?.  ?=(%ball -.vw)  (pure:m ~)
  %-  pure:m
  %-  zing
  %+  turn  ~(tap by dir.ball.vw)
  |=  [h=@ta hb=ball:tarball]
  ^-  (list [@p board-name board])
  ?~  host=(slaw %p h)  ~
  %+  murn  ~(tap by dir.hb)
  |=  [n=@ta b=ball:tarball]
  =/  r  (load:fb ~(tap by (ball-grubs b)))
  ?.(?=(%& -.r) ~ `[u.host `board-name`n p.r])
::  ==  answering
::
++  err
  |=  [c=ctx code=@ud msg=tape]
  (send-page id.c code (render-error:fl msg look.c))
::
++  send-page
  |=  [id=@ta code=@ud page=manx]
  %+  send-simple:srv  id
  :_  `(manx-to-octs:fl page)
  :-  code
  :~  ['content-type' 'text/html']
      ['cache-control' 'no-store, no-cache, must-revalidate']
      ['pragma' 'no-cache']
  ==
::
++  send-json
  |=  [id=@ta jon=json]
  %+  send-simple:srv  id
  :_  `(as-octs:mimes:html (en:json:html jon))
  [200 ~[['content-type' 'application/json'] ['cache-control' 'no-store']]]
::
++  redirect
  |=  [id=@ta to=tape]
  (send-simple:srv id [[303 ~[['location' (crip to)]]] ~])
::  +send-asset: the favicon, the app icon, the manifest and the service
::  worker, which the page shell links
::
++  send-asset
  |=  [id=@ta site=(list @t)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  raw
    |=  [type=@t body=@t]
    (send-simple:srv id [[200 ~[['content-type' type]]] `(as-octs:mimes:html body)])
  ?+    site  (send-simple:srv id [[200 ~[['content-type' 'image/svg+xml']]] `+.icon])
      [%sw ~]
    %+  send-simple:srv  id
    :_  `(as-octs:mimes:html furum-sw-js:fl)
    [200 ~[['content-type' 'application/javascript'] ['service-worker-allowed' '/apps/furum']]]
  ::
  ::  the logo as a png, for the manifest and iOS's home screen
      [%icon ~]
    (send-simple:srv id [[200 ~[['content-type' 'image/png']]] (de:base64:mimes:html furum-icon-png:fl)])
  ::
      [%manifest ~]
    %+  raw  'application/manifest+json'
    %:  rap  3
      '{"name":"furum","short_name":"furum","start_url":"/apps/furum",'
      '"display":"standalone","background_color":"#f6f6ef","theme_color":"#cc2020",'
      '"icons":[{"src":"/apps/furum/icon","sizes":"512x512","type":"image/png"}],'
      '"share_target":{"action":"/apps/furum/share","method":"GET",'
      '"params":{"title":"title","text":"text","url":"url"}}}'
      ~
    ==
  ==
::  ==  faults
::
::  +alarm: a fault of `kind` seen. It is kept at /tr/fault (its line,
::  when it began and was last seen, how many times) and said on the
::  console at `pri` (2 >>, 3 >>>) only when +fault-plan says so: new,
::  changed, or a crash back after two quiet hours. A trace follows the
::  line the first time only. A crashed fiber calls it, so it never
::  fails, and without a clock (a refused /sys/bowl.sig) it does nothing:
::  every read and write needs one, and the kernel names that veto.
::
::  ponytail: two fibers that fault in the same moment each write back
::  what they read, so a line may be said twice. A grub per kind ends it.
::
++  alarm
  |=  [up=@ud kind=@tas pri=@ud line=tape =tang]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  clock=(unit @da)  bind:m  soft-now
  ?~  clock  (pure:m ~)
  ;<  fs=(map @tas fault:fr)  bind:m  (read-faults up)
  =/  plan  (fault-plan:fr (~(get by fs) kind) (crip line) u.clock ?:(=(2 pri) `~h2 ~))
  ;<  ~  bind:m  (write-faults up (~(put by fs) kind new.plan))
  ?.  say.plan  (pure:m ~)
  (pure:m ((%*(. slog pri pri) [leaf+line ?:(=(1 n.new.plan) tang ~)]) ~))
::  +alarm-ungranted: a road refused where it was used. It is ours to
::  say only if the shell's grant lacks it: a granted road refused is the
::  weir catching up with an approval (the shell restarts the app before
::  it applies the new weir), and a reload follows. Before any approval
::  (no grant.json) the shell is asking, and nothing is said either.
::
++  alarm-ungranted
  |=  [up=@ud kind=@tas verb=@t road=@t line=tape]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  grant=json  bind:m  (read-json (rf up / %'grant.json'))
  ?.  ?=([%o *] grant)  (pure:m ~)
  ?:  (granted:fr grant verb road)  (pure:m ~)
  (alarm up kind 3 line ~)
::  +clear: a kind's cause has gone; its fault goes, silently
::
++  clear
  |=  [up=@ud kind=@tas]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  fs=(map @tas fault:fr)  bind:m  (read-faults up)
  ?.  (~(has by fs) kind)  (pure:m ~)
  (write-faults up (~(del by fs) kind))
::
++  write-faults
  |=  [up=@ud fs=(map @tas fault:fr)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  *  bind:m  (over-as-soft:io (rf up /tr %fault) [[/ %noun] [%1 fs]] [/ %noun])
  (pure:m ~)
::
++  read-faults
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,(map @tas fault:fr))
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up /tr %fault))
  (pure:m (fall (biff n |=(v=* (bind (mole |.(;;([%1 (map @tas fault:fr)] v))) tail))) ~))
::  what the console says of each fault, worded once: what is wrong,
::  then what to do. Variable parts go last, so a line can be searched.
::
++  say-inbox  "%furum: other ships can't reach this ship's boards or inbox. Allow furum /sys/ames/registry (may poke) on grubbery's permissions page."
++  say-groups  "%furum: members can't read this ship's paid boards. Allow furum /sys/ames/usergroups/ (may create & remove files) and /sys/ames/registry (may poke) on grubbery's permissions page."
++  say-read  "%furum: may not read other ships, so their boards and the directory stay empty. Allow furum /sys/ames/ships/ (may read) on grubbery's permissions page."
++  say-send  "%furum: may not send to other ships, so its posts, votes and registrations there are lost. Allow furum /sys/ames/ships/ (may poke) on grubbery's permissions page."
++  say-iris  "%furum: may not reach Cashu mints, so nobody can pay for this ship's boards. Allow furum /sys/iris/ (may poke) on grubbery's permissions page."
++  say-registry
  |=  who=@p
  "%furum: the registry setting names a ship that keeps no directory furum can read. Set the registry ship on furum's admin page: {(scow %p who)}"
++  say-crash
  |=  kind=@tas
  "%furum {(trip kind)}: crashed, and tries again by itself (rise.json counts the tries). If it keeps crashing, report it with the kernel's %fiber-crash trace before this line."
++  say-payment
  |=  id=@ta
  "%furum: a payment's record can't be read, so it is left as it is. Report it: /pay/{(trip id)}"
++  say-web  "%furum: may not serve its pages at /apps/furum. Allow furum /sys/eyre/ (may poke) on grubbery's permissions page."
::  +check-grant: at the writer's start (every load, so every approval),
::  the faults the shell's grant explains: each missing road furum can't
::  do without, kept and said once; each granted one, its fault cleared.
::  Before any approval there is no grant.json, the shell is asking, and
::  furum says nothing. /sys/push/ and /sys/scry/ go unchecked: furum
::  works without them, as their weir lines say. Nor are /sys/bowl.sig
::  and /sys/behn/: refused, they park the fiber that first uses them,
::  and the kernel says that once for the app (its parked line), with
::  the parked grub's bang as the record. Furum says only what fails
::  softly, which the kernel doesn't report.
::
++  needs
  ^-  (list [kind=@tas verb=@t road=@t must=? line=@t])
  :~  [%web 'poke' '/sys/eyre/' & (crip say-web)]
      [%inbox 'poke' '/sys/ames/registry' & (crip say-inbox)]
      [%send 'poke' '/sys/ames/ships/' & (crip say-send)]
      [%read 'peek' '/sys/ames/ships/' & (crip say-read)]
      [%iris 'poke' '/sys/iris/' | (crip say-iris)]
      [%groups 'make' '/sys/ames/usergroups/' | (crip say-groups)]
  ==
++  check-grant
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  grant=json  bind:m  (read-json (rf 0 / %'grant.json'))
  ?.  ?=([%o *] grant)  (pure:m ~)
  ;<  clock=(unit @da)  bind:m  soft-now
  ?~  clock  (pure:m ~)
  ;<  fs=(map @tas fault:fr)  bind:m  (read-faults 0)
  =/  plan  (grant-faults:fr fs grant u.clock needs)
  ;<  ~  bind:m  ?:(=(fs.plan fs) (pure:m ~) (write-faults 0 fs.plan))
  (pure:m ((%*(. slog pri 3) (turn say.plan |=(l=@t leaf+(trip l)))) ~))
::  +poke-ours: a poke, and why it didn't land: ~ when it did; %ours when
::  our own weir refused it (a road furum wasn't granted); %theirs when
::  it failed further on (the other end refused it, or crashed on it)
::
++  poke-ours
  |=  [=road:tarball =bask:tarball]
  =/  m  (fiber:fiber:nexus ,(unit ?(%ours %theirs)))
  ^-  form:m
  ;<  =wire  bind:m  (nonce:io /poke)
  ;<  ~  bind:m  (send-dart:io %node wire road %poke bask)
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %veto *]  [%done `%ours]
      [~ %pack * *]
    ?.  =(wire wire.u.in)  [%skip ~]
    [%done ?~(err.u.in ~ `%theirs)]
  ==
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
  |=  [up=@ud =prod:fiber:nexus kind=@tas msg=tape]
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
  ::  no clock: nothing can be read or kept, and the kernel names the veto
  ?~  clock  (rise-park note)
  =/  now=@da  u.clock
  ;<  log=json  bind:m  (read-json (rf up / %'rise.json'))
  =/  plan  (rise-plan:fr (gj:fr log key) crash now)
  ?.  (gth until.plan now)  (pure:m ~)
  ;<  ~  bind:m
    =/  m  (fiber:fiber:nexus ,~)
    ?.  crash  (pure:m ~)
    ;<  *  bind:m
      %^  over-as-soft:io  (rf up / %'rise.json')
        [[/ %json] (set-key:fr log key (rise-row:fr plan now))]
      [/ %json]
    (pure:m ~)
  ;<  set=?  bind:m
    (soft-behn /rise/set [[/ %timer-set] `[wire @da]`[/rise until.plan]])
  ::  no timer: a refused /sys/behn/, which parks the fibers that use it
  ::  and which the kernel says once; nothing more is said here
  ?.  set  (rise-park note)
  ::  the trace is the kernel's: it prints %fiber-crash with it each time
  ;<  ~  bind:m  ?.(crash (pure:m ~) (alarm up (cat 3 'crash-' kind) 2 (say-crash kind) ~))
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
