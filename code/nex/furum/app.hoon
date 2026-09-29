::  furum: decentralized forums, as a grubbery nexus. The plan, and the
::  reasons for its shape, are in docs/grubbery-migration.md.
::
::  The tree this nexus owns (every persistent path has a row in +on-load):
::    /main.sig            the writer: every mutation goes through it
::    /inbox.sig           the one road another ship may poke (+grant-public)
::    /web.sig             binds /apps/furum; one fiber per request
::    /prune.sig           the auto-prune tick, on a 6-hour grid
::    /requests/<id>       the ephemeral request fibers
::    /boards/<name>/…     one board, in the grubs lib/furum-board names
::    /follows/<host>/<name>  a board you follow
::    /prefs  /seen  /limits  dark mode; what you last read; rate limits
::    /tr/last  /tr/inbox  the writer's last refusal; what other ships poked
::    /rise.json           per fiber, its crashes in a row and its next try
::    tile, link, weir and icon: laid fresh on every load
::
::  ROADS ARE NEXUS-RELATIVE. A desk-installed app cannot learn its own
::  absolute path, so every road is [%| up lane], where up is the number
::  of steps from the calling fiber to the nexus root: 0 for the fibers
::  at the root, 1 for a request fiber at /requests/<id>.
::
::  THE WRITER MUST NOT CRASH. Every refusal is a branch that returns
::  cleanly and writes /tr/last. A request that must see its write asks
::  ([/furum %ask]) and the writer answers it once the tree has changed.
::
/<  *   /lib/furum-types.hoon
/<  fr  /lib/furum-rules.hoon
/<  fl  /lib/furum.hoon
/<  fb  /lib/furum-board.hoon
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
          [%fall %| /requests empty-dir:loader]
          [%fall %| /boards empty-dir:loader]
          [%fall %| /follows empty-dir:loader]
          [%fall %& [/ %prefs] [[/ %noun] [%1 |]]]
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
        ;<  ~  bind:m  (rise-later prod "%furum writer: failed")
        ;<  ~  bind:m  grant-public
        |-
        ;<  [=from:fiber:nexus =sage:tarball]  bind:m  take-poke-from:io
        ;<  res=(unit deny:fb)  bind:m  (apply from sage)
        ;<  ~  bind:m
          ?.  =([/furum %ask] p.sage)  (pure:m ~)
          ;<  *  bind:m  (poke-soft:io [%| p.from %& q.from] [[/furum %done] res])
          (pure:m ~)
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
          ::  auto-prune: at each slot of the 6-hour grid, the writer
          ::  prunes every board that asks for it
          [~ %'prune.sig']
        ;<  ~  bind:m  (rise-later prod "%furum prune: failed")
        |-
        ;<  now=@da  bind:m  get-time:io
        ;<  ~  bind:m  (sleep:io (sub (prune-at:fr now) now))
        ;<  *  bind:m  (poke-soft:io (rf 0 / %'main.sig') [[/furum %op] `op`[%prune ~]])
        $
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
  $%  [%inbox src=@p mark=blot:tarball]
      [%act who=@p =action]
      [%seen host=@p name=board-name pid=(unit post-id)]
      [%prune ~]
  ==
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
::  +apply: one op from a poke, answered with why it was refused, or ~.
::  Only this nexus's own fibers may write.
::
++  apply
  |=  [=from:fiber:nexus =sage:tarball]
  =/  m  (fiber:fiber:nexus ,(unit deny:fb))
  ^-  form:m
  ?^  (get-poke-src:io from)  (refuse 403 'a ship may not write here')
  ?.  |(=([/furum %op] p.sage) =([/furum %ask] p.sage))  (refuse 400 'not an op')
  =/  o=(unit op)  (mole |.(;;(op q.q.sage)))
  ?~  o  (refuse 400 'a malformed op')
  ?-    -.u.o
      %inbox  ;<(~ bind:m (trace-inbox src.u.o mark.u.o) (pure:m ~))
      %seen   ;<(~ bind:m (write-seen +.u.o) (pure:m ~))
      %prune  ;<(~ bind:m prune-all (pure:m ~))
      %act    (do-act who.u.o action.u.o)
  ==
