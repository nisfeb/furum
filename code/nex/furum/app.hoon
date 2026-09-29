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
::    /sweep               when a member next runs out
::    /follows/<host>/<name>  a board on another ship we read; its follower
::    /cache/<host>/<name>/…  that board's mirror, the same grubs
::    /feed                the boards in the home feed
::    /prefs  /seen  /limits  dark mode, push tags, the registry ship; what
::                         you last read; rate limits
::    /notes               notifications, newest first, the last 50
::    /registry            the directory, on the ship that keeps it (public)
::    /directory           this ship's copy of it
::    /grant.json          the shell's record of our grant, with our own path
::    /tr/last  /tr/inbox  the writer's last refusal; what other ships poked
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
          [%over %& [/ %'icon.svg'] [[/ %mime] [~[%image 'svg+xml'] (as-octs:mimes:html furum-favicon-svg:fl)]]]
          [%fall %& [/ %'main.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'inbox.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'web.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'prune.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'dir.sig'] [[/ %sig] ~]]
          [%fall %& [/ %'sweep.sig'] [[/ %sig] ~]]
          [%fall %| /members empty-dir:loader]
          [%fall %& [/ %sweep] [[/ %noun] [%1 ~]]]
          [%fall %| /requests empty-dir:loader]
          [%fall %| /outbox empty-dir:loader]
          [%fall %| /boards empty-dir:loader]
          [%fall %| /follows empty-dir:loader]
          [%fall %| /cache empty-dir:loader]
          [%fall %& [/ %feed] [[/ %noun] [%1 ~]]]
          [%fall %& [/ %prefs] [[/ %noun] [%2 default-prefs]]]
          [%fall %& [/ %notes] [[/ %noun] [%1 ~]]]
          [%fall %& [/ %registry] [[/ %noun] [%1 *registry-store]]]
          [%fall %& [/ %directory] [[/ %noun] [%1 *registry-store]]]
          [%stay %& [/ %'grant.json']]
          [%fall %& [/ %seen] [[/ %noun] [%1 ~ ~]]]
          [%fall %& [/ %limits] [[/ %noun] [%1 ~]]]
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
          ::  and drops it when that fiber dies (phase 0, spike B). An ask
          ::  is answered once it is applied, refused or not
          [~ %'main.sig']
        ;<  ~  bind:m  (rise-later 0 prod "%furum writer: failed")
        ::  jailed (no clock yet), the approval reload does this
        ;<  clock=(unit @da)  bind:m  soft-now
        ;<  ~  bind:m  ?~(clock (pure:m ~) ;<(~ bind:m grant-public sweep-all))
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
        ;<  ~  bind:m  (rise-later 0 prod "%furum inbox: failed")
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
        ;<  ~  bind:m  (rise-later 0 prod "%furum web: failed")
        ;<  ~  bind:m  (bind-http-self:io [~ /apps/furum])
        (http-dispatch:io %furum)
          ::  auto-prune: at each slot of the 6-hour grid, the writer
          ::  prunes every board that asks for it
          [~ %'prune.sig']
        ;<  ~  bind:m  (rise-later 0 prod "%furum prune: failed")
        |-
        ;<  now=@da  bind:m  get-time:io
        ;<  ~  bind:m  (sleep:io (sub (prune-at:fr now) now))
        ;<  *  bind:m  (poke-soft:io (rf 0 / %'main.sig') [[/furum %op] `op`[%prune ~]])
        $
          ::  the sweeper: when a member's time runs out, the writer
          ::  takes the ship out of the board's group
          [~ %'sweep.sig']
        ;<  ~  bind:m  (rise-later 0 prod "%furum sweep: failed")
        ;<  *  bind:m  (keep-soft:io /s (rf 0 / %sweep) ~ ~s30)
        sweeper
          ::  this ship's copy of the registry's directory
          [~ %'dir.sig']
        ;<  ~  bind:m  (rise-later 0 prod "%furum directory: failed")
        read-registry
          ::  a follower: the mirror of one board on another ship
          [[%follows @ ~] @]
        ;<  ~  bind:m  (rise-later 2 prod "%furum follower {(trip i.t.path.rail)}/{(trip name.rail)}: failed")
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
      [%sent name=@ta]
      [%prefs tags=(unit (set term)) registry=(unit @p)]
      [%reg who=@p here=path act=registry-action]
      [%sweep ~]
  ==
