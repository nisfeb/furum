::  app/furum.hoon: decentralized forum agent
::
::  serves three roles depending on context:
::  - registry: maintains directory of boards (on hardcoded registry ship)
::  - host: hosts boards with posts, comments, votes, permissions
::  - client: subscribes to registry and hosts, caches data, serves UI
::
/-  *furum
/+  default-agent, dbug, fl=furum
|%
+$  old-board-info
  $:  name=board-name
      title=@t
      description=@t
      host=@p
      created=@da
      default-role=role
  ==
+$  old-board
  $:  info=old-board-info
      roles=(map @p role)
      next-post-id=post-id
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      next-comment-ids=(map post-id comment-id)
  ==
+$  old-cached-board
  $:  info=old-board-info
      roles=(map @p role)
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
  ==
+$  s4-board
  $:  info=board-info
      roles=(map @p role)
      next-post-id=post-id
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      next-comment-ids=(map post-id comment-id)
  ==
+$  s4-cached-board
  $:  info=board-info
      roles=(map @p role)
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
  ==
+$  s6-board
  $:  info=board-info
      roles=(map @p role)
      next-post-id=post-id
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      next-comment-ids=(map post-id comment-id)
      pinned=(set post-id)
  ==
+$  s6-cached-board
  $:  info=board-info
      roles=(map @p role)
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      pinned=(set post-id)
  ==
::
+$  versioned-state
  $%  state-2
      state-3
      state-4
      state-5
      state-6
      state-7
  ==