::  +refuse: a refused op, as the writer's last outcome at /tr/last
::
++  refuse
  |=  =deny:fb
  =/  m  (fiber:fiber:nexus ,(unit deny:fb))
  ^-  form:m
  ;<  now=@da  bind:m  get-time:io
  ;<  ~  bind:m
    %+  over:io  (rf 0 /tr %last)
    :-  [/ %json]
    %-  pairs:enjs:format
    :~  ['at' s+(scot %da now)]
        ['code' (numb:enjs:format code.deny)]
        ['why' s+why.deny]
    ==
  (pure:m `deny)
::  +do-act: one user action, by `who`
::
++  do-act
  |=  [who=@p =action]
  =/  m  (fiber:fiber:nexus ,(unit deny:fb))
  ^-  form:m
  ;<  our=@p  bind:m  get-our:io
  ?:  ?=(%mark-notifications-read -.action)  (pure:m ~)
  ?:  ?=(?(%toggle-dark-mode %follow-board %unfollow-board) -.action)
    ?.  =(who our)  (refuse 403 'only the owner keeps these preferences')
    ?-  -.action
      %toggle-dark-mode  ;<(~ bind:m toggle-dark (pure:m ~))
      %follow-board      ;<(~ bind:m (over:io (rf 0 /follows/(scot %p host.action) name.action) [[/ %noun] [%1 ~]]) (pure:m ~))
    ::  soft: unfollowing twice culls nothing, and must not fail the writer
      %unfollow-board
    ;<  *  bind:m  (cull-soft:io (rf 0 /follows/(scot %p host.action) name.action))
    (pure:m ~)
    ==
  =/  name=(unit board-name)  (board-of action)
  ?~  name  (refuse 501 'not in this release of furum')
  ::  a name no board can have is never made into a path
  ?.  (valid-board-name:fl u.name)
    ?:  ?=(%create-board -.action)  (refuse 400 'board names may only use a-z, 0-9 and -')
    (refuse 404 'board not found')
  ;<  now=@da  bind:m  get-time:io
  ;<  old=(map path *)  bind:m  (read-grubs 0 u.name)
  =/  have=(each (unit board) @t)
    ?:  =(~ old)  &+~
    =/  r  (load:fb ~(tap by old))
    ?:(?=(%| -.r) r &+`p.r)
  ?:  ?=(%| -.have)  (refuse 500 p.have)
  ;<  lim=limits  bind:m  read-limits
  =/  r  (act:fb who our now action p.have lim)
  ?:  ?=(%| -.r)  (refuse p.r)
  ;<  ~  bind:m  (store u.name old brd.p.r)
  ;<  ~  bind:m
    ?:  =(lim lim.p.r)  (pure:(fiber:fiber:nexus ,~) ~)
    (over:io (rf 0 / %limits) [[/ %noun] [%1 lim.p.r]])
  (pure:m ~)
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
  ;<  dark=?  bind:m  (read-dark 0)
  (over:io (rf 0 / %prefs) [[/ %noun] [%1 !dark]])
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
::  ==  reading the tree; `up` is the reader's depth below the nexus root
::
::  +read-grubs: a board directory's grubs by path, ~ when there is none
::
++  read-grubs
  |=  [up=@ud name=board-name]
  =/  m  (fiber:fiber:nexus ,(map path *))
  ^-  form:m
  ;<  vw=view:nexus  bind:m  (peek:io (rv up /boards/[name]) ~)
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
++  read-dark
  |=  up=@ud
  =/  m  (fiber:fiber:nexus ,?)
  ^-  form:m
  ;<  n=(unit *)  bind:m  (read-noun (rf up / %prefs))
  (pure:m (fall (mole |.(+:;;([%1 ?] (need n)))) |))
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
    ?:  &(get ?=([%b @ @ *] site))  (serve-public [id our now | site args])
    (send-page id 403 (render-error:fl "not authenticated" |))
  ;<  dark=?  bind:m  (read-dark 1)
  =/  c=ctx  [id our now dark site args]
  ?:  get  (serve-get c)
  ?.  =('POST' method.request.req)  (err c 405 "method not allowed")
  ?:  (cross-site:fr header-list.request.req)  (err c 403 "cross-site request refused")
  (serve-post c (parse-form:fl body.request.req) header-list.request.req)