::  your preferences: dark mode, which notes push to your browsers, and
::  the ship whose directory you read
::
+$  prefs  [dark=? tags=(set term) registry=@p]
++  default-prefs  `prefs`[| (sy ~[%comments %new-posts %payments]) ~ricsul-bilwyt]
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
::  traced, and the boards stay local.
::
++  grant-public
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  reg=(unit tang)  bind:m  (reg-register-at-soft:io [/ %'main.sig'])
  ?^  reg  (trace:io [leaf+"%furum: no registry road; other ships cannot reach the inbox" u.reg])
  ;<  names=(list @ta)  bind:m  (board-names 0)
  ;<  open=(list road:tarball)  bind:m  (public-roads names)
  ;<  how=(unit tang)  bind:m
    %+  reg-how-soft:io  /public
    [~ (sy ~[(rf 0 / %'inbox.sig')]) (silt [(rf 0 / %registry) open])]
  ?~  how  (pure:m ~)
  (trace:io [leaf+"%furum: the registry refused the public grant" u.how])
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
      %prefs  ;<(~ bind:m (set-prefs +.u.o) (pure:m ~))
      %sent   ;<(* bind:m (cull-soft:io (rf 0 /outbox name.u.o)) (pure:m ~))
      %act    (do-act who.u.o action.u.o)
      %reg    (do-reg +.u.o)
      %sweep  ;<(~ bind:m sweep-all (pure:m ~))
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
++  toggle-dark
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs 0)
  (over:io (rf 0 / %prefs) [[/ %noun] [%2 pf(dark !dark.pf)]])
::
++  set-prefs
  |=  [tags=(unit (set term)) registry=(unit @p)]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs 0)
  =?  tags.pf  ?=(^ tags)  u.tags
  =?  registry.pf  ?=(^ registry)  u.registry
  (over:io (rf 0 / %prefs) [[/ %noun] [%2 pf]])
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
  ::
      %act
    ;<  res=(unit deny)  bind:m  (do-act src action.u.g)
    ?~  res  (pure:m ~)
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
  (keep-note title body url tags)
::  +note-to: a note for someone: kept here if it is for us, else sent
::  through the outbox
::
++  note-to
  |=  n=note-out
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ?:  =(our to.n)  (keep-note title.n body.n url.n tags.n)
  ;<  eny=@uvJ  bind:m  get-entropy:io
  %+  over:io  (rf 0 /outbox (scot %uv (end [3 8] eny)))
  [[/ %noun] `[@p msg]`[to.n %note title.n body.n url.n tags.n]]
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
  ?.  ok  (trace:io ~[leaf+"%furum: no usergroup road; paid boards stay closed to members"])
  ;<  how=(unit tang)  bind:m
    (reg-how-soft:io /[(grp name)] [~ ~ (sy ~[(rv 0 /boards/[name]/content)])])
  ?~  how  (pure:m ~)
  (trace:io [leaf+"%furum: the registry refused a member group" u.how])
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
::  +read-prefs: the owner's preferences; a first release's dark-mode
::  flag carries over
::
++  read-prefs
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,prefs)
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up / %prefs))
  ?~  n  (pure:m default-prefs)
  ?^  p=(mole |.(+:;;([%2 prefs] u.n)))  (pure:m u.p)
  =/  dp=prefs  default-prefs
  ?^  d=(mole |.(+:;;([%1 ?] u.n)))  (pure:m dp(dark u.d))
  (pure:m default-prefs)