::
+$  state-2
  $:  %2
      registry=(map board-name directory-entry)
      boards=(map board-name old-board)
      cache=(map [@p board-name] old-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
  ==
::
+$  state-3
  $:  %3
      registry=(map board-name directory-entry)
      boards=(map board-name s4-board)
      cache=(map [@p board-name] s4-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
  ==
::
+$  state-4
  $:  %4
      registry=(map board-name directory-entry)
      boards=(map board-name s4-board)
      cache=(map [@p board-name] s4-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
  ==
::
+$  state-5
  $:  %5
      registry=(map board-name directory-entry)
      boards=(map board-name s6-board)
      cache=(map [@p board-name] s6-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
  ==
::
+$  state-6
  $:  %6
      registry=(map board-name directory-entry)
      boards=(map board-name s6-board)
      cache=(map [@p board-name] s6-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
      board-seen=(map [@p board-name] @da)
      post-seen=(map [@p board-name post-id] @da)
  ==
::
+$  state-7
  $:  %7
      registry=(map board-name directory-entry)
      boards=(map board-name board)
      cache=(map [@p board-name] cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
      board-seen=(map [@p board-name] @da)
      post-seen=(map [@p board-name post-id] @da)
  ==
::
+$  card  card:agent:gall
--
::
=>
|%
++  registry-ship  ~ricsul-bilwyt-dozzod-nisfeb
::
++  get-role
  |=  [who=@p brd=board]
  ^-  role
  ?:  =(who host.info.brd)  %mod
  =/  explicit  (~(get by roles.brd) who)
  ?~  explicit  default-role.info.brd
  u.explicit
::
++  is-mod
  |=  [who=@p brd=board]
  ^-  ?
  =(%mod (get-role who brd))
::
++  can-post
  |=  [who=@p brd=board]
  ^-  ?
  =/  =role  (get-role who brd)
  ?|  =(role %mod)
      =(role %poster)
  ==
::
++  can-read
  |=  [who=@p brd=board]
  ^-  ?
  %.y
::
++  can-delete
  |=  [who=@p author=@p brd=board]
  ^-  ?
  ?|  =(who author)
      (is-mod who brd)
  ==
::
++  give-board-update
  |=  [name=board-name upd=update]
  ^-  card
  [%give %fact ~[/board/[name]] %furum-update !>(upd)]
::
--
::
%-  agent:dbug
=|  state-7
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  [%pass /eyre/connect %arvo %e %connect [~ /apps/furum] dap.bowl]
      [%pass /registry %agent [registry-ship %furum] %watch /directory]
  ==
::
++  on-save  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
      %2
    ::  migrate boards: add public=%.n to each board-info, then pinned
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=old-board
      ^-  board
      =/  ni=board-info  [name.info.ob title.info.ob description.info.ob host.info.ob created.info.ob default-role.info.ob %.n]
      [ni roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob *(set post-id) '']
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=old-cached-board
      ^-  cached-board
      =/  ni=board-info  [name.info.oc title.info.oc description.info.oc host.info.oc created.info.oc default-role.info.oc %.n]
      [ni roles.oc posts.oc comments.oc *(set post-id) '']
    `this(state [%7 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old *(set [@p board-name]) *(map [@p board-name] @da) *(map [@p board-name post-id] @da)])
  ::
      %3
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s4-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob *(set post-id) '']
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s4-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc *(set post-id) '']
    `this(state [%7 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old *(set [@p board-name]) *(map [@p board-name] @da) *(map [@p board-name post-id] @da)])
  ::
      %4
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s4-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob *(set post-id) '']
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s4-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc *(set post-id) '']
    `this(state [%7 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old *(map [@p board-name] @da) *(map [@p board-name post-id] @da)])
  ::
      %5
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s6-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob '']
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s6-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc pinned.oc '']
    `this(state [%7 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old *(map [@p board-name] @da) *(map [@p board-name post-id] @da)])
  ::
      %6
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s6-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob '']
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s6-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc pinned.oc '']
    `this(state [%7 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old])
  ::
    %7  `this(state old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  (on-poke:def mark vase)
      %furum-action
    =/  act  !<(action vase)
    (handle-action act)
  ::
      %furum-registry-action
    =/  act  !<(registry-action vase)
    (handle-registry-action act)
  ::
      %handle-http-request
    =/  req  !<([@ta inbound-request:eyre] vase)
    (handle-http req)
  ==
  ::
  ++  handle-action
    |=  act=action
    ^-  (quip card _this)
    ?-    -.act
        %create-board
      ?>  =(src.bowl our.bowl)
      =/  =board-info
        :*  name.act
            title.act
            description.act
            our.bowl
            now.bowl
            default-role.act
            %.n
        ==
      =/  =board
        :*  info=board-info
            roles=*(map @p role)
            next-post-id=0
            posts=*(map post-id post)
            comments=*(map post-id (map comment-id comment))
            next-comment-ids=*(map post-id comment-id)
            pinned=*(set post-id)
            sidebar=''
        ==
      `this(boards (~(put by boards) name.act board))
    ::
        %delete-board
      ?>  =(src.bowl our.bowl)
      `this(boards (~(del by boards) name.act))
    ::
        %set-public
      ?>  =(src.bowl our.bowl)
      =/  brd  (~(got by boards) name.act)
      =/  new-info  info.brd(public public.act)
      =/  new-brd  brd(info new-info)
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%board-info-update new-info])
      ==
    ::
        %pin-post
      =/  brd  (~(got by boards) name.act)
      ?>  (is-mod src.bowl brd)
      =/  new-pinned=(set post-id)
        ?:(pinned.act (~(put in pinned.brd) id.act) (~(del in pinned.brd) id.act))
      =/  new-brd  brd(pinned new-pinned)
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%pin-update id.act pinned.act])
      ==
    ::
        %set-sidebar
      =/  brd  (~(got by boards) name.act)
      ?>  (is-mod src.bowl brd)
      =/  new-brd  brd(sidebar sidebar.act)
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%sidebar-update sidebar.act])
      ==
    ::
        %set-role
      =/  brd  (~(got by boards) name.act)
      ?>  (is-mod src.bowl brd)
      =/  new-roles  (~(put by roles.brd) who.act role.act)
      =/  new-brd  brd(roles new-roles)
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%role-update who.act `role.act])
      ==
    ::
        %remove-role
      =/  brd  (~(got by boards) name.act)
      ?>  (is-mod src.bowl brd)
      =/  new-roles  (~(del by roles.brd) who.act)
      =/  new-brd  brd(roles new-roles)
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%role-update who.act ~])
      ==
    ::
        %new-post
      =/  brd  (~(got by boards) name.act)
      ?>  (can-post src.bowl brd)
      =/  =post
        :*  id=next-post-id.brd
            author=src.bowl
            title=title.act
            url=url.act
            body=body.act
            created=now.bowl
            up-votes=*(set @p)
            down-votes=*(set @p)
            comment-count=0
        ==
      =/  new-brd
        %=  brd
          next-post-id  +(next-post-id.brd)
          posts          (~(put by posts.brd) id.post post)
          comments       (~(put by comments.brd) id.post *(map comment-id comment))
          next-comment-ids  (~(put by next-comment-ids.brd) id.post 0)
        ==
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%new-post post])
      ==
    ::
        %delete-post
      =/  brd  (~(got by boards) name.act)
      =/  =post  (~(got by posts.brd) id.act)
      ?>  (can-delete src.bowl author.post brd)
      =/  new-brd
        %=  brd
          posts           (~(del by posts.brd) id.act)
          comments        (~(del by comments.brd) id.act)
          next-comment-ids  (~(del by next-comment-ids.brd) id.act)
        ==
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%delete-post id.act])
      ==
    ::
        %edit-post
      =/  brd  (~(got by boards) name.act)
      =/  =post  (~(got by posts.brd) id.act)
      ?>  =(src.bowl author.post)
      =/  new-pst  post(title title.act, body body.act)
      =/  new-brd  brd(posts (~(put by posts.brd) id.act new-pst))
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%edit-post id.act title.act body.act])
      ==
    ::
        %new-comment
      =/  brd  (~(got by boards) name.act)
      ?>  (can-post src.bowl brd)
      =/  post-comments  (~(got by comments.brd) post.act)
      =/  next-cid  (~(got by next-comment-ids.brd) post.act)
      =/  =comment
        :*  id=next-cid
            parent=parent.act
            author=src.bowl
            body=body.act
            created=now.bowl
            up-votes=*(set @p)
            down-votes=*(set @p)
        ==
      =/  pst  (~(got by posts.brd) post.act)
      =/  new-brd
        %=  brd
          comments  (~(put by comments.brd) post.act (~(put by post-comments) next-cid comment))
          next-comment-ids  (~(put by next-comment-ids.brd) post.act +(next-cid))
          posts  (~(put by posts.brd) post.act pst(comment-count +(comment-count.pst)))
        ==
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%new-comment post.act comment])
      ==
    ::
        %delete-comment
      =/  brd  (~(got by boards) name.act)
      =/  post-comments  (~(got by comments.brd) post.act)
      =/  =comment  (~(got by post-comments) id.act)
      ?>  (can-delete src.bowl author.comment brd)
      =/  pst  (~(got by posts.brd) post.act)
      =/  new-brd
        %=  brd
          comments  (~(put by comments.brd) post.act (~(del by post-comments) id.act))
          posts  (~(put by posts.brd) post.act pst(comment-count (dec comment-count.pst)))
        ==
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%delete-comment post.act id.act])
      ==
    ::
        %resub
      ?>  =(src.bowl our.bowl)
      =/  key  [host.act name.act]
      :_  this(cache (~(del by cache) key), subs (~(put in subs) key))
      :~  [%pass /board/(scot %p host.act)/[name.act] %agent [host.act %furum] %leave ~]
          [%pass /board/(scot %p host.act)/[name.act] %agent [host.act %furum] %watch /board/[name.act]]
      ==
    ::
        %follow-board
      `this(followed (~(put in followed) [host.act name.act]))
    ::
        %unfollow-board
      `this(followed (~(del in followed) [host.act name.act]))
    ::
        %toggle-dark-mode
      ?:  (~(has in dark-mode) src.bowl)
        `this(dark-mode (~(del in dark-mode) src.bowl))
      `this(dark-mode (~(put in dark-mode) src.bowl))
    ::
        %upvote
      =/  brd  (~(got by boards) name.act)
      ?>  (can-read src.bowl brd)
      (apply-vote name.act brd target.act src.bowl %up)
    ::
        %downvote
      =/  brd  (~(got by boards) name.act)
      ?>  (can-read src.bowl brd)
      (apply-vote name.act brd target.act src.bowl %down)
    ::
        %remove-vote
      =/  brd  (~(got by boards) name.act)
      ?>  (can-read src.bowl brd)
      (apply-vote name.act brd target.act src.bowl %remove)
    ==
  ::
  ++  handle-registry-action
    |=  act=registry-action
    ^-  (quip card _this)
    ?>  =(our.bowl registry-ship)
    ?-    -.act
        %register
      =/  entry=directory-entry
        [name.act title.act description.act src.bowl *(set @tas) %.n]
      :_  this(registry (~(put by registry) name.act entry))
      :~  [%give %fact ~[/directory] %furum-registry-update !>(`registry-update`[%add entry])]
      ==
    ::
        %unregister
      =/  entry  (~(got by registry) name.act)
      ?>  =(src.bowl host.entry)
      :_  this(registry (~(del by registry) name.act))
      :~  [%give %fact ~[/directory] %furum-registry-update !>(`registry-update`[%remove name.act])]
      ==
    ::
        %tag-board
      ?>  =(our.bowl registry-ship)
      ?>  ?|  =(src.bowl our.bowl)
              (~(has in registry-admins) src.bowl)
          ==
      =/  entry  (~(got by registry) name.act)
      =/  new-tags  (~(put in tags.entry) tag.act)
      =/  new-entry  entry(tags new-tags)
      :_  this(registry (~(put by registry) name.act new-entry))
      :~  [%give %fact ~[/directory] %furum-registry-update !>(`registry-update`[%tag name.act new-tags])]
      ==
    ::
        %untag-board
      ?>  =(our.bowl registry-ship)
      ?>  ?|  =(src.bowl our.bowl)
              (~(has in registry-admins) src.bowl)
          ==
      =/  entry  (~(got by registry) name.act)
      =/  new-tags  (~(del in tags.entry) tag.act)
      =/  new-entry  entry(tags new-tags)
      :_  this(registry (~(put by registry) name.act new-entry))
      :~  [%give %fact ~[/directory] %furum-registry-update !>(`registry-update`[%tag name.act new-tags])]
      ==
    ::
        %curate-board
      ?>  =(our.bowl registry-ship)
      ?>  ?|  =(src.bowl our.bowl)
              (~(has in registry-admins) src.bowl)
          ==
      =/  entry  (~(got by registry) name.act)
      =/  new-entry  entry(curated curated.act)
      :_  this(registry (~(put by registry) name.act new-entry))
      :~  [%give %fact ~[/directory] %furum-registry-update !>(`registry-update`[%curate name.act curated.act])]
      ==
    ::
        %add-registry-admin
      ?>  =(our.bowl registry-ship)
      ?>  =(src.bowl our.bowl)
      `this(registry-admins (~(put in registry-admins) who.act))
    ::
        %remove-registry-admin
      ?>  =(our.bowl registry-ship)
      ?>  =(src.bowl our.bowl)
      `this(registry-admins (~(del in registry-admins) who.act))
    ==
  ::
  ++  handle-http
    |=  [eyre-id=@ta req=inbound-request:eyre]
    ^-  (quip card _this)
    =/  [pax=(list @t) args=(map @t @t)]
      (parse-request-url:fl url.request.req)
    ::  strip /apps/furum prefix
    =/  path=(list @t)
      ?.  ?&  ?=([@ @ *] pax)
              =(i.pax 'apps')
              =(i.t.pax 'furum')
          ==
        pax
      t.t.pax
    ::  serve manifest, icon, service worker, and about page without auth
    ?:  ?&  =('GET' method.request.req)
            ?|  =([%manifest ~] path)
                =([%sw ~] path)
                =([%icon ~] path)
                =([%favicon ~] path)
            ==
        ==
      (handle-get eyre-id path %.n args)
    ?:  ?&  =('GET' method.request.req)
            =([%about ~] path)
        ==
      (send-html eyre-id 200 (render-about:fl our.bowl))
    ::  serve public boards without auth
    ?:  ?&  =('GET' method.request.req)
            !authenticated.req
            ?=([%b @ @ *] path)
        ==
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?:  =(host our.bowl)
        =/  brd  (~(get by boards) name)
        ?.  ?&(?=(^ brd) public.info.u.brd)
          (send-html eyre-id 403 (render-error:fl "not authenticated" %.n))
        (handle-public-get eyre-id path args)
      (send-html eyre-id 403 (render-error:fl "not authenticated" %.n))
    ?.  authenticated.req
      (send-html eyre-id 403 (render-error:fl "not authenticated" %.n))
    ::  check dark mode preference for current user
    =/  dark=?  (~(has in dark-mode) our.bowl)
    ::  route based on method and path
    ?:  =('GET' method.request.req)
      (handle-get eyre-id path dark args)
    ?:  =('POST' method.request.req)
      (handle-post eyre-id path body.request.req header-list.request.req dark)
    (send-html eyre-id 405 (render-error:fl "method not allowed" dark))
  ::
  ++  handle-public-get
    |=  [eyre-id=@ta path=(list @t) args=(map @t @t)]
    ^-  (quip card _this)
    ?+    path
      (send-html eyre-id 404 (render-error:fl "page not found" %.n))
    ::  public board view: /b/{host}/{name}
        [%b @ @ ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  brd  (~(get by boards) name)
      ?~  brd
        (send-html eyre-id 404 (render-error:fl "board not found" %.n))
      =/  post-list=(list post)  ~(val by posts.u.brd)
      =/  srt  (parse-sort:fl args)
      =/  pg  (parse-page:fl args)
      (send-html eyre-id 200 (render-board:fl host info.u.brd post-list our.bowl now.bowl %.n %.n %.n srt %.n pg pinned.u.brd ~ sidebar.u.brd))
    ::  public post detail: /b/{host}/{name}/{post-id}
        [%b @ @ @ ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      =/  brd  (~(get by boards) name)
      ?~  brd
        (send-html eyre-id 404 (render-error:fl "board not found" %.n))
      =/  pst  (~(get by posts.u.brd) pid)
      ?~  pst
        (send-html eyre-id 404 (render-error:fl "post not found" %.n))
      =/  cmts  (~(gut by comments.u.brd) pid *(map comment-id comment))
      (send-html eyre-id 200 (render-post-page:fl host info.u.brd u.pst cmts our.bowl now.bowl %.n %.n %.n pinned.u.brd ~))
    ==
  ::
  ++  handle-get
    |=  [eyre-id=@ta path=(list @t) dark=? args=(map @t @t)]
    ^-  (quip card _this)
    ?+    path
      (send-html eyre-id 404 (render-error:fl "page not found" dark))
    ::  favicon (SVG)
        [%favicon ~]
      =/  svg=@t  furum-favicon-svg:fl
      =/  =response-header:http  [200 ~[['content-type' 'image/svg+xml']]]
      =/  data=octs  [(met 3 svg) svg]
      :_  this
      :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
          [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`data)]
          [%give %kick ~[/http-response/[eyre-id]] ~]
      ==
    ::  app icon
        [%icon ~]
      =/  b64=cord  furum-icon-b64:fl
      =/  decoded  (de:base64:mimes:html b64)
      ?~  decoded
        (send-html eyre-id 500 (render-error:fl "icon decode failed" dark))
      =/  =response-header:http  [200 ~[['content-type' 'image/jpeg']]]
      :_  this
      :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
          [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`u.decoded)]
          [%give %kick ~[/http-response/[eyre-id]] ~]
      ==
    ::  PWA manifest
        [%manifest ~]
      =/  manifest=@t
        %:  rap  3
          '{"name":"furum",'
          '"short_name":"furum",'
          '"start_url":"/apps/furum",'
          '"display":"standalone",'
          '"background_color":"#f6f6ef",'
          '"theme_color":"#cc2020",'
          '"icons":[{"src":"/apps/furum/icon","sizes":"200x200","type":"image/jpeg"}],'
          '"share_target":{"action":"/apps/furum/share","method":"GET",'
          '"params":{"title":"title","text":"text","url":"url"}}}'
          ~
        ==
      =/  =response-header:http  [200 ~[['content-type' 'application/manifest+json']]]
      =/  data=octs  [(met 3 manifest) manifest]
      :_  this
      :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
          [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`data)]
          [%give %kick ~[/http-response/[eyre-id]] ~]
      ==
    ::  service worker (required for PWA standalone mode)
        [%sw ~]
      =/  sw=@t  'self.addEventListener("fetch",function(e){});'
      =/  =response-header:http  [200 ~[['content-type' 'application/javascript'] ['service-worker-allowed' '/apps/furum']]]
      =/  data=octs  [(met 3 sw) sw]
      :_  this
      :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
          [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`data)]
          [%give %kick ~[/http-response/[eyre-id]] ~]
      ==
    ::  S3 storage config (JSON API for upload JS)
        [%s3-config ~]
      =/  get-str
        |=  [=json keys=(list @t)]
        ^-  @t
        ?~  keys  ?:(?=([%s *] json) p.json '')
        ?.  ?=([%o *] json)  ''
        =/  v  (~(get by p.json) i.keys)
        ?~  v  ''
        $(json u.v, keys t.keys)
      =/  cred-json=json
        .^(json %gx /(scot %p our.bowl)/storage/(scot %da now.bowl)/credentials/json)
      =/  conf-json=json
        .^(json %gx /(scot %p our.bowl)/storage/(scot %da now.bowl)/configuration/json)
      %-  send-json
      :+  eyre-id  200
      %-  pairs:enjs:format
      :~  ['endpoint' s+(get-str cred-json ~['storage-update' 'credentials' 'endpoint'])]
          ['accessKeyId' s+(get-str cred-json ~['storage-update' 'credentials' 'accessKeyId'])]
          ['secretAccessKey' s+(get-str cred-json ~['storage-update' 'credentials' 'secretAccessKey'])]
          ['bucket' s+(get-str conf-json ~['storage-update' 'configuration' 'currentBucket'])]
          ['region' s+(get-str conf-json ~['storage-update' 'configuration' 'region'])]
          ['publicUrlBase' s+(get-str conf-json ~['storage-update' 'configuration' 'publicUrlBase'])]
          ['service' s+(get-str conf-json ~['storage-update' 'configuration' 'service'])]
      ==
    ::  share target: receive shared content from OS share sheet
        [%share ~]
      =/  share-title=@t  (~(gut by args) 'title' '')
      =/  share-text=@t  (~(gut by args) 'text' '')
      =/  share-url=@t  (~(gut by args) 'url' '')
      ::  build list of boards user can post to: own boards + followed
      =/  own=(list [@p board-name])
        (turn ~(tap by boards) |=([n=board-name b=board] [our.bowl n]))
      =/  fol=(list [@p board-name])  ~(tap in followed)
      =/  all-boards=(list [@p board-name])
        (weld own fol)
      (send-html eyre-id 200 (render-share:fl all-boards share-title share-url share-text dark))
    ::  home: feed (default) or directory
        ~
      =/  home-view=@t  (~(gut by args) 'view' 'feed')
      ?:  =('feed' home-view)
        ::  collect posts from all followed boards
        =/  feed-posts=(list [host=@p board-name=board-name =post])
          %-  zing
          %+  turn  ~(tap in followed)
          |=  [host=@p name=board-name]
          ^-  (list [host=@p board-name=board-name =post])
          ?:  =(host our.bowl)
            =/  brd  (~(get by boards) name)
            ?~  brd  ~
            (turn ~(val by posts.u.brd) |=(p=post [host name p]))
          =/  cb  (~(get by cache) [host name])
          ?~  cb  ~
          (turn ~(val by posts.u.cb) |=(p=post [host name p]))
        =/  pg  (parse-page:fl args)
        (send-html eyre-id 200 (render-feed:fl feed-posts our.bowl now.bowl dark pg board-seen))
      =/  entries=(list directory-entry)  ~(val by registry)
      =/  all-tags=(set @tas)
        %+  roll  entries
        |=  [e=directory-entry acc=(set @tas)]
        (~(uni in acc) tags.e)
      =/  bwn=(set [@p board-name])
        %-  ~(gas in *(set [@p board-name]))
        %+  murn  entries
        |=  e=directory-entry
        ^-  (unit [@p board-name])
        =/  key  [host.e name.e]
        =/  last-seen  (~(get by board-seen) key)
        ?~  last-seen  ~
        =/  post-map=(map post-id post)
          ?:  =(host.e our.bowl)
            =/  brd  (~(get by boards) name.e)
            ?~(brd *(map post-id post) posts.u.brd)
          =/  cb  (~(get by cache) [host.e name.e])
          ?~(cb *(map post-id post) posts.u.cb)
        =/  newest=@da
          %+  roll  ~(val by post-map)
          |=  [p=post acc=@da]
          ?:((gth created.p acc) created.p acc)
        ?:  (gth newest u.last-seen)  `key
        ~
      (send-html eyre-id 200 (render-home:fl entries %all ~ all-tags =(our.bowl registry-ship) dark bwn))
    ::  curated boards
        [%curated ~]
      =/  entries=(list directory-entry)  ~(val by registry)
      =/  curated=(list directory-entry)
        (skim entries |=(e=directory-entry curated.e))
      =/  all-tags=(set @tas)
        %+  roll  entries
        |=  [e=directory-entry acc=(set @tas)]
        (~(uni in acc) tags.e)
      =/  bwn=(set [@p board-name])
        %-  ~(gas in *(set [@p board-name]))
        %+  murn  curated
        |=  e=directory-entry
        ^-  (unit [@p board-name])
        =/  key  [host.e name.e]
        =/  last-seen  (~(get by board-seen) key)
        ?~  last-seen  ~
        =/  post-map=(map post-id post)
          ?:  =(host.e our.bowl)
            =/  brd  (~(get by boards) name.e)
            ?~(brd *(map post-id post) posts.u.brd)
          =/  cb  (~(get by cache) [host.e name.e])
          ?~(cb *(map post-id post) posts.u.cb)
        =/  newest=@da
          %+  roll  ~(val by post-map)
          |=  [p=post acc=@da]
          ?:((gth created.p acc) created.p acc)
        ?:  (gth newest u.last-seen)  `key
        ~
      (send-html eyre-id 200 (render-home:fl curated %curated ~ all-tags =(our.bowl registry-ship) dark bwn))
    ::  boards filtered by tag
        [%tag @ ~]
      =/  tag=@tas  i.t.path
      =/  entries=(list directory-entry)  ~(val by registry)
      =/  tagged=(list directory-entry)
        (skim entries |=(e=directory-entry (~(has in tags.e) tag)))
      =/  all-tags=(set @tas)
        %+  roll  entries
        |=  [e=directory-entry acc=(set @tas)]
        (~(uni in acc) tags.e)
      =/  bwn=(set [@p board-name])
        %-  ~(gas in *(set [@p board-name]))
        %+  murn  tagged
        |=  e=directory-entry
        ^-  (unit [@p board-name])
        =/  key  [host.e name.e]
        =/  last-seen  (~(get by board-seen) key)
        ?~  last-seen  ~
        =/  post-map=(map post-id post)
          ?:  =(host.e our.bowl)
            =/  brd  (~(get by boards) name.e)
            ?~(brd *(map post-id post) posts.u.brd)
          =/  cb  (~(get by cache) [host.e name.e])
          ?~(cb *(map post-id post) posts.u.cb)
        =/  newest=@da
          %+  roll  ~(val by post-map)
          |=  [p=post acc=@da]
          ?:((gth created.p acc) created.p acc)
        ?:  (gth newest u.last-seen)  `key
        ~
      (send-html eyre-id 200 (render-home:fl tagged %tag `tag all-tags =(our.bowl registry-ship) dark bwn))
    ::  registry admin (registry host and delegates)
        [%registry ~]
      ?.  ?|  =(our.bowl registry-ship)
              (~(has in registry-admins) our.bowl)
          ==
        (send-html eyre-id 403 (render-error:fl "registry admin is only available to the registry host and delegates" dark))
      =/  entries=(list directory-entry)  ~(val by registry)
      (send-html eyre-id 200 (render-registry-admin:fl entries registry-admins =(our.bowl registry-ship) dark))
    ::  create board form
        [%create ~]
      (send-html eyre-id 200 (render-create:fl dark))
    ::  board view: /b/{host}/{name}
        [%b @ @ ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?:  =(host our.bowl)
        ::  local board
        =/  brd  (~(get by boards) name)
        ?~  brd
          (send-html eyre-id 404 (render-error:fl "board not found" dark))
        =/  post-list=(list post)  ~(val by posts.u.brd)
        =/  im=?  (is-mod our.bowl u.brd)
        =/  srt  (parse-sort:fl args)
        =/  ifl=?  (~(has in followed) [host name])
        =/  pg  (parse-page:fl args)
        =/  bls=(unit @da)  (~(get by board-seen) [host name])
        =.  board-seen  (~(put by board-seen) [host name] now.bowl)
        (send-html eyre-id 200 (render-board:fl host info.u.brd post-list our.bowl now.bowl im %.y dark srt ifl pg pinned.u.brd bls sidebar.u.brd))
      ::  remote board (from cache, auto-subscribe if needed)
      =/  cb  (~(get by cache) [host name])
      ?~  cb
        ?:  (~(has in subs) [host name])
          ::  already subscribed, waiting for data — auto-refresh
          (send-html eyre-id 200 (render-loading:fl "/apps/furum/b/{(scow %p host)}/{(trip name)}" dark))
        :_  this(subs (~(put in subs) [host name]))
        :~  [%pass /board/(scot %p host)/[name] %agent [host %furum] %watch /board/[name]]
            [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(`response-header:http`[303 ~[['location' (crip "/apps/furum/b/{(scow %p host)}/{(trip name)}")]]])]
            [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`(octs))]
            [%give %kick ~[/http-response/[eyre-id]] ~]
        ==
      =/  post-list=(list post)  ~(val by posts.u.cb)
      =/  mr  (~(get by my-roles) [host name])
      =/  im=?  ?~(mr %.n =(u.mr %mod))
      =/  srt  (parse-sort:fl args)
      =/  ifl=?  (~(has in followed) [host name])
      =/  pg  (parse-page:fl args)
      =/  bls=(unit @da)  (~(get by board-seen) [host name])
      =.  board-seen  (~(put by board-seen) [host name] now.bowl)
      (send-html eyre-id 200 (render-board:fl host info.u.cb post-list our.bowl now.bowl im %.y dark srt ifl pg pinned.u.cb bls sidebar.u.cb))
    ::  submit form: /b/{host}/{name}/submit
        [%b @ @ %submit ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      (send-html eyre-id 200 (render-submit:fl host name dark))
    ::  mod panel: /b/{host}/{name}/mod
        [%b @ @ %mod ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?:  =(host our.bowl)
        ::  local board
        =/  brd  (~(get by boards) name)
        ?~  brd
          (send-html eyre-id 404 (render-error:fl "board not found" dark))
        ?.  (is-mod our.bowl u.brd)
          (send-html eyre-id 403 (render-error:fl "not a moderator" dark))
        (send-html eyre-id 200 (render-mod:fl host info.u.brd roles.u.brd %.y dark sidebar.u.brd))
      ::  remote board - check my-roles
      =/  mr  (~(get by my-roles) [host name])
      ?.  ?~(mr %.n =(u.mr %mod))
        (send-html eyre-id 403 (render-error:fl "not a moderator" dark))
      =/  cb  (~(get by cache) [host name])
      ?~  cb
        (send-html eyre-id 404 (render-error:fl "board not found in cache" dark))
      (send-html eyre-id 200 (render-mod:fl host info.u.cb roles.u.cb %.n dark sidebar.u.cb))
    ::  edit post form: /b/{host}/{name}/{post-id}/edit
        [%b @ @ @ %edit ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      ?:  =(host our.bowl)
        =/  brd  (~(get by boards) name)
        ?~  brd
          (send-html eyre-id 404 (render-error:fl "board not found" dark))
        =/  pst  (~(get by posts.u.brd) pid)
        ?~  pst
          (send-html eyre-id 404 (render-error:fl "post not found" dark))
        ?.  =(our.bowl author.u.pst)
          (send-html eyre-id 403 (render-error:fl "only the author can edit this post" dark))
        (send-html eyre-id 200 (render-edit-post:fl host name u.pst dark))
      ::  remote: poke goes to remote, but edit form needs the post data from cache
      =/  cb  (~(get by cache) [host name])
      ?~  cb
        (send-html eyre-id 404 (render-error:fl "board not found in cache" dark))
      =/  pst  (~(get by posts.u.cb) pid)
      ?~  pst
        (send-html eyre-id 404 (render-error:fl "post not found" dark))
      ?.  =(our.bowl author.u.pst)
        (send-html eyre-id 403 (render-error:fl "only the author can edit this post" dark))
      (send-html eyre-id 200 (render-edit-post:fl host name u.pst dark))
    ::  post detail: /b/{host}/{name}/{post-id}
        [%b @ @ @ ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      ?:  =(host our.bowl)
        =/  brd  (~(get by boards) name)
        ?~  brd
          (send-html eyre-id 404 (render-error:fl "board not found" dark))
        =/  pst  (~(get by posts.u.brd) pid)
        ?~  pst
          (send-html eyre-id 404 (render-error:fl "post not found" dark))
        =/  cmts  (~(gut by comments.u.brd) pid *(map comment-id comment))
        =/  im=?  (is-mod our.bowl u.brd)
        =/  pls=(unit @da)  (~(get by post-seen) [host name pid])
        =.  post-seen  (~(put by post-seen) [host name pid] now.bowl)
        (send-html eyre-id 200 (render-post-page:fl host info.u.brd u.pst cmts our.bowl now.bowl im %.y dark pinned.u.brd pls))
      ::  remote (auto-subscribe if needed)
      =/  cb  (~(get by cache) [host name])
      ?~  cb
        ?:  (~(has in subs) [host name])
          (send-html eyre-id 200 (render-loading:fl "/apps/furum/b/{(scow %p host)}/{(trip name)}/{(a-co:co pid)}" dark))
        :_  this(subs (~(put in subs) [host name]))
        :~  [%pass /board/(scot %p host)/[name] %agent [host %furum] %watch /board/[name]]
            [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(`response-header:http`[303 ~[['location' (crip "/apps/furum/b/{(scow %p host)}/{(trip name)}/{(a-co:co pid)}")]]])]
            [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`(octs))]
            [%give %kick ~[/http-response/[eyre-id]] ~]
        ==
      =/  pst  (~(get by posts.u.cb) pid)
      ?~  pst
        (send-html eyre-id 404 (render-error:fl "post not found" dark))
      =/  cmts  (~(gut by comments.u.cb) pid *(map comment-id comment))
      =/  mr  (~(get by my-roles) [host name])
      =/  im=?  ?~(mr %.n =(u.mr %mod))
      =/  pls=(unit @da)  (~(get by post-seen) [host name pid])
      =.  post-seen  (~(put by post-seen) [host name pid] now.bowl)
      (send-html eyre-id 200 (render-post-page:fl host info.u.cb u.pst cmts our.bowl now.bowl im %.y dark pinned.u.cb pls))
    ==
  ::
  ++  handle-post
    |=  [eyre-id=@ta path=(list @t) body=(unit octs) headers=(list [key=@t value=@t]) dark=?]
    ^-  (quip card _this)
    =/  form  (parse-form:fl body)
    ?+    path
      (send-html eyre-id 404 (render-error:fl "not found" dark))
    ::  toggle dark mode: POST /dark-mode
        [%dark-mode ~]
      =^  cards  this  (handle-action [%toggle-dark-mode ~])
      =/  referer=tape
        =/  ref  (skim headers |=([k=@t *] =(k 'referer')))
        ?~  ref  "/apps/furum"
        (trip value.i.ref)
      =^  redir  this  (redirect eyre-id referer)
      [(weld cards redir) this]
    ::  add registry admin: POST /registry/add-admin
        [%registry %add-admin ~]
      =/  who-val=@t  (~(gut by form) 'who' '')
      =/  who=@p  (slav %p who-val)
      =^  cards  this  (handle-registry-action [%add-registry-admin who])
      =^  redir  this  (redirect eyre-id "/apps/furum/registry")
      [(weld cards redir) this]
    ::  remove registry admin: POST /registry/remove-admin
        [%registry %remove-admin ~]
      =/  who-val=@t  (~(gut by form) 'who' '')
      =/  who=@p  (slav %p who-val)
      =^  cards  this  (handle-registry-action [%remove-registry-admin who])
      =^  redir  this  (redirect eyre-id "/apps/furum/registry")
      [(weld cards redir) this]
    ::  tag board: POST /registry/tag
        [%registry %tag ~]
      =/  name=@t  (~(gut by form) 'name' '')
      =/  tag=@t  (~(gut by form) 'tag' '')
      =^  cards  this  (handle-registry-action [%tag-board (crip (cass (trip name))) (crip (cass (trip tag)))])
      =^  redir  this  (redirect eyre-id "/apps/furum/registry")
      [(weld cards redir) this]
    ::  untag board: POST /registry/untag
        [%registry %untag ~]
      =/  name=@t  (~(gut by form) 'name' '')
      =/  tag=@t  (~(gut by form) 'tag' '')
      =^  cards  this  (handle-registry-action [%untag-board (crip (cass (trip name))) (crip (cass (trip tag)))])
      =^  redir  this  (redirect eyre-id "/apps/furum/registry")
      [(weld cards redir) this]
    ::  curate board: POST /registry/curate
        [%registry %curate ~]
      =/  name=@t  (~(gut by form) 'name' '')
      =/  curated-val=@t  (~(gut by form) 'curated' '')
      =/  curated=?  =('true' curated-val)
      =^  cards  this  (handle-registry-action [%curate-board (crip (cass (trip name))) curated])
      =^  redir  this  (redirect eyre-id "/apps/furum/registry")
      [(weld cards redir) this]
    ::  create board: POST /create
        [%create ~]
      =/  name=@t  (~(gut by form) 'name' '')
      =/  title=@t  (~(gut by form) 'title' '')
      =/  desc=@t  (~(gut by form) 'description' '')
      =/  drole=@t  (~(gut by form) 'default-role' 'poster')
      =/  =role  ?:(=('reader' drole) %reader %poster)
      =/  act=action  [%create-board (crip (cass (trip name))) title desc role]
      =^  cards1  this  (handle-action act)
      =^  cards2  this
        ::  register with registry
        =/  bname  (crip (cass (trip name)))
        ?:  =(our.bowl registry-ship)
          (handle-registry-action [%register bname title desc])
        :_  this
        :~  [%pass /register %agent [registry-ship %furum] %poke %furum-registry-action !>(`registry-action`[%register bname title desc])]
        ==
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p our.bowl)}/{(trip name)}")
      [(weld cards1 (weld cards2 redir)) this]
    ::  submit post: POST /b/{host}/{name}/submit
        [%b @ @ %submit ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  title=@t  (~(gut by form) 'title' '')
      =/  url-val=@t  (~(gut by form) 'url' '')
      =/  body-val=@t  (~(gut by form) 'body' '')
      =/  =action
        :*  %new-post
            name
            title
            ?:(=('' url-val) ~ `url-val)
            ?:(=('' body-val) ~ `body-val)
        ==
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  edit post: POST /b/{host}/{name}/{post-id}/edit
        [%b @ @ @ %edit ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      =/  title-val=@t  (~(gut by form) 'title' '')
      =/  body-val=@t  (~(gut by form) 'body' '')
      =/  =action  [%edit-post name pid title-val ?:(=('' body-val) ~ `body-val)]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/{(a-co:co pid)}")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  comment: POST /b/{host}/{name}/{post-id}/comment
        [%b @ @ @ %comment ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      =/  body-val=@t  (~(gut by form) 'body' '')
      =/  parent-val=@t  (~(gut by form) 'parent' '')
      =/  parent=(unit comment-id)
        ?:(=('' parent-val) ~ (rush parent-val dem:ag))
      =/  =action  [%new-comment name pid parent body-val]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/{(a-co:co pid)}")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  delete post: POST /b/{host}/{name}/{post-id}/delete
        [%b @ @ @ %delete ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      =/  =action  [%delete-post name pid]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  delete comment: POST /b/{host}/{name}/{post-id}/delete-comment
        [%b @ @ @ %delete-comment ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      =/  cid-val=@t  (~(gut by form) 'comment-id' '')
      =/  cid=@ud  (slav %ud cid-val)
      =/  =action  [%delete-comment name pid cid]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/{(a-co:co pid)}")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  pin/unpin post: POST /b/{host}/{name}/{post-id}/pin
        [%b @ @ @ %pin ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      =/  pin-val=@t  (~(gut by form) 'pinned' '')
      =/  pinned=?  =('true' pin-val)
      =/  =action  [%pin-post name pid pinned]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  set sidebar: POST /b/{host}/{name}/sidebar
        [%b @ @ %sidebar ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  sidebar=@t  (~(gut by form) 'sidebar' '')
      =/  =action  [%set-sidebar name sidebar]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  follow board: POST /b/{host}/{name}/follow
        [%b @ @ %follow ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =^  cards  this  (handle-action [%follow-board host name])
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}")
      [(weld cards redir) this]
    ::  unfollow board: POST /b/{host}/{name}/unfollow
        [%b @ @ %unfollow ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =^  cards  this  (handle-action [%unfollow-board host name])
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}")
      [(weld cards redir) this]
    ::  vote: POST /b/{host}/{name}/vote
        [%b @ @ %vote ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  target-val=@t  (~(gut by form) 'target' '')
      =/  dir-val=@t  (~(gut by form) 'dir' 'up')
      =/  target  (parse-vote-target:fl target-val)
      ?~  target
        (send-html eyre-id 400 (render-error:fl "invalid vote target" dark))
      =/  =action
        ?:  =('up' dir-val)    [%upvote name u.target]
        ?:  =('down' dir-val)  [%downvote name u.target]
        [%remove-vote name u.target]
      ::  redirect back (use referer header or board page)
      =/  referer=tape
        =/  ref  (skim headers |=([k=@t *] =(k 'referer')))
        ?~  ref  "/apps/furum/b/{(scow %p host)}/{(trip name)}"
        (trip value.i.ref)
      =^  redir  this  (redirect eyre-id referer)
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  toggle public: POST /b/{host}/{name}/mod/public
        [%b @ @ %mod %public ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?.  =(host our.bowl)
        (send-html eyre-id 403 (render-error:fl "can only change public setting on local boards" dark))
      =/  brd  (~(get by boards) name)
      ?~  brd
        (send-html eyre-id 404 (render-error:fl "board not found" dark))
      =/  =action  [%set-public name !public.info.u.brd]
      =^  cards  this  (handle-action action)
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod")
      [(weld cards redir) this]
    ::  set role: POST /b/{host}/{name}/mod/role
        [%b @ @ %mod %role ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  who-val=@t  (~(gut by form) 'who' '')
      =/  role-val=@t  (~(gut by form) 'role' '')
      =/  who=@p  (slav %p who-val)
      =/  =role
        ?:  =('mod' role-val)     %mod
        ?:  =('poster' role-val)  %poster
        %reader
      =/  =action  [%set-role name who role]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  remove role: POST /b/{host}/{name}/mod/remove-role
        [%b @ @ %mod %remove-role ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  who-val=@t  (~(gut by form) 'who' '')
      =/  who=@p  (slav %p who-val)
      =/  =action  [%remove-role name who]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ==
  ::
  ++  send-html
    |=  [eyre-id=@ta status=@ud page=manx]
    ^-  (quip card _this)
    =/  =response-header:http  [status ~[['content-type' 'text/html'] ['cache-control' 'no-store, no-cache, must-revalidate'] ['pragma' 'no-cache']]]
    =/  data=octs  (manx-to-octs:fl page)
    :_  this
    :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
        [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`data)]
        [%give %kick ~[/http-response/[eyre-id]] ~]
    ==
  ::
  ++  send-json
    |=  [eyre-id=@ta status=@ud jon=json]
    ^-  (quip card _this)
    =/  txt=@t  (en:json:html jon)
    =/  =response-header:http  [status ~[['content-type' 'application/json'] ['cache-control' 'no-store']]]
    =/  data=octs  [(met 3 txt) txt]
    :_  this
    :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
        [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`data)]
        [%give %kick ~[/http-response/[eyre-id]] ~]
    ==
  ::
  ++  redirect
    |=  [eyre-id=@ta url=tape]
    ^-  (quip card _this)
    =/  =response-header:http  [303 ~[['location' (crip url)]]]
    :_  this
    :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
        [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`(octs))]
        [%give %kick ~[/http-response/[eyre-id]] ~]
    ==
  ::
  ++  apply-vote
    |=  [name=board-name brd=board target=vote-target who=@p direction=?(%up %down %remove)]
    ^-  (quip card _this)
    ?-    -.target
        %post
      =/  pst  (~(got by posts.brd) id.target)
      =/  new-up  ?:(=(direction %up) (~(put in up-votes.pst) who) (~(del in up-votes.pst) who))
      =/  new-down  ?:(=(direction %down) (~(put in down-votes.pst) who) (~(del in down-votes.pst) who))
      =/  new-pst  pst(up-votes new-up, down-votes new-down)
      =/  new-brd  brd(posts (~(put by posts.brd) id.target new-pst))
      :_  this(boards (~(put by boards) name new-brd))
      :~  (give-board-update name [%vote-update target new-up new-down])
      ==
    ::
        %comment
      =/  pc  (~(got by comments.brd) post.target)
      =/  cmt  (~(got by pc) id.target)
      =/  new-up  ?:(=(direction %up) (~(put in up-votes.cmt) who) (~(del in up-votes.cmt) who))
      =/  new-down  ?:(=(direction %down) (~(put in down-votes.cmt) who) (~(del in down-votes.cmt) who))
      =/  new-cmt  cmt(up-votes new-up, down-votes new-down)
      =/  new-brd  brd(comments (~(put by comments.brd) post.target (~(put by pc) id.target new-cmt)))
      :_  this(boards (~(put by boards) name new-brd))
      :~  (give-board-update name [%vote-update target new-up new-down])
      ==
    ==
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
    ::  eyre http response path
    ::
      [%http-response *]
    `this
    ::  registry subscription
    ::
      [%directory ~]
    ?>  =(our.bowl registry-ship)
    :_  this
    =/  entries=(list directory-entry)  ~(val by registry)
    :~  [%give %fact ~ %furum-registry-update !>(`registry-update`[%initial entries])]
    ==
    ::  board subscription
    ::
      [%board @ ~]
    =/  name=board-name  i.t.path
    =/  brd  (~(got by boards) name)
    =/  post-list=(list post)  ~(val by posts.brd)
    =/  subscriber-role=role  (get-role src.bowl brd)
    :_  this
    :~  [%give %fact ~ %furum-update !>(`update`[%initial info.brd roles.brd post-list comments.brd pinned.brd sidebar.brd])]
        [%give %fact ~ %furum-update !>(`update`[%role-update src.bowl `subscriber-role])]
    ==
  ==
::
++  on-leave
  |=  =path
  ^-  (quip card _this)
  `this
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
      [%x %directory ~]
    ``noun+!>(registry)
  ::
      [%x %boards ~]
    ``noun+!>(boards)
  ::
      [%x %board @ ~]
    =/  name=board-name  i.t.t.path
    ?~  brd=(~(get by boards) name)  [~ ~]
    ``noun+!>(u.brd)
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?+    wire  (on-agent:def wire sign)
    ::  poke acks (register, mod actions)
    ::
      [%register ~]  `this
      [%mod-action ~]  `this
    ::  responses from registry subscription
    ::
      [%registry ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %furum-registry-update
        =/  upd  !<(registry-update q.cage.sign)
        (handle-registry-update upd)
      ==
    ::
        %kick
      :_  this
      :~  [%pass /registry %agent [registry-ship %furum] %watch /directory]
      ==
    ::
        %watch-ack
      ?~  p.sign  `this
      `this
    ==
    ::  responses from board subscriptions
    ::
      [%board @ @ ~]
    =/  host=@p  (slav %p i.t.wire)
    =/  name=board-name  i.t.t.wire
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %furum-update
        =/  upd  !<(update q.cage.sign)
        (handle-board-update host name upd)
      ==
    ::
        %kick
      :_  this
      :~  [%pass /board/(scot %p host)/[name] %agent [host %furum] %watch /board/[name]]
      ==
    ::
        %watch-ack
      ?~  p.sign  `this
      `this
    ==
  ==
  ::
  ++  handle-registry-update
    |=  upd=registry-update
    ^-  (quip card _this)
    ?-    -.upd
        %initial
      =/  new-registry=(map board-name directory-entry)
        %+  roll  entries.upd
        |=  [entry=directory-entry acc=(map board-name directory-entry)]
        (~(put by acc) name.entry entry)
      `this(registry new-registry)
    ::
        %add
      `this(registry (~(put by registry) name.directory-entry.upd directory-entry.upd))
    ::
        %remove
      `this(registry (~(del by registry) name.upd))
    ::
        %tag
      =/  entry  (~(get by registry) name.upd)
      ?~  entry  `this
      `this(registry (~(put by registry) name.upd u.entry(tags tags.upd)))
    ::
        %curate
      =/  entry  (~(get by registry) name.upd)
      ?~  entry  `this
      `this(registry (~(put by registry) name.upd u.entry(curated curated.upd)))
    ==
  ::
  ++  handle-board-update
    |=  [host=@p name=board-name upd=update]
    ^-  (quip card _this)
    =/  key  [host name]
    ?-    -.upd
        %initial
      =/  post-map=(map post-id post)
        %+  roll  posts.upd
        |=  [p=post acc=(map post-id post)]
        (~(put by acc) id.p p)
      =/  =cached-board
        [info.upd roles.upd post-map comments.upd pinned.upd sidebar.upd]
      `this(cache (~(put by cache) key cached-board), my-roles (~(put by my-roles) key default-role.info.upd))
    ::
        %new-post
      =/  cb  (~(got by cache) key)
      `this(cache (~(put by cache) key cb(posts (~(put by posts.cb) id.post.upd post.upd))))
    ::
        %delete-post
      =/  cb  (~(got by cache) key)
      `this(cache (~(put by cache) key cb(posts (~(del by posts.cb) id.upd))))
    ::
        %edit-post
      =/  cb  (~(got by cache) key)
      =/  pst  (~(get by posts.cb) id.upd)
      ?~  pst  `this
      `this(cache (~(put by cache) key cb(posts (~(put by posts.cb) id.upd u.pst(title title.upd, body body.upd)))))
    ::
        %new-comment
      =/  cb  (~(got by cache) key)
      =/  pc  (~(gut by comments.cb) post.upd *(map comment-id comment))
      =/  new-pc  (~(put by pc) id.comment.upd comment.upd)
      =/  pst  (~(get by posts.cb) post.upd)
      =/  new-posts
        ?~  pst  posts.cb
        (~(put by posts.cb) post.upd u.pst(comment-count +(comment-count.u.pst)))
      `this(cache (~(put by cache) key cb(comments (~(put by comments.cb) post.upd new-pc), posts new-posts)))
    ::
        %delete-comment
      =/  cb  (~(got by cache) key)
      =/  pc  (~(gut by comments.cb) post.upd *(map comment-id comment))
      =/  pst  (~(get by posts.cb) post.upd)
      =/  new-posts
        ?~  pst  posts.cb
        =/  cnt  comment-count.u.pst
        (~(put by posts.cb) post.upd u.pst(comment-count ?:(=(0 cnt) 0 (dec cnt))))
      `this(cache (~(put by cache) key cb(comments (~(put by comments.cb) post.upd (~(del by pc) id.upd)), posts new-posts)))
    ::
        %vote-update
      =/  cb  (~(got by cache) key)
      ?-    -.target.upd
          %post
        =/  pst  (~(got by posts.cb) id.target.upd)
        =/  new-pst  pst(up-votes up-votes.upd, down-votes down-votes.upd)
        `this(cache (~(put by cache) key cb(posts (~(put by posts.cb) id.target.upd new-pst))))
      ::
          %comment
        =/  pc  (~(got by comments.cb) post.target.upd)
        =/  cmt  (~(got by pc) id.target.upd)
        =/  new-cmt  cmt(up-votes up-votes.upd, down-votes down-votes.upd)
        `this(cache (~(put by cache) key cb(comments (~(put by comments.cb) post.target.upd (~(put by pc) id.target.upd new-cmt)))))
      ==
    ::
        %role-update
      =/  cb  (~(get by cache) key)
      =?  this  ?=(^ cb)
        ?~  role.upd
          this(cache (~(put by cache) key u.cb(roles (~(del by roles.u.cb) who.upd))))
        this(cache (~(put by cache) key u.cb(roles (~(put by roles.u.cb) who.upd u.role.upd))))
      ?.  =(who.upd our.bowl)  `this
      ?~  role.upd
        ?~  cb  `this(my-roles (~(del by my-roles) key))
        `this(my-roles (~(put by my-roles) key default-role.info.u.cb))
      `this(my-roles (~(put by my-roles) key u.role.upd))
    ::
        %board-info-update
      =/  cb  (~(got by cache) key)
      `this(cache (~(put by cache) key cb(info info.upd)))
    ::
        %pin-update
      =/  cb  (~(got by cache) key)
      =/  new-pinned=(set post-id)
        ?:(pinned.upd (~(put in pinned.cb) id.upd) (~(del in pinned.cb) id.upd))
      `this(cache (~(put by cache) key cb(pinned new-pinned)))
    ::
        %sidebar-update
      =/  cb  (~(got by cache) key)
      `this(cache (~(put by cache) key cb(sidebar sidebar.upd)))
    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%eyre %connect ~]
    `this
  ==
::
++  on-fail  on-fail:def
--