::  +serve-public: a public board and its posts, to anyone. A board
::  that isn't public, or doesn't exist, answers alike.
::
++  serve-public
  |=  c=ctx
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  denied  (send-page id.c 403 (render-error:fl "not authenticated" |))
  ?.  ?=([%b @ @ ?(~ [@ ~])] site.c)  denied
  ?.  =(`our.c (slaw %p i.t.site.c))  denied
  ;<  b=(each (unit board) @t)  bind:m  (read-board i.t.t.site.c)
  ?.  ?=([%& ~ *] b)  denied
  =/  brd=board  u.p.b
  ?.  &(public.info.brd ?=(~ payment.brd))  denied
  ?~  t.t.t.site.c
    %^  send-page  id.c  200
    %:  render-board:fl  our.c  info.brd  ~(val by posts.brd)  our.c  now.c
      %.n  %.n  %.n  (parse-sort:fl args.c)  %.n  (parse-page:fl args.c)  pinned.brd  ~  sidebar.brd
    ==
  ?~  pid=(parse-id:fl i.t.t.t.site.c)  (send-page id.c 404 (render-error:fl "post not found" |))
  ?~  pst=(~(get by posts.brd) u.pid)  (send-page id.c 404 (render-error:fl "post not found" |))
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
      [%notifications ~]  (send-page id.c 200 (render-notifications:fl ~ now.c dark.c))
      [%notif-count ~]   (send-json id.c (pairs:enjs:format ~[['count' (numb:enjs:format 0)]]))
  ::  no %storage road yet: the upload button says S3 is not set up
      [%s3-config ~]     (send-json id.c [%o ~])
  ::
      [%admin ~]
    ;<  all=(list [board-name board])  bind:m  all-boards
    %^  send-page  id.c  200
    (render-admin:fl our.c dark.c all | ~ ~ ~ ~ (~(gut by args.c) 'msg' ''))
  ::
      [%share ~]
    ;<  all=(list [board-name board])  bind:m  all-boards
    ;<  fol=(list [@p board-name])  bind:m  read-follows
    =/  arg  |=(k=@t (~(gut by args.c) k ''))
    %^  send-page  id.c  200
    %:  render-share:fl
      (weld (turn all |=([n=board-name *] [our.c n])) fol)
      (arg 'title')  (arg 'url')  (arg 'text')  dark.c
    ==
  ==
::  +serve-home: the feed of followed boards, or the directory. Until the
::  registry comes (phase 3) the directory is this ship's own boards.
::
++  serve-home
  |=  c=ctx
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  all=(list [board-name board])  bind:m  all-boards
  ;<  s=seen  bind:m  (read-seen 1)
  ?:  &(?=(~ site.c) =('feed' (~(gut by args.c) 'view' 'feed')))
    ;<  fol=(list [@p board-name])  bind:m  read-follows
    =/  pg=@ud  (parse-page:fl args.c)
    =/  bm  (malt all)
    =/  feed=(list [host=@p board-name=board-name =post])
      %-  zing
      %+  turn  fol
      |=  [host=@p name=board-name]
      ^-  (list [host=@p board-name=board-name =post])
      ?.  =(host our.c)  ~
      ?~  b=(~(get by bm) name)  ~
      %+  turn  (scag (mul pg per-page:fl) (sort-posts-by-new:fl ~(val by posts.u.b)))
      |=(p=post [host name p])
    (send-page id.c 200 (render-feed:fl feed our.c now.c dark.c pg boards.s))
  =/  entries=(list directory-entry)
    (turn all |=([n=board-name b=board] [n title.info.b description.info.b our.c ~ |]))
  =/  bwn=(set [@p board-name])
    %-  silt
    %+  murn  all
    |=  [n=board-name b=board]
    ?~  last=(~(get by boards.s) [our.c n])  ~
    =/  newest  (roll (turn ~(val by posts.b) |=(p=post created.p)) max)
    ?.((gth newest u.last) ~ `[our.c n])
  ?+    site.c
      (send-page id.c 200 (render-home:fl entries %all ~ ~ | dark.c bwn))
      [%curated ~]
    =/  cur  (skim entries |=(e=directory-entry curated.e))
    (send-page id.c 200 (render-home:fl cur %curated ~ ~ | dark.c bwn))
  ::
      [%tag @ ~]
    =/  tag=@tas  ;;(@tas i.t.site.c)
    =/  tagged  (skim entries |=(e=directory-entry (~(has in tags.e) tag)))
    (send-page id.c 200 (render-home:fl tagged %tag `tag ~ | dark.c bwn))
  ==
::  +serve-board: a board this ship hosts and the pages under it. Boards
::  on other ships come with following (phase 3).
::
++  serve-board
  |=  c=ctx
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?.  ?=([%b @ @ *] site.c)  (err c 404 "page not found")
  ?~  host=(slaw %p i.t.site.c)  (err c 404 "board not found")
  ?.  =(u.host our.c)  (err c 404 "boards on other ships arrive in the next release of furum")
  =/  name=board-name  i.t.t.site.c
  =/  rest=(list @t)  t.t.t.site.c
  ?:  ?=([%submit ~] rest)  (send-page id.c 200 (render-submit:fl our.c name dark.c))
  ;<  b=(each (unit board) @t)  bind:m  (read-board name)
  ?:  ?=(%| -.b)  (err c 500 (trip p.b))
  ?~  p.b  (err c 404 "board not found")
  =/  brd=board  u.p.b
  =/  mod=?  (is-mod:fr our.c brd)
  ?+    rest  (err c 404 "page not found")
      ~
    ;<  s=seen  bind:m  (read-seen 1)
    ;<  fol=(list [@p board-name])  bind:m  read-follows
    ;<  ~  bind:m  (tell [%seen our.c name ~])
    %^  send-page  id.c  200
    %:  render-board:fl  our.c  info.brd  ~(val by posts.brd)  our.c  now.c
      mod  %.y  dark.c  (parse-sort:fl args.c)  (lien fol |=(f=[@p board-name] =(f [our.c name])))
      (parse-page:fl args.c)  pinned.brd  (~(get by boards.s) [our.c name])  sidebar.brd
    ==
  ::
      [%mod %backup-proofs ~]  (err c 501 "paid boards arrive in a later release of furum")
      [%mod ~]
    ?.  mod  (err c 403 "not a moderator")
    %^  send-page  id.c  200
    %:  render-mod:fl  our.c  info.brd  roles.brd  %.y  dark.c  sidebar.brd  payment.brd
      wallet.brd  %.n  (~(gut by args.c) 'saved' '')  paid.brd  now.c  prune.brd
    ==
  ::
      [@ %edit ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    ?~  pst=(~(get by posts.brd) u.pid)  (err c 404 "post not found")
    ?.  =(our.c author.u.pst)  (err c 403 "only the author can edit this post")
    (send-page id.c 200 (render-edit-post:fl our.c name u.pst dark.c))
  ::
      [@ ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    ?~  pst=(~(get by posts.brd) u.pid)  (err c 404 "post not found")
    ;<  s=seen  bind:m  (read-seen 1)
    ;<  ~  bind:m  (tell [%seen our.c name `u.pid])
    %^  send-page  id.c  200
    %:  render-post-page:fl  our.c  info.brd  u.pst  (~(gut by comments.brd) u.pid ~)
      our.c  now.c  mod  %.y  dark.c  pinned.brd  (~(get by posts.s) [our.c name u.pid])
    ==
  ==