::
++  read-dark
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,?)
  ^-  form:m
  ;<  pf=prefs  bind:m  (read-prefs up)
  (pure:m dark.pf)
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
::  grubs whose version moved. Every ten minutes (two, while a board is
::  closed to us) it copies again and asks again: a host that drops a
::  reader never says so, and one that lets a reader in doesn't either.
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
  ;<  w=(unit wave:nexus)  bind:m  (keep-soft:io /fp [%& %| (weld there /pub)] ~ ~s30)
  ?~  w
    ;<  ~  bind:m  (sleep:io (min ~h1 (mul ~m1 (bex (min tries 6)))))
    (follow host name +(tries))
  ;<  ~  bind:m  (sync-part there mine /pub)
  ;<  c=(unit wave:nexus)  bind:m  (open-content there mine)
  =/  lp=(map path cass:clay)  (wave-files /pub u.w)
  =/  lc=(map path cass:clay)  ?~(c ~ (wave-files /content u.c))
  =/  kept=?  ?=(^ c)
  |-
  ;<  now=@da  bind:m  get-time:io
  ;<  ~  bind:m  (set-timer:io /hb (add now ?:(kept ~m10 ~m2)))
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
    ;<  c=(unit wave:nexus)  bind:m  (open-content there mine)
    $(kept ?=(^ c), lc ?~(c ~ (wave-files /content u.c)))
  ==
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
::
++  read-registry
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ;<  pf=prefs  bind:m  (read-prefs 0)
  ?:  =(our registry.pf)
    ;<  *  bind:m  take-poke-from:io
    read-registry
  ;<  base=path  bind:m  (install-of 0 registry.pf)
  =/  there=path  (remote registry.pf base /)
  ;<  w=(unit wave:nexus)  bind:m  (keep-soft:io /r [%& %& there %registry] ~ ~s30)
  |-
  ;<  vw=(unit (unit view:nexus))  bind:m
    ((with-timeout:io (unit view:nexus)) /reg ~s30 (peek-soft:io [%& %& there %registry] ~))
  ;<  ~  bind:m
    ?.  ?=([~ ~ %file *] vw)  (pure:m ~)
    =/  n=*  (sang-noun:tarball sang.u.u.vw)
    ?~  (mole |.(;;([%1 registry-store] n)))  (pure:m ~)
    (over:io (rf 0 / %directory) [[/ %noun] n])
  ;<  now=@da  bind:m  get-time:io
  ;<  ~  bind:m  (set-timer:io /rh (add now ~h1))
  ;<  e=?(%news %again)  bind:m  take-reg
  ;<  ~  bind:m  (cancel-timer:io /rh)
  ?:  ?=(%again e)  read-registry
  $
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
  ;<  base=path  bind:m  (install-of 1 to.o)
  ;<  *  bind:m
    %+  (with-timeout:io (unit tang))  /o
    [~s30 (poke-soft:io [%& %& (remote to.o base /) %'inbox.sig'] [[/furum %msg] msg.o])]
  (tell [%sent name])
::  ==  HTTP
::
::  what a request fiber knows about its request
::
+$  ctx  [id=@ta our=@p now=@da dark=? site=(list @t) args=(map @t @t)]
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
    ?:  &(get ?=([%b @ @ *] site))  (serve-public [id our now %.n site args])
    (send-page id 403 (render-error:fl "not authenticated" %.n))
  ;<  dark=?  bind:m  (read-dark 1)
  =/  c=ctx  [id our now dark site args]
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
  =/  denied  (send-page id.c 403 (render-error:fl "not authenticated" %.n))
  ?.  ?=([%b @ @ ?(~ [@ ~])] site.c)  denied
  ?.  =(`our.c (slaw %p i.t.site.c))  denied
  ;<  b=(each (unit board) @t)  bind:m  (read-board our.c i.t.t.site.c)
  ?.  ?=([%& ~ *] b)  denied
  =/  brd=board  u.p.b
  ?.  &(public.info.brd ?=(~ payment.brd))  denied
  ?~  t.t.t.site.c
    %^  send-page  id.c  200
    %:  render-board:fl  our.c  info.brd  ~(val by posts.brd)  our.c  now.c
      %.n  %.n  %.n  (parse-sort:fl args.c)  %.n  (parse-page:fl args.c)  pinned.brd  ~  sidebar.brd
    ==
  ?~  pid=(parse-id:fl i.t.t.t.site.c)  (send-page id.c 404 (render-error:fl "post not found" %.n))
  ?~  pst=(~(get by posts.brd) u.pid)  (send-page id.c 404 (render-error:fl "post not found" %.n))
  %^  send-page  id.c  200
  %:  render-post-page:fl  our.c  info.brd  u.pst  (~(gut by comments.brd) u.pid ~)
    our.c  now.c  %.n  %.n  %.n  pinned.brd  ~
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
      [%guide ~]         (send-page id.c 200 (render-guide:fl dark.c))
      [%create ~]        (send-page id.c 200 (render-create:fl dark.c))
  ::  no %storage road yet: the upload button says S3 is not set up
      [%s3-config ~]     (send-json id.c [%o ~])
  ::
      [%notifications ~]
    ;<  notes=(list notification)  bind:m  (read-notes 1)
    (send-page id.c 200 (render-notifications:fl notes now.c dark.c))
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
    %:  render-admin:fl  our.c  dark.c  all  =(our.c registry.pf)
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
      (arg 'title')  (arg 'url')  (arg 'text')  dark.c
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
    (send-page id.c 200 (render-feed:fl feed our.c now.c dark.c pg boards.s))
  ;<  st=registry-store  bind:m  (read-directory 1)
  ;<  pf=prefs  bind:m  (read-prefs 1)
  =/  entries=(list directory-entry)  ~(val by dir.st)
  =/  tags=(set @tas)  (roll entries |=([e=directory-entry a=(set @tas)] (~(uni in a) tags.e)))
  =/  bwn=(set [@p board-name])
    %-  silt
    %+  murn  ~(tap by known)
    |=  [k=[@p board-name] b=board]
    ?~  last=(~(get by boards.s) k)  ~
    =/  newest  (roll (turn ~(val by posts.b) |=(p=post created.p)) max)
    ?.((gth newest u.last) ~ `k)
  =/  reg=?  =(our.c registry.pf)
  ?+    site.c
      (send-page id.c 200 (render-home:fl entries %all ~ tags reg dark.c bwn))
      [%curated ~]
    =/  cur  (skim entries |=(e=directory-entry curated.e))
    (send-page id.c 200 (render-home:fl cur %curated ~ tags reg dark.c bwn))
  ::
      [%tag @ ~]
    =/  tag=@tas  ;;(@tas i.t.site.c)
    =/  tagged  (skim entries |=(e=directory-entry (~(has in tags.e) tag)))
    (send-page id.c 200 (render-home:fl tagged %tag `tag tags reg dark.c bwn))
  ==
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
  ?:  ?=([%submit ~] rest)  (send-page id.c 200 (render-submit:fl u.host name dark.c))
  ;<  b=(each (unit board) @t)  bind:m  (read-board u.host name)
  ?:  ?=(%| -.b)  (err c 500 (trip p.b))
  ?~  p.b
    ?:  |(local !(valid-board-name:fl name))  (err c 404 "board not found")
    ;<  ~  bind:m  (tell [%watch u.host name])
    (send-page id.c 200 (render-loading:fl (weld "/apps/furum" (trip (spat site.c))) dark.c))
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
  ?:  &(closed ?=(^ payment.brd))
    (send-page id.c 200 (render-paywall:fl u.host info.brd u.payment.brd ~ dark.c %.n))
  ?+    rest  (err c 404 "page not found")
      ~
    ;<  s=seen  bind:m  (read-seen 1)
    ;<  fol=(set [@p board-name])  bind:m  (read-feed 1)
    ;<  ~  bind:m  (tell [%seen u.host name ~])
    %^  send-page  id.c  200
    %:  render-board:fl  u.host  info.brd  ~(val by posts.brd)  our.c  now.c
      mod  %.y  dark.c  (parse-sort:fl args.c)  (~(has in fol) [u.host name])
      (parse-page:fl args.c)  pinned.brd  (~(get by boards.s) [u.host name])  sidebar.brd
    ==
  ::
      [%mod %backup-proofs ~]  (err c 501 "paid boards arrive in a later release of furum")
      [%mod ~]
    ?.  mod  (err c 403 "not a moderator")
    %^  send-page  id.c  200
    %:  render-mod:fl  u.host  info.brd  roles.brd  local  dark.c  sidebar.brd  payment.brd
      wallet.brd  %.n  (~(gut by args.c) 'saved' '')  paid.brd  now.c  prune.brd
    ==
  ::
      [@ %edit ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    ?~  pst=(~(get by posts.brd) u.pid)  (err c 404 "post not found")
    ?.  =(our.c author.u.pst)  (err c 403 "only the author can edit this post")
    (send-page id.c 200 (render-edit-post:fl u.host name u.pst dark.c))
  ::
      [@ ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    ?~  pst=(~(get by posts.brd) u.pid)  (err c 404 "post not found")
    ;<  s=seen  bind:m  (read-seen 1)
    ;<  ~  bind:m  (tell [%seen u.host name `u.pid])
    %^  send-page  id.c  200
    %:  render-post-page:fl  u.host  info.brd  u.pst  (~(gut by comments.brd) u.pid ~)
      our.c  now.c  mod  %.y  dark.c  pinned.brd  (~(get by posts.s) [u.host name u.pid])
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
  ::  paying comes in phase 5
  ?:  ?=(?([%pay ~] [%pay-lightning ~] [%mod %melt ~]) rest)
    (err c 501 "paying for boards arrives in a later release of furum")
  ::  what only the host may change
  ?:  &(!local ?=([%mod ?(%prune %edit-info %public %delete %register %payment %grant %revoke) ~] rest))
    (err c 403 "only the board's host can change that")
  ?:  ?=([%mod %register ~] rest)
    ;<  b=(each (unit board) @t)  bind:m  (read-board our.c name)
    ?.  ?=([%& ~ *] b)  (err c 404 "board not found")
    =*  info  info.u.p.b
    ;<  *  bind:m  (register c [%register name title.info description.info])
    (redirect id.c "{base}/mod?saved=registered")
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
      [%mod %edit-info ~]  &+[[%edit-board-info name (f 'title') (f 'description')] "{base}/mod"]
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
  ::  a price makes the board paid; unticked, free again
      [%mod %payment ~]
    =/  mint=@t  (f 'mint-url')
    :+  %&
      :+  %set-payment  name
      ?.  =('on' (f 'enabled'))  ~
      `[(num 'price' 0) (mul ~d1 (max 1 (num 'interval' 30))) ?:(=('' mint) ~ `mint)]
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
  (send-page id.c code (render-error:fl msg dark.c))
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
  ?+    site  (raw 'image/svg+xml' furum-favicon-svg:fl)
      [%sw ~]
    %+  send-simple:srv  id
    :_  `(as-octs:mimes:html furum-sw-js:fl)
    [200 ~[['content-type' 'application/javascript'] ['service-worker-allowed' '/apps/furum']]]
  ::
      [%icon ~]
    ?~  jpg=(de:base64:mimes:html furum-icon-b64:fl)  (raw 'image/svg+xml' furum-favicon-svg:fl)
    (send-simple:srv id [[200 ~[['content-type' 'image/jpeg']]] jpg])
  ::
      [%manifest ~]
    %+  raw  'application/manifest+json'
    %:  rap  3
      '{"name":"furum","short_name":"furum","start_url":"/apps/furum",'
      '"display":"standalone","background_color":"#f6f6ef","theme_color":"#cc2020",'
      '"icons":[{"src":"/apps/furum/icon","sizes":"200x200","type":"image/jpeg"}],'
      '"share_target":{"action":"/apps/furum/share","method":"GET",'
      '"params":{"title":"title","text":"text","url":"url"}}}'
      ~
    ==
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
  |=  [up=@ud =prod:fiber:nexus msg=tape]
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
  ;<  log=json  bind:m  (read-json (rf up / %'rise.json'))
  =/  plan  (rise-plan:fr (gj:fr log key) crash now)
  ?.  (gth until.plan now)  (pure:m ~)
  ;<  ~  bind:m
    =/  m  (fiber:fiber:nexus ,~)
    ?.  crash  (pure:m ~)
    %-  %-  slog
        ?:  (lte n.plan 2)  [leaf+msg u.prod]
        ~[leaf+"{msg} again ({(a-co:co n.plan)} times running); next try in {(a-co:co (div (sub until.plan now) ~m1))} min"]
    ;<  *  bind:m
      %^  over-as-soft:io  (rf up / %'rise.json')
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