::  +serve-post: the owner's forms, each an action the writer applies
::  before the redirect, so the page it lands on shows it
::
++  serve-post
  |=  [c=ctx form=(map @t @t) headers=(list [key=@t value=@t])]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  =/  f  |=(k=@t (~(gut by form) k ''))
  =/  back=tape  (trip (fall (get-header:http 'referer' headers) '/apps/furum'))
  ?+    site.c  (err c 404 "not found")
      [%dark-mode ~]            (ask-then c [%toggle-dark-mode ~] back)
      [%notifications %read ~]  (redirect id.c "/apps/furum/notifications")
      [%b @ @ *]                (serve-board-post c f back)
  ::
      [%create ~]
    =/  name=@t  (crip (cass (trip (f 'name'))))
    =/  =role  ?:(=('reader' (f 'default-role')) %reader %poster)
    %^  ask-then  c
      [%create-board name (f 'title') (f 'description') role]
    "/apps/furum/b/{(scow %p our.c)}/{(trip name)}"
  ==
::
++  serve-board-post
  |=  [c=ctx f=$-(@t @t) back=tape]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ?.  ?=([%b @ @ *] site.c)  (err c 404 "not found")
  ?~  host=(slaw %p i.t.site.c)  (err c 404 "board not found")
  ?.  =(u.host our.c)  (err c 404 "boards on other ships arrive in the next release of furum")
  =/  name=board-name  i.t.t.site.c
  =/  rest=(list @t)  t.t.t.site.c
  =/  base=tape  "/apps/furum/b/{(scow %p our.c)}/{(trip name)}"
  =/  txt  |=(k=@t ?:(=('' (f k)) ~ `(f k)))
  =/  num  |=([k=@t d=@ud] (fall (rush (f k) dum:ag) d))
  ?+    rest  (err c 404 "not found")
      [%submit ~]    (ask-then c [%new-post name (f 'title') (txt 'url') (txt 'body')] base)
      [%sidebar ~]   (ask-then c [%set-sidebar name (f 'sidebar')] "{base}/mod")
      [%follow ~]    (ask-then c [%follow-board our.c name] base)
      [%unfollow ~]  (ask-then c [%unfollow-board our.c name] base)
      [%mod %edit-info ~]  (ask-then c [%edit-board-info name (f 'title') (f 'description')] "{base}/mod")
      [%mod %delete ~]     (ask-then c [%delete-board name] "/apps/furum")
  ::  paid boards come in phase 5, the directory in phase 3
      ?([%pay ~] [%pay-lightning ~] [%mod %payment ~] [%mod %melt ~])
    (err c 501 "paid boards arrive in a later release of furum")
      [%mod %register ~]   (err c 501 "the board directory arrives in the next release of furum")
  ::
      [%vote ~]
    ?~  t=(parse-vote-target:fl (f 'target'))  (err c 400 "invalid vote target")
    =/  d=@t  (f 'dir')
    %^  ask-then  c
      ?:  =('up' d)  [%upvote name u.t]
      ?:  =('down' d)  [%downvote name u.t]
      [%remove-vote name u.t]
    back
  ::
      [%mod %prune ~]
    =/  prune=(unit prune-config)
      ?.  =('on' (f 'prune-enabled'))  ~
      `[(num 'min-score' 2) (mul ~d1 (num 'after-days' 7))]
    (ask-then c [%set-prune name prune] "{base}/mod")
  ::
      [%mod %public ~]
    ;<  b=(each (unit board) @t)  bind:m  (read-board name)
    ?.  ?=([%& ~ *] b)  (err c 404 "board not found")
    (ask-then c [%set-public name !public.info.u.p.b] "{base}/mod")
  ::
      [%mod %role ~]
    ?~  who=(slaw %p (f 'who'))  (err c 400 "that is not a ship name")
    =/  r=@t  (f 'role')
    =/  =role  ?:(=('mod' r) %mod ?:(=('poster' r) %poster %reader))
    (ask-then c [%set-role name u.who role] "{base}/mod")
  ::
      [%mod %remove-role ~]
    ?~  who=(slaw %p (f 'who'))  (err c 400 "that is not a ship name")
    (ask-then c [%remove-role name u.who] "{base}/mod")
  ::
      [@ %edit ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    (ask-then c [%edit-post name u.pid (f 'title') (txt 'body')] "{base}/{(a-co:co u.pid)}")
  ::
      [@ %comment ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    =/  parent=(unit comment-id)  ?:(=('' (f 'parent')) ~ (parse-id:fl (f 'parent')))
    (ask-then c [%new-comment name u.pid parent (f 'body')] "{base}/{(a-co:co u.pid)}")
  ::
      [@ %delete ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    (ask-then c [%delete-post name u.pid] base)
  ::
      [@ %delete-comment ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    ?~  cid=(parse-id:fl (f 'comment-id'))  (err c 400 "invalid comment")
    (ask-then c [%delete-comment name u.pid u.cid] "{base}/{(a-co:co u.pid)}")
  ::
      [@ %pin ~]
    ?~  pid=(parse-id:fl i.rest)  (err c 404 "post not found")
    (ask-then c [%pin-post name u.pid =('true' (f 'pinned'))] base)
  ==
::  ==  talking to the writer
::
::  +ask-then: one action, applied, then the redirect; a refusal is an
::  error page with the writer's reason
::
++  ask-then
  |=  [c=ctx =action to=tape]
  =/  m  (fiber:fiber:nexus ,~)
  ^-  form:m
  ;<  res=(unit deny:fb)  bind:m  (ask [%act our.c action])
  ?~  res  (redirect id.c to)
  (err c code.u.res (trip why.u.res))
::  +ask: an op the writer answers once applied. A writer waiting after a
::  crash refuses the poke at once; one that never answers times out.
::
++  ask
  |=  =op
  =/  m  (fiber:fiber:nexus ,(unit deny:fb))
  ^-  form:m
  ;<  err=(unit tang)  bind:m  (poke-soft:io (rf 1 / %'main.sig') [[/furum %ask] op])
  ?^  err  (pure:m `[503 'furum is recovering from a crash; try again in a minute'])
  ;<  res=(unit (unit deny:fb))  bind:m  ((with-timeout:io (unit deny:fb)) /ask ~s30 take-done)
  ?~  res  (pure:m `[504 'furum took too long to answer; try again'])
  (pure:m u.res)
::
++  take-done
  =/  m  (fiber:fiber:nexus ,(unit deny:fb))
  ^-  form:m
  |=  input:fiber:nexus
  :+  ~  q.state
  ?+  in  [%skip ~]
      ~  [%wait ~]
      [~ %poke * *]
    ?.  =([/furum %done] p.sage.u.in)  [%skip ~]
    [%done (fall (mole |.(;;((unit deny:fb) q.q.sage.u.in))) `[500 'the writer answered nonsense'])]
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
::  +read-board: one board by name; ~ when there is none, or why it won't
::  load
::
++  read-board
  |=  name=@t
  =/  m  (fiber:fiber:nexus ,(each (unit board) @t))
  ^-  form:m
  ?.  (valid-board-name:fl name)  (pure:m &+~)
  ;<  gs=(map path *)  bind:m  (read-grubs 1 name)
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
::
++  read-follows
  =/  m  (fiber:fiber:nexus ,(list [@p board-name]))
  ^-  form:m
  ;<  vw=view:nexus  bind:m  (peek:io (rv 1 /follows) ~)
  ?.  ?=(%ball -.vw)  (pure:m ~)
  %-  pure:m
  %+  murn  ~(tap in ~(key by (ball-grubs ball.vw)))
  |=  p=path
  ?.  ?=([@ @ ~] p)  ~
  ?~  h=(slaw %p i.p)  ~
  `[u.h `board-name`i.t.p]
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
