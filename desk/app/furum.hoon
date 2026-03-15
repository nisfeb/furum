::  app/furum.hoon: decentralized forum agent
::
::  serves three roles depending on context:
::  - registry: maintains directory of boards (on hardcoded registry ship)
::  - host: hosts boards with posts, comments, votes, permissions
::  - client: subscribes to registry and hosts, caches data, serves UI
::
/-  *furum
/-  push
/+  default-agent, dbug, fl=furum, ca=cashu, web-pusher
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
+$  s7-board
  $:  info=board-info
      roles=(map @p role)
      next-post-id=post-id
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      next-comment-ids=(map post-id comment-id)
      pinned=(set post-id)
      sidebar=@t
  ==
+$  s7-cached-board
  $:  info=board-info
      roles=(map @p role)
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      pinned=(set post-id)
      sidebar=@t
  ==
+$  s8-payment-config
  $:  price=@ud
      interval=@dr
  ==
+$  s8-board
  $:  info=board-info
      roles=(map @p role)
      next-post-id=post-id
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      next-comment-ids=(map post-id comment-id)
      pinned=(set post-id)
      sidebar=@t
      payment=(unit s8-payment-config)
      paid=(map @p @da)
  ==
+$  s9-cached-board
  $:  info=board-info
      roles=(map @p role)
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      pinned=(set post-id)
      sidebar=@t
      paid-until=(unit @da)
  ==
+$  s11-cached-board
  $:  info=board-info
      roles=(map @p role)
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      pinned=(set post-id)
      sidebar=@t
      payment=(unit s8-payment-config)
      paid-until=(unit @da)
  ==
::
+$  versioned-state
  $%  state-2
      state-3
      state-4
      state-5
      state-6
      state-7
      state-8
      state-9
      state-10
      state-11
      state-12
      state-13
      state-14
      state-15
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
      boards=(map board-name s7-board)
      cache=(map [@p board-name] s7-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
      board-seen=(map [@p board-name] @da)
      post-seen=(map [@p board-name post-id] @da)
  ==
::
+$  state-8
  $:  %8
      registry=(map board-name directory-entry)
      boards=(map board-name s8-board)
      cache=(map [@p board-name] s9-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
      board-seen=(map [@p board-name] @da)
      post-seen=(map [@p board-name post-id] @da)
      pending-payments=(map @t [who=@p name=board-name amount=@ud])
  ==
::
+$  s14-board
  $:  info=board-info
      roles=(map @p role)
      next-post-id=post-id
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      next-comment-ids=(map post-id comment-id)
      pinned=(set post-id)
      sidebar=@t
      payment=(unit payment-config)
      paid=(map @p @da)
      wallet=(map @t (list cashu-proof))
      mint-keysets=(map @t (map @ud @t))
  ==
::
+$  s11-board
  $:  info=board-info
      roles=(map @p role)
      next-post-id=post-id
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      next-comment-ids=(map post-id comment-id)
      pinned=(set post-id)
      sidebar=@t
      payment=(unit s8-payment-config)
      paid=(map @p @da)
      wallet=(map @t (list cashu-proof))
      mint-keysets=(map @t (map @ud @t))
  ==
::
+$  pending-swap
  $:  who=@p
      name=board-name
      amount=@ud
      mint=@t
      keyset-id=@t
      step=?(%fetch-keys %swap)
      input-proofs=@t
      secrets=(list @t)
      blinding-factors=(list @)
  ==
::
+$  pending-melt
  $:  name=board-name
      mint=@t
      step=?(%quote %execute)
      invoice=@t
      proofs-used=(list cashu-proof)
      quote-id=@t
      fee-reserve=@ud
  ==
::
+$  pending-mint-quote
  $:  who=@p
      name=board-name
      mint=@t
      quote-id=@t
      bolt11=@t
      amount=@ud
      keyset-id=@t
      expiry=@da
      step=?(%quote %check-quote %mint-tokens %fetch-keys)
      secrets=(list @t)
      blinding-factors=(list @)
  ==
::
+$  pending-ln-invoice
  $:  host=@p
      name=board-name
      bolt11=(unit @t)
      amount=@ud
      expiry=@ud
  ==
::
+$  state-9
  $:  %9
      registry=(map board-name directory-entry)
      boards=(map board-name s11-board)
      cache=(map [@p board-name] s9-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
      board-seen=(map [@p board-name] @da)
      post-seen=(map [@p board-name post-id] @da)
      pending-swaps=(map @t pending-swap)
      pending-melts=(map @t pending-melt)
  ==
::
+$  state-10
  $:  %10
      registry=(map board-name directory-entry)
      boards=(map board-name s11-board)
      cache=(map [@p board-name] s11-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
      board-seen=(map [@p board-name] @da)
      post-seen=(map [@p board-name post-id] @da)
      pending-swaps=(map @t pending-swap)
      pending-melts=(map @t pending-melt)
  ==
::
+$  state-11
  $:  %11
      registry=(map board-name directory-entry)
      boards=(map board-name s11-board)
      cache=(map [@p board-name] s11-cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
      board-seen=(map [@p board-name] @da)
      post-seen=(map [@p board-name post-id] @da)
      pending-swaps=(map @t pending-swap)
      pending-melts=(map @t pending-melt)
  ==
::
+$  state-12
  $:  %12
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
      pending-swaps=(map @t pending-swap)
      pending-melts=(map @t pending-melt)
      pending-mints=(map @t pending-mint-quote)
      pending-ln-invoices=(map @t pending-ln-invoice)
  ==
::
+$  state-13
  $:  %13
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
      pending-swaps=(map @t pending-swap)
      pending-melts=(map @t pending-melt)
      pending-mints=(map @t pending-mint-quote)
      pending-ln-invoices=(map @t pending-ln-invoice)
      backup-dates=(list @da)
  ==
::
+$  state-14
  $:  %14
      registry=(map board-name directory-entry)
      boards=(map board-name s14-board)
      cache=(map [@p board-name] cached-board)
      subs=(set [@p board-name])
      dark-mode=(set @p)
      registry-admins=(set @p)
      my-roles=(map [@p board-name] role)
      followed=(set [@p board-name])
      board-seen=(map [@p board-name] @da)
      post-seen=(map [@p board-name post-id] @da)
      pending-swaps=(map @t pending-swap)
      pending-melts=(map @t pending-melt)
      pending-mints=(map @t pending-mint-quote)
      pending-ln-invoices=(map @t pending-ln-invoice)
      backup-dates=(list @da)
      notifications=(list notification)
  ==
::
+$  state-15
  $:  %15
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
      pending-swaps=(map @t pending-swap)
      pending-melts=(map @t pending-melt)
      pending-mints=(map @t pending-mint-quote)
      pending-ln-invoices=(map @t pending-ln-invoice)
      backup-dates=(list @da)
      notifications=(list notification)
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
++  has-paid-access
  |=  [who=@p brd=board now=@da]
  ^-  ?
  ?~  payment.brd  %.y
  ?:  (is-mod who brd)  %.y
  =/  exp  (~(get by paid.brd) who)
  ?~  exp  %.n
  (gth u.exp now)
::
++  give-board-update
  |=  [name=board-name upd=update]
  ^-  card
  [%give %fact ~[/board/[name]] %furum-update !>(upd)]
::
::
--
::
%-  agent:dbug
%-  %:  agent:web-pusher
      /apps/furum
      'mailto:furum@urbit.org'
      %.y
      0
    ==
=|  state-15
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
      [ni roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob *(set post-id) '' ~ *(map @p @da) *(map @t (list cashu-proof)) *(map @t (map @ud @t)) ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=old-cached-board
      ^-  cached-board
      =/  ni=board-info  [name.info.oc title.info.oc description.info.oc host.info.oc created.info.oc default-role.info.oc %.n]
      [ni roles.oc posts.oc comments.oc *(set post-id) '' ~ ~]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old *(set [@p board-name]) *(map [@p board-name] @da) *(map [@p board-name post-id] @da) *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %3
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s4-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob *(set post-id) '' ~ *(map @p @da) *(map @t (list cashu-proof)) *(map @t (map @ud @t)) ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s4-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc *(set post-id) '' ~ ~]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old *(set [@p board-name]) *(map [@p board-name] @da) *(map [@p board-name post-id] @da) *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %4
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s4-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob *(set post-id) '' ~ *(map @p @da) *(map @t (list cashu-proof)) *(map @t (map @ud @t)) ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s4-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc *(set post-id) '' ~ ~]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old *(map [@p board-name] @da) *(map [@p board-name post-id] @da) *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %5
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s6-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob '' ~ *(map @p @da) *(map @t (list cashu-proof)) *(map @t (map @ud @t)) ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s6-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc pinned.oc '' ~ ~]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old *(map [@p board-name] @da) *(map [@p board-name post-id] @da) *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %6
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s6-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob '' ~ *(map @p @da) *(map @t (list cashu-proof)) *(map @t (map @ud @t)) ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s6-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc pinned.oc '' ~ ~]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %7
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s7-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob sidebar.ob ~ *(map @p @da) *(map @t (list cashu-proof)) *(map @t (map @ud @t)) ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s7-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc pinned.oc sidebar.oc ~ ~]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %8
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s8-board
      ^-  board
      =/  new-pay=(unit payment-config)  ?~(payment.ob ~ `[price.u.payment.ob interval.u.payment.ob ~])
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob sidebar.ob new-pay paid.ob *(map @t (list cashu-proof)) *(map @t (map @ud @t)) ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s9-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc pinned.oc sidebar.oc ~ paid-until.oc]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %9
    ::  migrate cache and boards: add payment.mint field
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s11-board
      ^-  board
      =/  new-pay=(unit payment-config)  ?~(payment.ob ~ `[price.u.payment.ob interval.u.payment.ob ~])
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob sidebar.ob new-pay paid.ob wallet.ob mint-keysets.ob ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s9-cached-board
      ^-  cached-board
      [info.oc roles.oc posts.oc comments.oc pinned.oc sidebar.oc ~ paid-until.oc]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %10
    ::  migrate boards, clear cache and re-subscribe
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s11-board
      ^-  board
      =/  new-pay=(unit payment-config)  ?~(payment.ob ~ `[price.u.payment.ob interval.u.payment.ob ~])
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob sidebar.ob new-pay paid.ob wallet.ob mint-keysets.ob ~]
    =/  resub-cards=(list card)
      %+  turn  ~(tap in subs.old)
      |=  [host=@p name=board-name]
      [%pass /board/(scot %p host)/[name] %agent [host %furum] %leave ~]
    :_  this(state [%15 registry.old new-boards *(map [@p board-name] cached-board) *(set [@p board-name]) dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
    resub-cards
  ::
      %11
    ::  migrate boards and cache: add mint field to payment-config
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s11-board
      ^-  board
      =/  new-pay=(unit payment-config)  ?~(payment.ob ~ `[price.u.payment.ob interval.u.payment.ob ~])
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob sidebar.ob new-pay paid.ob wallet.ob mint-keysets.ob ~]
    =/  new-cache=(map [@p board-name] cached-board)
      %-  ~(run by cache.old)
      |=  oc=s11-cached-board
      ^-  cached-board
      =/  new-pay=(unit payment-config)  ?~(payment.oc ~ `[price.u.payment.oc interval.u.payment.oc ~])
      [info.oc roles.oc posts.oc comments.oc pinned.oc sidebar.oc new-pay paid-until.oc]
    `this(state [%15 registry.old new-boards new-cache subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old pending-swaps.old pending-melts.old *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %12
    ::  add backup-dates field
    `this(state [%15 registry.old boards.old cache.old subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) ~ ~])
  ::
      %13
    ::  add notifications field
    `this(state [%15 registry.old boards.old cache.old subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) backup-dates.old ~])
  ::
      %14
    ::  add prune field to boards
    =/  new-boards=(map board-name board)
      %-  ~(run by boards.old)
      |=  ob=s14-board
      ^-  board
      [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob sidebar.ob payment.ob paid.ob wallet.ob mint-keysets.ob ~]
    `this(state [%15 registry.old new-boards cache.old subs.old dark-mode.old registry-admins.old my-roles.old followed.old board-seen.old post-seen.old *(map @t pending-swap) *(map @t pending-melt) *(map @t pending-mint-quote) *(map @t pending-ln-invoice) backup-dates.old notifications.old])
  ::
      %15
    ::  clear stale pending ops and restart prune timers
    =/  prune-cards=(list card)
      %+  murn  ~(tap by boards.old)
      |=  [name=board-name brd=board]
      ^-  (unit card)
      ?~  prune.brd  ~
      `[%pass /prune/[name] %arvo %b %wait (add now.bowl ~h6)]
    :_  this(state old(pending-swaps *(map @t pending-swap), pending-melts *(map @t pending-melt), pending-mints *(map @t pending-mint-quote), pending-ln-invoices *(map @t pending-ln-invoice)))
    prune-cards
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
  ::
      %furum-board-restore
    =/  dat  !<(board-restore-payload vase)
    (handle-board-restore dat)
  ==
  ::
  ++  handle-board-restore
    |=  dat=board-restore-payload
    ^-  (quip card _this)
    ::  only the ship owner can restore boards
    ?>  =(src.bowl our.bowl)
    ::  only accept restores for boards we host
    ?>  =(our.bowl host.info.cached-board.dat)
    ::  board must already exist (host created it as a target for restore)
    =/  existing  (~(get by boards) name.dat)
    ?~  existing
      ~&  >>>  [%restore-rejected-no-board name.dat src.bowl]
      `this
    ::  reconstruct full board from cached data
    =/  cb  cached-board.dat
    =/  next-pid=@ud
      =/  pids=(list post-id)  ~(tap in ~(key by posts.cb))
      ?~  pids  0
      .+((roll `(list post-id)`pids max))
    =/  next-cids=(map post-id comment-id)
      %-  ~(run by comments.cb)
      |=  cm=(map comment-id comment)
      ^-  comment-id
      =/  cids=(list comment-id)  ~(tap in ~(key by cm))
      ?~  cids  0
      .+((roll `(list comment-id)`cids max))
    =/  restored=board
      :*  info=info.cb
          roles=roles.cb
          next-post-id=next-pid
          posts=posts.cb
          comments=comments.cb
          next-comment-ids=next-cids
          pinned=pinned.cb
          sidebar=sidebar.cb
          payment=payment.cb
          paid=paid.u.existing
          wallet=wallet.u.existing
          mint-keysets=mint-keysets.u.existing
          prune=prune.u.existing
      ==
    ~&  >>>  [%board-restored name.dat src.bowl (lent ~(tap by posts.cb)) next-pid]
    ::  kick board subscribers so they re-subscribe and get fresh content
    :_  this(boards (~(put by boards) name.dat restored))
    :~  [%give %kick ~[/board/[name.dat]] ~]
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
            payment=~
            paid=*(map @p @da)
            wallet=*(map @t (list cashu-proof))
            mint-keysets=*(map @t (map @ud @t))
            prune=~
        ==
      `this(boards (~(put by boards) name.act board))
    ::
        %delete-board
      ?>  =(src.bowl our.bowl)
      ::  kick all subscribers on this board
      =/  kick-cards=(list card)
        :~  [%give %kick ~[/board/[name.act]] ~]
        ==
      ::  unregister from registry
      =/  unreg-cards=(list card)
        :~  [%pass /mod-action %agent [registry-ship %furum] %poke %furum-registry-action !>(`registry-action`[%unregister name.act])]
        ==
      :_  this(boards (~(del by boards) name.act))
      (weld kick-cards unreg-cards)
    ::
        %edit-board-info
      ?>  =(src.bowl our.bowl)
      ?>  (gth (met 3 title.act) 0)
      =/  safe-title=@t  (crip (scag 200 (trip title.act)))
      =/  safe-desc=@t  (crip (scag 2.000 (trip description.act)))
      =/  brd  (~(got by boards) name.act)
      =/  new-info  info.brd(title safe-title, description safe-desc)
      =/  new-brd  brd(info new-info)
      :_  this(boards (~(put by boards) name.act new-brd))
      :~  (give-board-update name.act [%board-info-update new-info])
      ==
    ::
        %set-public
      ?>  =(src.bowl our.bowl)
      =/  brd  (~(got by boards) name.act)
      ::  paid boards cannot be made public
      ?>  ?|(!public.act ?=(~ payment.brd))
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
        %set-prune
      ?>  =(src.bowl our.bowl)
      =/  brd  (~(got by boards) name.act)
      =/  new-brd  brd(prune prune.act)
      ::  start prune timer if enabling (timer self-cancels if prune disabled later)
      =/  timer-cards=(list card)
        ?~  prune.act  ~
        :~  [%pass /prune/[name.act] %arvo %b %wait (add now.bowl ~h6)]
        ==
      :_  this(boards (~(put by boards) name.act new-brd))
      timer-cards
    ::
        %set-payment
      =/  brd  (~(got by boards) name.act)
      ?>  (is-mod src.bowl brd)
      ::  enabling payment disables public access
      =/  new-brd  brd(payment payment.act)
      =?  new-brd  ?=(^ payment.act)
        new-brd(public.info %.n)
      =/  cards=(list card)
        :~  (give-board-update name.act [%payment-config-update payment.act])
        ==
      =?  cards  &(?=(^ payment.act) public.info.brd)
        (snoc cards (give-board-update name.act [%board-info-update info.new-brd]))
      :_  this(boards (~(put by boards) name.act new-brd))
      cards
    ::
        %submit-payment
      =/  brd  (~(got by boards) name.act)
      =/  pay  payment.brd
      ?~  pay
        ~&  >>>  [%submit-payment-board-not-paid name.act src.bowl]
        `this
      ::  parse token JSON to extract proofs and keyset id
      =/  maybe-json  (de:json:html tokens.act)
      ?~  maybe-json
        ~&  >>>  [%submit-payment-invalid-json name.act src.bowl]
        `this
      =/  jon  u.maybe-json
      ?.  ?=([%o *] jon)
        ~&  >>>  [%submit-payment-expected-object name.act src.bowl]
        `this
      =/  maybe-inputs  (~(get by p.jon) 'inputs')
      ?~  maybe-inputs
        ~&  >>>  [%submit-payment-missing-inputs name.act src.bowl]
        `this
      ?.  ?=([%a *] u.maybe-inputs)
        ~&  >>>  [%submit-payment-inputs-not-array name.act src.bowl]
        `this
      ::  sum amounts and extract keyset id from first proof
      =/  total=@ud  0
      =/  keyset-id=@t  ''
      =/  total-and-kid=[tot=@ud kid=@t]
        %+  roll  p.u.maybe-inputs
        |=  [tok=json acc=[tot=@ud kid=@t]]
        ?.  ?=([%o *] tok)  acc
        =/  amt-val  (~(get by p.tok) 'amount')
        =/  id-val  (~(get by p.tok) 'id')
        =/  amt=@ud
          ?~  amt-val  0
          ?+  -.u.amt-val  0
            %n  (roll (trip p.u.amt-val) |=([c=@ a=@ud] (add (mul a 10) (sub c '0'))))
          ==
        =/  kid=@t
          ?~  id-val  kid.acc
          ?+  -.u.id-val  kid.acc
            %s  p.u.id-val
          ==
        [(add tot.acc amt) kid]
      =.  total  tot.total-and-kid
      =.  keyset-id  kid.total-and-kid
      ::  reject if total < price
      ?.  (gte total price.u.pay)
        ~&  >>>  [%submit-payment-insufficient name.act src.bowl total price.u.pay]
        `this
      ::  generate nonce for tracking
      =/  nonce=@t  (scot %uv (sham [now.bowl src.bowl name.act eny.bowl]))
      ::  clean mint URL
      =/  mint-clean=tape  (clean-mint-url:ca mint.act)
      =/  mint-cord=@t  (crip mint-clean)
      ::  check if we have cached keys for this keyset
      =/  cached-keys  (~(get by mint-keysets.brd) keyset-id)
      ?~  cached-keys
        ::  step 1: fetch keyset keys first
        =.  pending-swaps
          %+  ~(put by pending-swaps)  nonce
          :*  src.bowl
              name.act
              total
              mint-cord
              keyset-id
              %fetch-keys
              tokens.act
              *(list @t)
              *(list @)
          ==
        =/  keys-url=@t  (crip (weld mint-clean "/v1/keys/{(trip keyset-id)}"))
        :_  this
        :~  [%pass /iris/swap/[nonce] %arvo %i %request [%'GET' keys-url ~ ~] *outbound-config:iris]
        ==
      ::  have keys — proceed directly to swap
      (do-swap nonce src.bowl name.act total mint-cord keyset-id tokens.act brd)
    ::
        %melt-to-lightning
      ?>  =(src.bowl our.bowl)
      =/  brd  (~(got by boards) name.act)
      ?>  (is-mod src.bowl brd)
      ::  find proofs for this mint
      =/  mint-clean=tape  (clean-mint-url:ca mint.act)
      =/  mint-cord=@t  (crip mint-clean)
      =/  proofs=(list cashu-proof)  (~(gut by wallet.brd) mint-cord ~)
      ?>  (gth (lent proofs) 0)
      ::  step 1: get melt quote
      =/  nonce=@t  (scot %uv (sham [now.bowl src.bowl name.act eny.bowl]))
      =.  pending-melts
        %+  ~(put by pending-melts)  nonce
        [name.act mint-cord %quote invoice.act proofs '' 0]
      =/  quote-body=@t  (en:json:html (build-melt-quote-request:ca invoice.act 'sat'))
      =/  quote-octs=octs  [(met 3 quote-body) quote-body]
      =/  quote-url=@t  (crip (weld mint-clean "/v1/melt/quote/bolt11"))
      :_  this
      :~  [%pass /iris/melt/[nonce] %arvo %i %request [%'POST' quote-url ~[['content-type' 'application/json']] `quote-octs] *outbound-config:iris]
      ==
    ::
        %revoke-paid
      ?>  =(src.bowl our.bowl)
      =/  brd  (~(got by boards) name.act)
      ?>  (is-mod src.bowl brd)
      =/  new-brd  brd(paid (~(del by paid.brd) who.act))
      ~&  >>>  [%revoked-paid name.act who.act]
      `this(boards (~(put by boards) name.act new-brd))
    ::
        %clear-wallet
      ?>  =(src.bowl our.bowl)
      =/  brd  (~(got by boards) name.act)
      ?>  (is-mod src.bowl brd)
      =/  new-brd  brd(wallet *(map @t (list cashu-proof)))
      ~&  >>>  [%cleared-wallet name.act]
      `this(boards (~(put by boards) name.act new-brd))
    ::
        %request-lightning-invoice
      ::  remote user requests a Lightning invoice to pay for board access
      =/  brd  (~(get by boards) name.act)
      ?~  brd
        ~&  >>>  [%ln-invoice-no-board name.act src.bowl]
        `this
      =/  pay  payment.u.brd
      ?~  pay
        ~&  >>>  [%ln-invoice-no-payment name.act src.bowl]
        `this
      =/  mint-url  mint.u.pay
      ?~  mint-url
        ~&  >>>  [%ln-invoice-no-mint name.act src.bowl]
        `this
      =/  mint-clean=tape  (clean-mint-url:ca u.mint-url)
      =/  mint-cord=@t  (crip mint-clean)
      ::  check for cached keyset
      =/  keyset-id=@t
        =/  ks  ~(tap by mint-keysets.u.brd)
        ?~  ks  ''
        -.i.ks
      ::  store pending mint quote
      =/  nonce=@t  nonce.act
      =.  pending-mints
        %+  ~(put by pending-mints)  nonce
        :*  src.bowl
            name.act
            mint-cord
            ''
            ''
            price.u.pay
            keyset-id
            *@da
            ?:(=('' keyset-id) %fetch-keys %quote)
            *(list @t)
            *(list @)
        ==
      ?:  =('' keyset-id)
        ::  need to fetch keyset first
        =/  keys-url=@t  (crip (weld mint-clean "/v1/keysets"))
        :_  this
        :~  [%pass /iris/mint-keys/[nonce] %arvo %i %request [%'GET' keys-url ~ ~] *outbound-config:iris]
        ==
      ::  have keyset — request mint quote
      =/  quote-body=@t  (en:json:html (build-mint-quote-request:ca price.u.pay 'sat'))
      =/  quote-octs=octs  [(met 3 quote-body) quote-body]
      =/  quote-url=@t  (crip (weld mint-clean "/v1/mint/quote/bolt11"))
      :_  this
      :~  [%pass /iris/mint-quote/[nonce] %arvo %i %request [%'POST' quote-url ~[['content-type' 'application/json']] `quote-octs] *outbound-config:iris]
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
      ?>  (has-paid-access src.bowl brd now.bowl)
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
      =/  post-push-cards=(list card)
        ?:  =(src.bowl our.bowl)  ~
        =/  post-url=@t
          (crip "/apps/furum/b/{(scow %p our.bowl)}/{(trip name.act)}/{(a-co:co id.post)}")
        =/  notify-act=action  [%notify 'New post on your board' (crip "{(scow %p src.bowl)} posted '{(trip title.act)}' to {(trip name.act)}") `post-url (sy %new-posts ~)]
        :~  [%pass /notify/new-post %agent [our.bowl %furum] %poke %furum-action !>(notify-act)]
        ==
      :_  this(boards (~(put by boards) name.act new-brd))
      (weld ~[(give-board-update name.act [%new-post post])] post-push-cards)
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
      ?>  (has-paid-access src.bowl brd now.bowl)
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
      ?>  (has-paid-access src.bowl brd now.bowl)
      ?>  (can-post src.bowl brd)
      =/  post-comments  (~(gut by comments.brd) post.act *(map comment-id comment))
      =/  next-cid  (~(gut by next-comment-ids.brd) post.act 0)
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
      =/  post-url=@t
        (crip "/apps/furum/b/{(scow %p our.bowl)}/{(trip name.act)}/{(a-co:co post.act)}")
      =/  push-cards=(list card)
        ::  notify post author when someone else comments on their post
        ::
        =/  comment-cards=(list card)
          ?:  =(src.bowl author.pst)  ~
          =/  ntitle=@t  'New comment on your post'
          =/  nbody=@t  (crip "{(scow %p src.bowl)} commented on '{(trip title.pst)}'")
          ::  send %notify to the target (local or remote — stores + pushes)
          =/  notify-act=action  [%notify ntitle nbody `post-url (sy %comments ~)]
          :~  [%pass /notify/comment %agent [author.pst %furum] %poke %furum-action !>(notify-act)]
          ==
        ::  notify parent comment author on reply
        ::
        =/  reply-cards=(list card)
          ?~  parent.act  ~
          =/  parent-comment  (~(get by post-comments) u.parent.act)
          ?~  parent-comment  ~
          ?:  =(src.bowl author.u.parent-comment)  ~
          ?:  =(author.u.parent-comment author.pst)  ~  :: already notified above
          =/  ntitle=@t  'Reply to your comment'
          =/  nbody=@t  (crip "{(scow %p src.bowl)} replied to your comment on '{(trip title.pst)}'")
          =/  notify-act=action  [%notify ntitle nbody `post-url (sy %comments ~)]
          :~  [%pass /notify/reply %agent [author.u.parent-comment %furum] %poke %furum-action !>(notify-act)]
          ==
        (weld comment-cards reply-cards)
      :_  this(boards (~(put by boards) name.act new-brd))
      (weld ~[(give-board-update name.act [%new-comment post.act comment])] push-cards)
    ::
        %delete-comment
      =/  brd  (~(got by boards) name.act)
      =/  pc  (~(get by comments.brd) post.act)
      ?~  pc  `this
      =/  cm  (~(get by u.pc) id.act)
      ?~  cm  `this
      =/  =comment  u.cm
      =/  post-comments  u.pc
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
      ?>  (has-paid-access src.bowl brd now.bowl)
      ?>  (can-read src.bowl brd)
      (apply-vote name.act brd target.act src.bowl %up)
    ::
        %downvote
      =/  brd  (~(got by boards) name.act)
      ?>  (has-paid-access src.bowl brd now.bowl)
      ?>  (can-read src.bowl brd)
      (apply-vote name.act brd target.act src.bowl %down)
    ::
        %remove-vote
      =/  brd  (~(got by boards) name.act)
      ?>  (has-paid-access src.bowl brd now.bowl)
      ?>  (can-read src.bowl brd)
      (apply-vote name.act brd target.act src.bowl %remove)
    ::
        %notify
      ::  receive notification from a remote host — send push locally and store
      ::  only accept from ourselves or ships we're subscribed to
      ?.  ?|  =(src.bowl our.bowl)
              %+  lien  ~(tap in subs)
              |=  [host=@p name=board-name]
              =(host src.bowl)
          ==
        `this
      ::  truncate inputs to prevent memory abuse
      =/  safe-title=@t  (crip (scag 200 (trip title.act)))
      =/  safe-body=@t  (crip (scag 500 (trip body.act)))
      =/  =notification  [safe-title safe-body url.act now.bowl %.n]
      =/  new-notifs=(list ^notification)  [notification (scag 49 notifications)]
      =/  =push-send:push
        :*  targets=(sy our.bowl ~)
            tags=tags.act
            exclude=~
            msg=[title=title.act body=body.act icon=~ url=url.act tag=~]
        ==
      :_  this(notifications new-notifs)
      :~  [%pass /push/remote-notify %agent [our dap]:bowl %poke %push-send !>(push-send)]
      ==
    ::
        %mark-notifications-read
      ?>  =(src.bowl our.bowl)
      =/  marked=(list notification)
        (turn notifications |=(n=notification n(read %.y)))
      `this(notifications marked)
    ::
        %backup-to-clay
      ?>  =(src.bowl our.bowl)
      =/  bak=furum-backup  [boards registry registry-admins now.bowl]
      ~&  >>>  [%backup-created now.bowl (lent ~(tap by boards)) (lent ~(tap by registry))]
      =/  date=@ta  (scot %da now.bowl)
      :_  this(backup-dates [now.bowl backup-dates])
      :~  [%pass /write-backup %arvo %c %info %furum %& [/backup/[date]/noun %ins noun+!>(`*`bak)]~]
      ==
    ::
        %restore-from-clay
      ?>  =(src.bowl our.bowl)
      ?~  backup-dates
        ~&  >>>  [%restore-no-backups-found ~]
        `this
      =/  latest=@t  (scot %da i.backup-dates)
      ~&  >>>  [%restoring-from latest]
      =/  raw=*  .^(* %cx /(scot %p our.bowl)/furum/(scot %da now.bowl)/backup/[latest]/noun)
      ::  try current format first, fall back to old format (boards without prune)
      =/  bak=furum-backup
        =/  try  (mule |.(;;(furum-backup raw)))
        ?:  ?=([%& *] try)  p.try
        ::  old backup: boards lack prune field — migrate
        =/  old  ;;([boards=(map board-name s14-board) registry=(map board-name directory-entry) registry-admins=(set @p) timestamp=@da] raw)
        =/  new-boards=(map board-name board)
          %-  ~(run by boards.old)
          |=  ob=s14-board
          ^-  board
          [info.ob roles.ob next-post-id.ob posts.ob comments.ob next-comment-ids.ob pinned.ob sidebar.ob payment.ob paid.ob wallet.ob mint-keysets.ob ~]
        [new-boards registry.old registry-admins.old timestamp.old]
      ~&  >>>  [%restore-loaded (lent ~(tap by boards.bak)) (lent ~(tap by registry.bak)) timestamp.bak]
      ::  kick all current subscribers before overwriting state
      =/  board-kicks=(list card)
        %+  turn  ~(tap by boards)
        |=  [name=board-name *]
        ^-  card
        [%give %kick ~[/board/[name]] ~]
      :_  this(boards boards.bak, registry registry.bak, registry-admins registry-admins.bak)
      [[%give %kick ~[/directory] ~] board-kicks]
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
      =/  entry  (~(get by registry) name.act)
      ?~  entry  `this
      ?>  =(src.bowl host.u.entry)
      :_  this(registry (~(del by registry) name.act))
      :~  [%give %fact ~[/directory] %furum-registry-update !>(`registry-update`[%remove name.act])]
      ==
    ::
        %tag-board
      ?>  =(our.bowl registry-ship)
      ?>  ?|  =(src.bowl our.bowl)
              (~(has in registry-admins) src.bowl)
          ==
      =/  entry  (~(get by registry) name.act)
      ?~  entry  `this
      =/  new-tags  (~(put in tags.u.entry) tag.act)
      =/  new-entry  u.entry(tags new-tags)
      :_  this(registry (~(put by registry) name.act new-entry))
      :~  [%give %fact ~[/directory] %furum-registry-update !>(`registry-update`[%tag name.act new-tags])]
      ==
    ::
        %untag-board
      ?>  =(our.bowl registry-ship)
      ?>  ?|  =(src.bowl our.bowl)
              (~(has in registry-admins) src.bowl)
          ==
      =/  entry  (~(get by registry) name.act)
      ?~  entry  `this
      =/  new-tags  (~(del in tags.u.entry) tag.act)
      =/  new-entry  u.entry(tags new-tags)
      :_  this(registry (~(put by registry) name.act new-entry))
      :~  [%give %fact ~[/directory] %furum-registry-update !>(`registry-update`[%tag name.act new-tags])]
      ==
    ::
        %curate-board
      ?>  =(our.bowl registry-ship)
      ?>  ?|  =(src.bowl our.bowl)
              (~(has in registry-admins) src.bowl)
          ==
      =/  entry  (~(get by registry) name.act)
      ?~  entry  `this
      =/  new-entry  u.entry(curated curated.act)
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
    ::
        %refresh-registry
      ?>  =(our.bowl registry-ship)
      ?>  =(src.bowl our.bowl)
      ::  kick all /directory subscribers — they will auto-resubscribe
      ::  and receive a fresh %initial with the full registry
      :_  this
      :~  [%give %kick ~[/directory] ~]
      ==
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
      ::  paid boards are not publicly accessible
      ?^  payment.u.brd
        (send-html eyre-id 403 (render-error:fl "not authenticated" %.n))
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
    ::  service worker (PWA + push notifications)
        [%sw ~]
      =/  sw=@t
        '''
        self.addEventListener("install",function(e){self.skipWaiting()});
        self.addEventListener("activate",function(e){e.waitUntil(self.clients.claim())});
        self.addEventListener("push",function(e){
          var d={title:"Notification",body:""};
          try{d=e.data.json()}catch(x){}
          var t=d.tag||"";
          e.waitUntil(
            (t?self.registration.getNotifications({tag:t}):Promise.resolve([]))
            .then(function(all){
              var c=1;
              if(all.length>0&&all[0].data&&all[0].data.count)c=all[0].data.count+1;
              var body=d.body||"";
              if(c>1)body=c+" new";
              return self.registration.showNotification(d.title,{
                body:body,icon:d.icon||"",tag:t,renotify:true,
                data:{url:d.url||"",count:c}
              })
            })
          )
        });
        self.addEventListener("notificationclick",function(e){
          e.notification.close();
          if(e.notification.data&&e.notification.data.url)
            e.waitUntil(clients.openWindow(e.notification.data.url))
        });
        '''
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
        ::  optimization: only take top N from each board before merging
        =/  pg  (parse-page:fl args)
        =/  need=@ud  (mul pg per-page:fl)
        =/  feed-posts=(list [host=@p board-name=board-name =post])
          %-  zing
          %+  turn  ~(tap in followed)
          |=  [host=@p name=board-name]
          ^-  (list [host=@p board-name=board-name =post])
          =/  post-list=(list post)
            ?:  =(host our.bowl)
              =/  brd  (~(get by boards) name)
              ?~  brd  ~
              ~(val by posts.u.brd)
            =/  cb  (~(get by cache) [host name])
            ?~  cb  ~
            ::  skip paid boards we haven't paid for
            ?:  ?&  ?=(^ payment.u.cb)
                    ?|  ?=(~ paid-until.u.cb)
                        (lte u.paid-until.u.cb now.bowl)
                    ==
                ==
              ~
            ~(val by posts.u.cb)
          =/  sorted=(list post)  (sort-posts-by-new:fl post-list)
          (turn (scag need sorted) |=(p=post [host name p]))
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
    ::  notification count (JSON API for header badge)
        [%notif-count ~]
      =/  unread=@ud
        %+  roll  notifications
        |=  [n=notification acc=@ud]
        ?:(read.n acc +(acc))
      (send-json eyre-id 200 (pairs:enjs:format ~[['count' (numb:enjs:format unread)]]))
    ::  notifications page
        [%notifications ~]
      (send-html eyre-id 200 (render-notifications:fl notifications now.bowl dark))
    ::  registry admin (redirect to admin page)
        [%registry ~]
      (redirect eyre-id "/apps/furum/admin")
    ::  admin page
        [%admin ~]
      ?.  =(our.bowl src.bowl)
        (send-html eyre-id 403 (render-error:fl "admin is only available to the ship owner" dark))
      =/  boards-list=(list [board-name board])  ~(tap by boards)
      =/  backups=(list @t)
        (turn backup-dates |=(d=@da (scot %da d)))
      =/  is-registry=?  =(our.bowl registry-ship)
      =/  entries=(list directory-entry)  ~(val by registry)
      =/  subs-list=(list [@p board-name])  ~(tap in subs)
      =/  cache-list=(list [@p board-name cached-board])
        %+  turn  ~(tap by cache)
        |=  [[host=@p name=board-name] cb=cached-board]
        [host name cb]
      =/  msg=@t  (~(gut by args) 'msg' '')
      (send-html eyre-id 200 (render-admin:fl our.bowl dark boards-list backups is-registry entries registry-admins subs-list cache-list msg))
    ::  guide page
        [%guide ~]
      (send-html eyre-id 200 (render-guide:fl dark))
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
        ::  paywall check
        ?.  (has-paid-access our.bowl u.brd now.bowl)
          ?~  payment.u.brd
            ::  no payment config — shouldn't reach here, but don't crash
            (send-html eyre-id 200 (render-error:fl "board configuration error" dark))
          =/  pnd=?  =('payment' (~(gut by args) 'pending' ''))
          =/  ln-nonce=@t  (~(gut by args) 'nonce' '')
          =/  ln-pending=?  =('lightning' (~(gut by args) 'pending' ''))
          ?:  &(ln-pending !=('' ln-nonce))
            =/  inv  (~(get by pending-ln-invoices) ln-nonce)
            ?~  inv
              (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}")
            =/  bolt=(unit @t)  bolt11.u.inv
            (send-html eyre-id 200 (render-lightning-invoice:fl host info.u.brd u.payment.u.brd bolt dark))
          (send-html eyre-id 200 (render-paywall:fl host info.u.brd u.payment.u.brd (~(get by paid.u.brd) our.bowl) dark pnd))
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
      ::  paywall check for remote cached board
      =/  pnd=?  =('payment' (~(gut by args) 'pending' ''))
      ?:  ?=(^ payment.u.cb)
        ::  board has payment config — check if we've paid
        ?:  ?&  ?=(^ paid-until.u.cb)
                (gth u.paid-until.u.cb now.bowl)
            ==
          ::  paid and not expired, show board
          =/  post-list=(list post)  ~(val by posts.u.cb)
          =/  mr  (~(get by my-roles) [host name])
          =/  im=?  ?~(mr %.n =(u.mr %mod))
          =/  srt  (parse-sort:fl args)
          =/  ifl=?  (~(has in followed) [host name])
          =/  pg  (parse-page:fl args)
          =/  bls=(unit @da)  (~(get by board-seen) [host name])
          =.  board-seen  (~(put by board-seen) [host name] now.bowl)
          (send-html eyre-id 200 (render-board:fl host info.u.cb post-list our.bowl now.bowl im %.y dark srt ifl pg pinned.u.cb bls sidebar.u.cb))
        ::  not paid or expired — check for Lightning invoice pending
        =/  ln-nonce=@t  (~(gut by args) 'nonce' '')
        =/  ln-pending=?  =('lightning' (~(gut by args) 'pending' ''))
        ?:  &(ln-pending !=('' ln-nonce))
          =/  inv  (~(get by pending-ln-invoices) ln-nonce)
          ?~  inv
            ::  entry gone — payment completed or expired, redirect to board
            (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}")
          =/  bolt=(unit @t)  bolt11.u.inv
          (send-html eyre-id 200 (render-lightning-invoice:fl host info.u.cb u.payment.u.cb bolt dark))
        ::  show paywall — if pending, re-subscribe to check if payment was processed
        =/  =response-header:http  [200 ~[['content-type' 'text/html'] ['cache-control' 'no-store, no-cache, must-revalidate'] ['pragma' 'no-cache']]]
        =/  data=octs  (manx-to-octs:fl (render-paywall:fl host info.u.cb u.payment.u.cb paid-until.u.cb dark pnd))
        =/  http-cards=(list card)
          :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
              [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`data)]
              [%give %kick ~[/http-response/[eyre-id]] ~]
          ==
        ::  always re-subscribe when showing paywall to refresh cached payment config
        =/  resub-cards=(list card)
          :~  [%pass /board/(scot %p host)/[name] %agent [host %furum] %leave ~]
              [%pass /board/(scot %p host)/[name] %agent [host %furum] %watch /board/[name]]
          ==
        :_  this
        (weld resub-cards http-cards)
      ::  no payment config — free board, show normally
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
        =/  pml=?
          ?&  =('melt' (~(gut by args) 'pending' ''))
              %+  lien  ~(val by pending-melts)
              |=(pm=pending-melt =(name name.pm))
          ==
        =/  sav=@t  (~(gut by args) 'saved' '')
        (send-html eyre-id 200 (render-mod:fl host info.u.brd roles.u.brd %.y dark sidebar.u.brd payment.u.brd wallet.u.brd pml sav paid.u.brd now.bowl prune.u.brd))
      ::  remote board - check my-roles
      =/  mr  (~(get by my-roles) [host name])
      ?.  ?~(mr %.n =(u.mr %mod))
        (send-html eyre-id 403 (render-error:fl "not a moderator" dark))
      =/  cb  (~(get by cache) [host name])
      ?~  cb
        (send-html eyre-id 404 (render-error:fl "board not found in cache" dark))
      =/  pml=?  =('melt' (~(gut by args) 'pending' ''))
      =/  sav=@t  (~(gut by args) 'saved' '')
      (send-html eyre-id 200 (render-mod:fl host info.u.cb roles.u.cb %.n dark sidebar.u.cb ~ *(map @t (list cashu-proof)) pml sav *(map @p @da) now.bowl ~))
    ::  backup wallet proofs: /b/{host}/{name}/mod/backup-proofs
        [%b @ @ %mod %backup-proofs ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?.  =(host our.bowl)
        (send-html eyre-id 403 (render-error:fl "only host can backup proofs" dark))
      =/  brd  (~(get by boards) name)
      ?~  brd
        (send-html eyre-id 404 (render-error:fl "board not found" dark))
      ?.  (is-mod our.bowl u.brd)
        (send-html eyre-id 403 (render-error:fl "not a moderator" dark))
      =/  proof-json=json
        :-  %a
        %-  zing
        %+  turn  ~(tap by wallet.u.brd)
        |=  [mint=@t proofs=(list cashu-proof)]
        ^-  (list json)
        %+  turn  proofs
        |=  p=cashu-proof
        %-  pairs:enjs:format
        :~  ['mint' s+mint]
            ['amount' (numb:enjs:format amount.p)]
            ['id' s+id.p]
            ['secret' s+secret.p]
            ['C' s+c.p]
        ==
      =/  txt=@t  (en:json:html proof-json)
      =/  fname=@t  (crip "{(trip name)}-proofs.json")
      =/  =response-header:http
        :-  200
        :~  ['content-type' 'application/json']
            ['content-disposition' (cat 3 'attachment; filename="' (cat 3 fname '"'))]
            ['cache-control' 'no-store']
        ==
      =/  data=octs  [(met 3 txt) txt]
      :_  this
      :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(response-header)]
          [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(`data)]
          [%give %kick ~[/http-response/[eyre-id]] ~]
      ==
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
      ::  paywall check for remote post detail
      ?:  ?&  ?=(^ payment.u.cb)
              ?|  ?=(~ paid-until.u.cb)
                  (lte u.paid-until.u.cb now.bowl)
              ==
          ==
        (send-html eyre-id 200 (render-paywall:fl host info.u.cb u.payment.u.cb paid-until.u.cb dark %.n))
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
    ::  admin backup: POST /admin/backup
        [%admin %backup ~]
      ?>  =(our.bowl src.bowl)
      =^  cards  this  (handle-action [%backup-to-clay ~])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin?msg=backup-created")
      [(weld cards redir) this]
    ::  admin restore: POST /admin/restore
        [%admin %restore ~]
      ?>  =(our.bowl src.bowl)
      =^  cards  this  (handle-action [%restore-from-clay ~])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin?msg=restore-complete")
      [(weld cards redir) this]
    ::  admin resub: POST /admin/resub
        [%admin %resub ~]
      ?>  =(our.bowl src.bowl)
      =/  host=@p  (slav %p (~(gut by form) 'host' ''))
      =/  name=board-name  (crip (trip (~(gut by form) 'name' '')))
      =^  cards  this  (handle-action [%resub host name])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin?msg=resubscribed")
      [(weld cards redir) this]
    ::  admin refresh registry: POST /admin/refresh-registry
        [%admin %refresh-registry ~]
      ?>  =(our.bowl src.bowl)
      =^  cards  this  (handle-registry-action [%refresh-registry ~])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin")
      [(weld cards redir) this]
    ::  mark notifications read: POST /notifications/read
        [%notifications %read ~]
      =^  cards  this  (handle-action [%mark-notifications-read ~])
      =^  redir  this  (redirect eyre-id "/apps/furum/notifications")
      [(weld cards redir) this]
    ::  add registry admin: POST /registry/add-admin
        [%registry %add-admin ~]
      =/  who-val=@t  (~(gut by form) 'who' '')
      =/  who=@p  (slav %p who-val)
      =^  cards  this  (handle-registry-action [%add-registry-admin who])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin")
      [(weld cards redir) this]
    ::  remove registry admin: POST /registry/remove-admin
        [%registry %remove-admin ~]
      =/  who-val=@t  (~(gut by form) 'who' '')
      =/  who=@p  (slav %p who-val)
      =^  cards  this  (handle-registry-action [%remove-registry-admin who])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin")
      [(weld cards redir) this]
    ::  tag board: POST /registry/tag
        [%registry %tag ~]
      =/  name=@t  (~(gut by form) 'name' '')
      =/  tag=@t  (~(gut by form) 'tag' '')
      =^  cards  this  (handle-registry-action [%tag-board (crip (cass (trip name))) (crip (cass (trip tag)))])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin")
      [(weld cards redir) this]
    ::  untag board: POST /registry/untag
        [%registry %untag ~]
      =/  name=@t  (~(gut by form) 'name' '')
      =/  tag=@t  (~(gut by form) 'tag' '')
      =^  cards  this  (handle-registry-action [%untag-board (crip (cass (trip name))) (crip (cass (trip tag)))])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin")
      [(weld cards redir) this]
    ::  curate board: POST /registry/curate
        [%registry %curate ~]
      =/  name=@t  (~(gut by form) 'name' '')
      =/  curated-val=@t  (~(gut by form) 'curated' '')
      =/  curated=?  =('true' curated-val)
      =^  cards  this  (handle-registry-action [%curate-board (crip (cass (trip name))) curated])
      =^  redir  this  (redirect eyre-id "/apps/furum/admin")
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
      ?:  =(i.t.t.t.path 'mod')
        (send-html eyre-id 404 (render-error:fl "not found" dark))
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
      ::  optimistically update local cache for remote comment
      =/  key  [host name]
      =/  cb  (~(get by cache) key)
      =?  this  ?=(^ cb)
        =/  pc  (~(gut by comments.u.cb) pid *(map comment-id comment))
        =/  next-cid=@ud
          =/  cids=(list comment-id)  ~(tap in ~(key by pc))
          ?~  cids  0
          .+((roll `(list @ud)`cids max))
        =/  =comment
          :*  id=next-cid
              parent=parent
              author=our.bowl
              body=body-val
              created=now.bowl
              up-votes=*(set @p)
              down-votes=*(set @p)
          ==
        =/  pst  (~(get by posts.u.cb) pid)
        =/  new-cb  u.cb(comments (~(put by comments.u.cb) pid (~(put by pc) id.comment comment)))
        =?  new-cb  ?=(^ pst)
          new-cb(posts (~(put by posts.new-cb) pid u.pst(comment-count +(comment-count.u.pst))))
        this(cache (~(put by cache) key new-cb))
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  delete post: POST /b/{host}/{name}/{post-id}/delete
        [%b @ @ @ %delete ~]
      ?:  =(i.t.t.t.path 'mod')
        ::  fall through to %mod %delete handler below
        =/  host=@p  (slav %p i.t.path)
        =/  name=board-name  i.t.t.path
        ?.  =(host our.bowl)
          (send-html eyre-id 403 (render-error:fl "can only delete local boards" dark))
        =/  =action  [%delete-board name]
        =^  cards  this  (handle-action action)
        =^  redir  this  (redirect eyre-id "/apps/furum")
        [(weld cards redir) this]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  pid=@ud  (slav %ud i.t.t.t.path)
      =/  =action  [%delete-post name pid]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      ::  optimistically update local cache for remote delete
      =/  key  [host name]
      =/  cb  (~(get by cache) key)
      =?  this  ?=(^ cb)
        =/  new-cb  u.cb(posts (~(del by posts.u.cb) pid), comments (~(del by comments.u.cb) pid))
        this(cache (~(put by cache) key new-cb))
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
      ::  optimistically update local cache for remote delete-comment
      =/  key  [host name]
      =/  cb  (~(get by cache) key)
      =?  this  ?=(^ cb)
        =/  pc  (~(get by comments.u.cb) pid)
        ?~  pc  this
        =/  pst  (~(get by posts.u.cb) pid)
        =/  new-cb  u.cb(comments (~(put by comments.u.cb) pid (~(del by u.pc) cid)))
        =?  new-cb  ?=(^ pst)
          new-cb(posts (~(put by posts.new-cb) pid u.pst(comment-count ?:((gth comment-count.u.pst 0) (dec comment-count.u.pst) 0))))
        this(cache (~(put by cache) key new-cb))
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
    ::  submit payment: POST /b/{host}/{name}/pay
        [%b @ @ %pay ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  mint=@t  (~(gut by form) 'mint' '')
      =/  tokens=@t  (~(gut by form) 'tokens' '')
      =/  =action  [%submit-payment name mint tokens]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}?pending=payment")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      ::  send payment to host; don't re-subscribe yet (host will kick us as unpaid)
      ::  the pending page reload will re-subscribe after payment is processed
      =/  pay-cards=(list card)
        :~  [%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)]
        ==
      [(weld pay-cards redir) this]
    ::  pay with Lightning: POST /b/{host}/{name}/pay-lightning
        [%b @ @ %pay-lightning ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  nonce=@t  (scot %uv (sham [now.bowl our.bowl name eny.bowl]))
      ::  store pending invoice locally
      =.  pending-ln-invoices
        (~(put by pending-ln-invoices) nonce [host name ~ 0 0])
      ::  poke host and subscribe to invoice path
      =/  =action  [%request-lightning-invoice name nonce]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}?pending=lightning&nonce={(trip nonce)}")
      =/  pay-cards=(list card)
        :~  [%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)]
            [%pass /invoice/[name]/[nonce] %agent [host %furum] %watch /invoice/[name]/[nonce]]
        ==
      [(weld pay-cards redir) this]
    ::  set prune config: POST /b/{host}/{name}/mod/prune
        [%b @ @ %mod %prune ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?.  =(host our.bowl)
        (send-html eyre-id 403 (render-error:fl "can only set prune on local boards" dark))
      =/  enabled=@t  (~(gut by form) 'prune-enabled' 'off')
      =/  prune=(unit prune-config)
        ?.  =('on' enabled)  ~
        =/  score-val=@t  (~(gut by form) 'min-score' '2')
        =/  days-val=@t  (~(gut by form) 'after-days' '7')
        =/  score=@ud
          %+  roll  (trip score-val)
          |=  [c=@ acc=@ud]
          ?:  |((lth c '0') (gth c '9'))  acc
          (add (mul acc 10) (sub c '0'))
        =/  days=@ud
          %+  roll  (trip days-val)
          |=  [c=@ acc=@ud]
          ?:  |((lth c '0') (gth c '9'))  acc
          (add (mul acc 10) (sub c '0'))
        `[score (mul days ~d1)]
      =/  =action  [%set-prune name prune]
      =^  cards  this  (handle-action action)
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod")
      [(weld cards redir) this]
    ::  set payment config: POST /b/{host}/{name}/mod/payment
        [%b @ @ %mod %payment ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      =/  enabled=@t  (~(gut by form) 'enabled' 'off')
      =/  price-val=@t  (crip (skip (trip (~(gut by form) 'price' '0')) |=(c=@ =(c '.'))))
      =/  interval-val=@t  (crip (skip (trip (~(gut by form) 'interval' '30')) |=(c=@ =(c '.'))))
      =/  price=@ud
        %+  roll  (trip price-val)
        |=  [c=@ acc=@ud]
        (add (mul acc 10) (sub c '0'))
      =/  days=@ud
        %+  roll  (trip interval-val)
        |=  [c=@ acc=@ud]
        (add (mul acc 10) (sub c '0'))
      =/  mint-val=@t  (~(gut by form) 'mint-url' '')
      =/  mint-opt=(unit @t)  ?:(=('' mint-val) ~ `mint-val)
      =/  pay=(unit payment-config)
        ?.  =('on' enabled)  ~
        `[price (mul ~d1 days) mint-opt]
      =/  =action  [%set-payment name pay]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod?saved=payment")
      ?:  =(host our.bowl)
        =^  cards  this  (handle-action action)
        [(weld cards redir) this]
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  melt to lightning: POST /b/{host}/{name}/mod/melt
        [%b @ @ %mod %melt ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?.  =(host our.bowl)
        (send-html eyre-id 403 (render-error:fl "can only withdraw from local boards" dark))
      =/  mint=@t  (~(gut by form) 'mint' '')
      =/  invoice=@t  (~(gut by form) 'invoice' '')
      =/  =action  [%melt-to-lightning name mint invoice]
      =^  cards  this  (handle-action action)
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod?pending=melt")
      [(weld cards redir) this]
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
      ::  optimistically update local cache for remote vote
      =/  key  [host name]
      =/  cb  (~(get by cache) key)
      =?  this  ?=(^ cb)
        ?-    -.u.target
            %post
          =/  pst  (~(get by posts.u.cb) id.u.target)
          ?~  pst  this
          =/  new-up=(set @p)
            ?:(=('up' dir-val) (~(put in up-votes.u.pst) our.bowl) (~(del in up-votes.u.pst) our.bowl))
          =/  new-dn=(set @p)
            ?:(=('down' dir-val) (~(put in down-votes.u.pst) our.bowl) (~(del in down-votes.u.pst) our.bowl))
          this(cache (~(put by cache) key u.cb(posts (~(put by posts.u.cb) id.u.target u.pst(up-votes new-up, down-votes new-dn)))))
        ::
            %comment
          =/  pc  (~(get by comments.u.cb) post.u.target)
          ?~  pc  this
          =/  cmt  (~(get by u.pc) id.u.target)
          ?~  cmt  this
          =/  new-up=(set @p)
            ?:(=('up' dir-val) (~(put in up-votes.u.cmt) our.bowl) (~(del in up-votes.u.cmt) our.bowl))
          =/  new-dn=(set @p)
            ?:(=('down' dir-val) (~(put in down-votes.u.cmt) our.bowl) (~(del in down-votes.u.cmt) our.bowl))
          this(cache (~(put by cache) key u.cb(comments (~(put by comments.u.cb) post.u.target (~(put by u.pc) id.u.target u.cmt(up-votes new-up, down-votes new-dn))))))
        ==
      [[[%pass /mod-action %agent [host %furum] %poke %furum-action !>(action)] redir] this]
    ::  edit board info: POST /b/{host}/{name}/mod/edit-info
        [%b @ @ %mod %edit-info ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?.  =(host our.bowl)
        (send-html eyre-id 403 (render-error:fl "can only edit local boards" dark))
      =/  title-val=@t  (~(gut by form) 'title' '')
      =/  desc-val=@t  (~(gut by form) 'description' '')
      =/  =action  [%edit-board-info name title-val desc-val]
      =^  cards  this  (handle-action action)
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod")
      [(weld cards redir) this]
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
    ::  register board in directory: POST /b/{host}/{name}/mod/register
        [%b @ @ %mod %register ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?.  =(host our.bowl)
        (send-html eyre-id 403 (render-error:fl "can only register local boards" dark))
      =/  brd  (~(get by boards) name)
      ?~  brd
        (send-html eyre-id 404 (render-error:fl "board not found" dark))
      ?:  =(our.bowl registry-ship)
        =^  cards  this  (handle-registry-action [%register name title.info.u.brd description.info.u.brd])
        =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod?saved=registered")
        [(weld cards redir) this]
      =^  redir  this  (redirect eyre-id "/apps/furum/b/{(scow %p host)}/{(trip name)}/mod?saved=registered")
      [[[%pass /register %agent [registry-ship %furum] %poke %furum-registry-action !>(`registry-action`[%register name title.info.u.brd description.info.u.brd])] redir] this]
    ::  delete board: POST /b/{host}/{name}/mod/delete
        [%b @ @ %mod %delete ~]
      =/  host=@p  (slav %p i.t.path)
      =/  name=board-name  i.t.t.path
      ?.  =(host our.bowl)
        (send-html eyre-id 403 (render-error:fl "can only delete local boards" dark))
      =/  =action  [%delete-board name]
      =^  cards  this  (handle-action action)
      =^  redir  this  (redirect eyre-id "/apps/furum")
      [(weld cards redir) this]
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
      =/  pst  (~(get by posts.brd) id.target)
      ?~  pst  `this
      =/  new-up  ?:(=(direction %up) (~(put in up-votes.u.pst) who) (~(del in up-votes.u.pst) who))
      =/  new-down  ?:(=(direction %down) (~(put in down-votes.u.pst) who) (~(del in down-votes.u.pst) who))
      =/  new-pst  u.pst(up-votes new-up, down-votes new-down)
      =/  new-brd  brd(posts (~(put by posts.brd) id.target new-pst))
      :_  this(boards (~(put by boards) name new-brd))
      :~  (give-board-update name [%vote-update target new-up new-down])
      ==
    ::
        %comment
      =/  pc  (~(get by comments.brd) post.target)
      ?~  pc  `this
      =/  cmt  (~(get by u.pc) id.target)
      ?~  cmt  `this
      =/  new-up  ?:(=(direction %up) (~(put in up-votes.u.cmt) who) (~(del in up-votes.u.cmt) who))
      =/  new-down  ?:(=(direction %down) (~(put in down-votes.u.cmt) who) (~(del in down-votes.u.cmt) who))
      =/  new-cmt  u.cmt(up-votes new-up, down-votes new-down)
      =/  new-brd  brd(comments (~(put by comments.brd) post.target (~(put by u.pc) id.target new-cmt)))
      :_  this(boards (~(put by boards) name new-brd))
      :~  (give-board-update name [%vote-update target new-up new-down])
      ==
    ==
  ::
  ++  do-swap
    |=  [nonce=@t who=@p name=board-name total=@ud mint=@t keyset-id=@t tokens=@t brd=board]
    ^-  (quip card _this)
    =/  amounts=(list @ud)  (split-amount:ca total)
    =/  idx=@ud  0
    =/  secrets=(list @t)  ~
    =/  bfactors=(list @)  ~
    =/  outputs=(list [amount=@ud id=@t b-hex=@t])  ~
    |-  ^-  (quip card _this)
    ?:  (gte idx (lent amounts))
      =/  input-json  (de:json:html tokens)
      ?~  input-json  ~|(%bad-input-json !!)
      =/  jon  u.input-json
      ?.  ?=([%o *] jon)  ~|(%bad-input-json !!)
      =/  inputs  (~(got by p.jon) 'inputs')
      =/  swap-req=json  (build-swap-request:ca inputs (flop outputs))
      =/  swap-body=@t  (en:json:html swap-req)
      =/  swap-octs=octs  [(met 3 swap-body) swap-body]
      =/  mint-clean=tape  (clean-mint-url:ca mint)
      =/  swap-url=@t  (crip (weld mint-clean "/v1/swap"))
      =.  pending-swaps
        %+  ~(put by pending-swaps)  nonce
        :*  who  name  total  mint  keyset-id  %swap  tokens
            (flop secrets)  (flop bfactors)
        ==
      :_  this
      :~  [%pass /iris/swap/[nonce] %arvo %i %request [%'POST' swap-url ~[['content-type' 'application/json']] `swap-octs] *outbound-config:iris]
      ==
    =/  amt=@ud  (snag idx amounts)
    =/  eny-seed=@  (sham [eny.bowl nonce idx now.bowl])
    =/  [b-hex=@t secret=@t blinding-factor=@]  (make-output:ca amt keyset-id eny-seed)
    %=  $
      idx  +(idx)
      secrets  [secret secrets]
      bfactors  [blinding-factor bfactors]
      outputs  [[amt keyset-id b-hex] outputs]
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
    =/  subscriber-role=role  (get-role src.bowl brd)
    =/  sub-paid-until=(unit @da)
      ?~  payment.brd  ~
      (~(get by paid.brd) src.bowl)
    =/  has-access=?  (has-paid-access src.bowl brd now.bowl)
    =/  post-list=(list post)
      ?.  has-access  ~
      ~(val by posts.brd)
    =/  cmts=(map post-id (map comment-id comment))
      ?.  has-access  *(map post-id (map comment-id comment))
      comments.brd
    =/  pins=(set post-id)
      ?.  has-access  *(set post-id)
      pinned.brd
    =/  sb=@t
      ?.  has-access  ''
      sidebar.brd
    =/  init-cards=(list card)
      :~  [%give %fact ~ %furum-update !>(`update`[%initial info.brd roles.brd post-list cmts pins sb payment.brd sub-paid-until])]
          [%give %fact ~ %furum-update !>(`update`[%role-update src.bowl `subscriber-role])]
      ==
    ::  kick unpaid subscribers so they don't receive ongoing content updates
    =?  init-cards  &(?=(^ payment.brd) !has-access)
      (snoc init-cards [%give %kick ~ `src.bowl])
    :_  this
    init-cards
    ::  Lightning invoice subscription
    ::
      [%invoice @ @ ~]
    =/  name=board-name  i.t.path
    =/  brd  (~(get by boards) name)
    ?~  brd  `this
    ?~  payment.u.brd  `this
    ::  if there's already a pending mint for this nonce, send the invoice
    =/  nonce=@t  i.t.t.path
    =/  pending  (~(get by pending-mints) nonce)
    ?~  pending  `this
    ?:  =('' bolt11.u.pending)  `this
    =/  upd=update  [%lightning-invoice nonce bolt11.u.pending amount.u.pending 0]
    :_  this
    :~  [%give %fact ~ %furum-update !>(upd)]
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
  ::  -- JSON endpoints for MCP / external tools --
  ::  scry with: /api/ENDPOINT/json
  ::
      [%x %api %boards ~]
    =/  entries=(list json)
      %+  turn  ~(tap by boards)
      |=  [name=board-name brd=board]
      ^-  json
      %-  pairs:enjs:format
      :~  ['name' s+name]
          ['title' s+title.info.brd]
          ['description' s+description.info.brd]
          ['posts' (numb:enjs:format ~(wyt by posts.brd))]
          ['public' b+public.info.brd]
          ['paid' b+?=(^ payment.brd)]
      ==
    ``json+!>([%a entries])
  ::
      [%x %api %board @ ~]
    =/  name=board-name  i.t.t.t.path
    =/  brd  (~(get by boards) name)
    ?~  brd  [~ ~]
    ?^  payment.u.brd  [~ ~]  ::  hide paid board content
    =/  post-list=(list json)
      %+  turn
        %+  sort  ~(val by posts.u.brd)
        |=  [a=post b=post]
        (gth created.a created.b)
      |=  =post
      ^-  json
      =/  up=@ud  ~(wyt in up-votes.post)
      =/  dn=@ud  ~(wyt in down-votes.post)
      %-  pairs:enjs:format
      :~  ['id' (numb:enjs:format id.post)]
          ['author' s+(scot %p author.post)]
          ['title' s+title.post]
          ['url' ?~(url.post ~ s+u.url.post)]
          ['body' ?~(body.post ~ s+u.body.post)]
          ['created' s+(scot %da created.post)]
          ['points' (numb:enjs:format ?:((gte up dn) (sub up dn) 0))]
          ['comments' (numb:enjs:format comment-count.post)]
      ==
    ``json+!>((pairs:enjs:format ~[['name' s+name] ['title' s+title.info.u.brd] ['description' s+description.info.u.brd] ['posts' [%a post-list]]]))
  ::
      [%x %api %post @ @ ~]
    =/  name=board-name  i.t.t.t.path
    =/  pid=@ud  (slav %ud i.t.t.t.t.path)
    =/  brd  (~(get by boards) name)
    ?~  brd  [~ ~]
    ?^  payment.u.brd  [~ ~]  ::  hide paid board content
    =/  pst  (~(get by posts.u.brd) pid)
    ?~  pst  [~ ~]
    =/  cmts  (~(gut by comments.u.brd) pid *(map comment-id comment))
    =/  comment-list=(list json)
      %+  turn
        %+  sort  ~(val by cmts)
        |=  [a=comment b=comment]
        (gth created.a created.b)
      |=  =comment
      ^-  json
      =/  up=@ud  ~(wyt in up-votes.comment)
      =/  dn=@ud  ~(wyt in down-votes.comment)
      %-  pairs:enjs:format
      :~  ['id' (numb:enjs:format id.comment)]
          ['parent' ?~(parent.comment ~ (numb:enjs:format u.parent.comment))]
          ['author' s+(scot %p author.comment)]
          ['body' s+body.comment]
          ['created' s+(scot %da created.comment)]
          ['points' (numb:enjs:format ?:((gte up dn) (sub up dn) 0))]
      ==
    =/  up=@ud  ~(wyt in up-votes.u.pst)
    =/  dn=@ud  ~(wyt in down-votes.u.pst)
    ``json+!>((pairs:enjs:format ~[['id' (numb:enjs:format id.u.pst)] ['author' s+(scot %p author.u.pst)] ['title' s+title.u.pst] ['url' ?~(url.u.pst ~ s+u.url.u.pst)] ['body' ?~(body.u.pst ~ s+u.body.u.pst)] ['created' s+(scot %da created.u.pst)] ['points' (numb:enjs:format ?:((gte up dn) (sub up dn) 0))] ['comments' [%a comment-list]]]))
  ::
      [%x %api %notifications ~]
    =/  notif-list=(list json)
      %+  turn  notifications
      |=  n=notification
      ^-  json
      %-  pairs:enjs:format
      :~  ['title' s+title.n]
          ['body' s+body.n]
          ['url' ?~(url.n ~ s+u.url.n)]
          ['time' s+(scot %da time.n)]
          ['read' b+read.n]
      ==
    ``json+!>([%a notif-list])
  ::
      [%x %api %cache ~]
    =/  entries=(list json)
      %+  turn  ~(tap by cache)
      |=  [[host=@p name=board-name] cb=cached-board]
      ^-  json
      %-  pairs:enjs:format
      :~  ['host' s+(scot %p host)]
          ['name' s+name]
          ['title' s+title.info.cb]
          ['posts' (numb:enjs:format ~(wyt by posts.cb))]
          ['paid-until' ?~(paid-until.cb ~ s+(scot %da u.paid-until.cb))]
      ==
    ``json+!>([%a entries])
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?+    wire  (on-agent:def wire sign)
    ::  poke acks (register, mod actions, notifications)
    ::
      [%register ~]  `this
      [%mod-action ~]  `this
      [%notify *]  `this
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
      ::  don't auto-resub if we're kicked from a paid board we haven't paid for
      =/  cb  (~(get by cache) [host name])
      ?:  ?&  ?=(^ cb)
              ?=(^ payment.u.cb)
              ?|  ?=(~ paid-until.u.cb)
                  (lte u.paid-until.u.cb now.bowl)
              ==
          ==
        `this
      :_  this
      :~  [%pass /board/(scot %p host)/[name] %agent [host %furum] %watch /board/[name]]
      ==
    ::
        %watch-ack
      ?~  p.sign  `this
      `this
    ==
    ::  Lightning invoice subscription responses
    ::
      [%invoice @ @ ~]
    =/  name=board-name  i.t.wire
    =/  nonce=@t  i.t.t.wire
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  `this
          %furum-update
        =/  upd  !<(update q.cage.sign)
        ?.  ?=([%lightning-invoice *] upd)  `this
        ::  store the invoice locally
        =/  existing  (~(get by pending-ln-invoices) nonce)
        ?~  existing  `this
        `this(pending-ln-invoices (~(put by pending-ln-invoices) nonce u.existing(bolt11 `bolt11.upd, amount amount.upd, expiry expiry.upd)))
      ==
    ::
        %kick
      ::  host kicks /invoice after successful payment — re-subscribe to board for content
      =/  inv  (~(get by pending-ln-invoices) nonce)
      =.  pending-ln-invoices  (~(del by pending-ln-invoices) nonce)
      ?~  inv  `this
      :_  this
      :~  [%pass /board/(scot %p host.u.inv)/[name] %agent [host.u.inv %furum] %leave ~]
          [%pass /board/(scot %p host.u.inv)/[name] %agent [host.u.inv %furum] %watch /board/[name]]
      ==
    ::
        %watch-ack
      ?~  p.sign  `this
      ::  watch failed — clean up
      `this(pending-ln-invoices (~(del by pending-ln-invoices) nonce))
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
        [info.upd roles.upd post-map comments.upd pinned.upd sidebar.upd payment.upd paid-until.upd]
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
    ::
        %payment-config-update
      =/  cb  (~(got by cache) key)
      `this(cache (~(put by cache) key cb(payment payment.upd)))
    ::
        %paid-update
      ?.  =(who.upd our.bowl)  `this
      =/  cb  (~(get by cache) key)
      ?~  cb  `this
      ::  update paid-until, then re-subscribe to get full content
      =.  cache  (~(put by cache) key u.cb(paid-until `paid-until.upd))
      :_  this
      :~  [%pass /board/(scot %p host)/[name] %agent [host %furum] %leave ~]
          [%pass /board/(scot %p host)/[name] %agent [host %furum] %watch /board/[name]]
      ==
    ::
        %lightning-invoice
      ::  handled via /invoice subscription, not board subscription
      `this
    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%write-backup ~]
    `this
  ::
      [%eyre %connect ~]
    `this
  ::
      [%prune @ ~]
    =/  name=board-name  i.t.wire
    ?.  ?=([%behn %wake *] sign-arvo)  `this
    =/  brd  (~(get by boards) name)
    ?~  brd  `this
    ?~  prune.u.brd  `this
    =/  min-score=@ud  min-score.u.prune.u.brd
    =/  after=@dr  after.u.prune.u.brd
    =/  cutoff=@da  (sub now.bowl after)
    ::  find posts to prune: older than cutoff, below min score, not pinned
    =/  to-prune=(list post-id)
      %+  murn  ~(tap by posts.u.brd)
      |=  [id=post-id =post]
      ^-  (unit post-id)
      ?:  (~(has in pinned.u.brd) id)  ~
      ?:  (gth created.post cutoff)  ~
      =/  up=@ud  ~(wyt in up-votes.post)
      =/  dn=@ud  ~(wyt in down-votes.post)
      =/  score=@ud  ?:((gte up dn) (sub up dn) 0)
      ?:  (gte score min-score)  ~
      `id
    ::  prune posts and their comments — build delete cards
    =/  prune-cards=(list card)
      (turn to-prune |=(pid=post-id (give-board-update name [%delete-post pid])))
    ::  remove pruned posts from board
    =/  pruned-brd=board
      %+  roll  to-prune
      |=  [pid=post-id b=_u.brd]
      %=  b
        posts             (~(del by posts.b) pid)
        comments          (~(del by comments.b) pid)
        next-comment-ids  (~(del by next-comment-ids.b) pid)
      ==
    ~&  >>>  [%prune-cycle name (lent to-prune)]
    ::  schedule next prune cycle
    :_  this(boards (~(put by boards) name pruned-brd))
    [[%pass /prune/[name] %arvo %b %wait (add now.bowl ~h6)] prune-cards]
  ::
      [%iris %swap @ ~]
    =/  nonce=@t  i.t.t.wire
    =/  pending  (~(get by pending-swaps) nonce)
    ?~  pending
      ~&  >>>  [%ecash-swap-unknown-nonce nonce]
      `this
    ?.  ?=([%iris %http-response *] sign-arvo)
      ~&  >>>  [%ecash-swap-bad-response name.u.pending who.u.pending]
      =.  pending-swaps  (~(del by pending-swaps) nonce)
      `this
    =/  =client-response:iris  client-response.sign-arvo
    ?.  ?=([%finished *] client-response)
      `this
    =/  response=response-header:http  response-header.client-response
    =/  body=(unit octs)  ?~(full-file.client-response ~ `data.u.full-file.client-response)
    ?.  =(200 status-code.response)
      =/  err-body=@t
        ?~  body  'no body'
        =/  raw  (trip q.u.body)
        (crip (scag 500 raw))
      ~&  >>>  [%ecash-swap-mint-rejected name.u.pending who.u.pending status-code.response err-body]
      =.  pending-swaps  (~(del by pending-swaps) nonce)
      `this
    ?~  body
      ~&  >>>  [%ecash-swap-empty-response name.u.pending who.u.pending]
      =.  pending-swaps  (~(del by pending-swaps) nonce)
      `this
    =/  resp-json  (de:json:html q.u.body)
    ?~  resp-json
      ~&  >>>  [%ecash-swap-invalid-json name.u.pending who.u.pending]
      =.  pending-swaps  (~(del by pending-swaps) nonce)
      `this
    ::  dispatch based on current step
    ?-    step.u.pending
        %fetch-keys
      ::  we just fetched keyset keys — parse and cache them, then proceed to swap
      =/  jon  u.resp-json
      =/  brd  (~(get by boards) name.u.pending)
      ?~  brd
        ~&  >>>  [%ecash-swap-board-gone name.u.pending]
        =.  pending-swaps  (~(del by pending-swaps) nonce)
        `this
      ::  parse keyset response: {keysets: [{id, unit, keys: {amount: hex_pubkey}}]}
      ?.  ?=([%o *] jon)
        ~&  >>>  [%ecash-swap-bad-keyset name.u.pending]
        =.  pending-swaps  (~(del by pending-swaps) nonce)
        `this
      =/  keys-val=(unit json)
        =/  ks  (~(get by p.jon) 'keysets')
        ?~  ks  (~(get by p.jon) 'keys')
        ?.  ?=([%a *] u.ks)  (~(get by p.jon) 'keys')
        =/  first  (snag 0 p.u.ks)
        ?.  ?=([%o *] first)  (~(get by p.jon) 'keys')
        (~(get by p.first) 'keys')
      ?~  keys-val
        ~&  >>>  [%ecash-swap-no-keys name.u.pending]
        =.  pending-swaps  (~(del by pending-swaps) nonce)
        `this
      ?.  ?=([%o *] u.keys-val)
        ~&  >>>  [%ecash-swap-bad-keys-format name.u.pending]
        =.  pending-swaps  (~(del by pending-swaps) nonce)
        `this
      ::  store keys as amt -> hex_pubkey in mint-keysets
      =/  key-map=(map @ud @t)
        %-  ~(rep by p.u.keys-val)
        |=  [[amt-key=@t hex-val=json] acc=(map @ud @t)]
        ?.  ?=([%s *] hex-val)  acc
        =/  amt=@ud  (roll (trip amt-key) |=([c=@ a=@ud] (add (mul a 10) (sub c '0'))))
        ?:  =(0 amt)  acc
        (~(put by acc) amt p.hex-val)
      =/  new-brd  u.brd(mint-keysets (~(put by mint-keysets.u.brd) keyset-id.u.pending key-map))
      =.  boards  (~(put by boards) name.u.pending new-brd)
      =.  pending-swaps  (~(del by pending-swaps) nonce)
      ::  now do the actual swap with cached keys
      =/  amounts=(list @ud)  (split-amount:ca amount.u.pending)
      =/  idx=@ud  0
      =/  secrets=(list @t)  ~
      =/  bfactors=(list @)  ~
      =/  swap-outputs=(list [amount=@ud id=@t b-hex=@t])  ~
      |-  ^-  (quip card _this)
      ?:  (gte idx (lent amounts))
        =/  input-json  (de:json:html input-proofs.u.pending)
        ?~  input-json  ~|(%bad-input-json !!)
        =/  ij  u.input-json
        ?.  ?=([%o *] ij)  ~|(%bad-input-json !!)
        =/  inputs  (~(got by p.ij) 'inputs')
        =/  swap-body=@t  (en:json:html (build-swap-request:ca inputs (flop swap-outputs)))
        =/  swap-octs=octs  [(met 3 swap-body) swap-body]
        =/  mint-clean=tape  (clean-mint-url:ca mint.u.pending)
        =/  swap-url=@t  (crip (weld mint-clean "/v1/swap"))
        =.  pending-swaps
          %+  ~(put by pending-swaps)  nonce
          :*  who.u.pending  name.u.pending  amount.u.pending  mint.u.pending
              keyset-id.u.pending  %swap  input-proofs.u.pending
              (flop secrets)  (flop bfactors)
          ==
        :_  this
        :~  [%pass /iris/swap/[nonce] %arvo %i %request [%'POST' swap-url ~[['content-type' 'application/json']] `swap-octs] *outbound-config:iris]
        ==
      =/  amt=@ud  (snag idx amounts)
      =/  eny-seed=@  (sham [eny.bowl nonce idx now.bowl])
      =/  [b-hex=@t secret=@t blinding-factor=@]  (make-output:ca amt keyset-id.u.pending eny-seed)
      %=  $
        idx  +(idx)
        secrets  [secret secrets]
        bfactors  [blinding-factor bfactors]
        swap-outputs  [[amt keyset-id.u.pending b-hex] swap-outputs]
      ==
    ::
        %swap
      ::  swap response — unblind signatures and store proofs
      =/  jon  u.resp-json
      =/  brd  (~(get by boards) name.u.pending)
      ?~  brd
        ~&  >>>  [%ecash-swap-board-gone name.u.pending]
        =.  pending-swaps  (~(del by pending-swaps) nonce)
        `this
      =/  sigs  (parse-swap-response:ca jon)
      ::  resolve mint public keys from cached keysets
      =/  key-map=(map @ud @t)  (~(gut by mint-keysets.u.brd) keyset-id.u.pending *(map @ud @t))
      =/  mint-keys=(map @ud [x=@ y=@])
        %-  ~(rep by key-map)
        |=  [[amt=@ud hex=@t] acc=(map @ud [x=@ y=@])]
        =/  result  (mule |.((hex-to-point:ca hex)))
        ?.  ?=([%& *] result)
          ~&  >>>  [%invalid-mint-key amt hex]
          acc
        (~(put by acc) amt p.result)
      =/  new-proofs=(list cashu-proof)
        %:  finalize-proofs:ca
          sigs
          secrets.u.pending
          blinding-factors.u.pending
          mint-keys
        ==
      ::  log new proofs for recovery
      ~&  >>>  [%ecash-swap-proofs (turn new-proofs |=(p=cashu-proof [amount.p id.p secret.p c.p]))]
      ::  add new proofs to wallet
      =/  existing-proofs=(list cashu-proof)  (~(gut by wallet.u.brd) mint.u.pending ~)
      =/  updated-wallet  (~(put by wallet.u.brd) mint.u.pending (weld existing-proofs new-proofs))
      =/  new-brd  u.brd(wallet updated-wallet)
      ::  grant access
      =/  pay  payment.new-brd
      ?~  pay
        ~&  >>>  [%ecash-swap-no-config name.u.pending]
        =.  pending-swaps  (~(del by pending-swaps) nonce)
        `this
      =/  existing  (~(get by paid.new-brd) who.u.pending)
      =/  base=@da  ?~(existing now.bowl ?:((gth u.existing now.bowl) u.existing now.bowl))
      =/  paid-until=@da  (add base interval.u.pay)
      =/  final-brd  new-brd(paid (~(put by paid.new-brd) who.u.pending paid-until))
      =.  pending-swaps  (~(del by pending-swaps) nonce)
      ~&  >>>  [%ecash-swap-success name.u.pending who.u.pending (lent new-proofs) paid-until]
      =/  notify-act=action  [%notify 'New paid subscriber' (crip "{(scow %p who.u.pending)} paid for access to {(trip name.u.pending)}") ~ (sy %payments ~)]
      :_  this(boards (~(put by boards) name.u.pending final-brd))
      :~  (give-board-update name.u.pending [%paid-update who.u.pending paid-until])
          [%pass /notify/payment %agent [our.bowl %furum] %poke %furum-action !>(notify-act)]
      ==
    ==
  ::
      [%iris %melt @ ~]
    =/  nonce=@t  i.t.t.wire
    =/  pending  (~(get by pending-melts) nonce)
    ?~  pending
      ~&  >>>  [%ecash-melt-unknown-nonce nonce]
      `this
    =/  restore-melt-proofs
      |=  pm=pending-melt
      ^-  (quip card _this)
      ?.  =(%execute step.pm)  `this
      =/  brd  (~(get by boards) name.pm)
      ?~  brd  `this
      =/  existing=(list cashu-proof)  (~(gut by wallet.u.brd) mint.pm ~)
      =/  new-brd  u.brd(wallet (~(put by wallet.u.brd) mint.pm (weld existing proofs-used.pm)))
      `this(boards (~(put by boards) name.pm new-brd))
    ?.  ?=([%iris %http-response *] sign-arvo)
      ~&  >>>  [%ecash-melt-bad-response name.u.pending]
      =.  pending-melts  (~(del by pending-melts) nonce)
      (restore-melt-proofs u.pending)
    =/  =client-response:iris  client-response.sign-arvo
    ?.  ?=([%finished *] client-response)
      `this
    =/  response=response-header:http  response-header.client-response
    =/  body=(unit octs)  ?~(full-file.client-response ~ `data.u.full-file.client-response)
    ?.  =(200 status-code.response)
      =/  err-body=@t
        ?~  body  'no body'
        (crip (scag 500 (trip q.u.body)))
      ~&  >>>  [%ecash-melt-rejected name.u.pending status-code.response err-body]
      =.  pending-melts  (~(del by pending-melts) nonce)
      (restore-melt-proofs u.pending)
    ?~  body
      ~&  >>>  [%ecash-melt-empty-response name.u.pending]
      =.  pending-melts  (~(del by pending-melts) nonce)
      (restore-melt-proofs u.pending)
    =/  resp-json  (de:json:html q.u.body)
    ?~  resp-json
      ~&  >>>  [%ecash-melt-invalid-json name.u.pending]
      =.  pending-melts  (~(del by pending-melts) nonce)
      (restore-melt-proofs u.pending)
    =/  jon  u.resp-json
    ?-    step.u.pending
        %quote
      ::  got melt quote — now execute with proofs
      =/  quote-result  (parse-melt-quote:ca jon)
      ?~  quote-result
        ~&  >>>  [%ecash-melt-bad-quote name.u.pending]
        =.  pending-melts  (~(del by pending-melts) nonce)
        `this
      =/  [quote-id=@t quote-amt=@ud fee-res=@ud]  u.quote-result
      ::  select proofs to cover amount + fee
      =/  needed=@ud  (add quote-amt fee-res)
      =/  brd  (~(get by boards) name.u.pending)
      ?~  brd
        =.  pending-melts  (~(del by pending-melts) nonce)
        `this
      =/  all-proofs=(list cashu-proof)  (~(gut by wallet.u.brd) mint.u.pending ~)
      ::  select proofs until we have enough
      =/  selected=(list cashu-proof)  ~
      =/  remaining=(list cashu-proof)  ~
      =/  selected-total=@ud  0
      =/  proofs-to-scan=(list cashu-proof)  all-proofs
      |-  ^-  (quip card _this)
      ?~  proofs-to-scan
        ::  not enough proofs
        ?.  (gte selected-total needed)
          ~&  >>>  [%ecash-melt-insufficient-funds name.u.pending needed selected-total]
          =.  pending-melts  (~(del by pending-melts) nonce)
          `this
        ::  send melt execution
        ~&  >>>  [%ecash-melt-proofs (turn selected |=(p=cashu-proof [amount.p id.p secret.p c.p]))]
        =/  melt-body=@t
          %:  en:json:html
            %:  build-melt-request:ca
              quote-id
              %+  turn  selected
              |=(p=cashu-proof [amount.p id.p secret.p c.p])
            ==
          ==
        =/  melt-octs=octs  [(met 3 melt-body) melt-body]
        =/  mint-clean=tape  (clean-mint-url:ca mint.u.pending)
        =/  melt-url=@t  (crip (weld mint-clean "/v1/melt/bolt11"))
        =.  pending-melts
          %+  ~(put by pending-melts)  nonce
          u.pending(step %execute, quote-id quote-id, fee-reserve fee-res, proofs-used selected)
        ::  remove used proofs from wallet
        =/  new-brd  u.brd(wallet (~(put by wallet.u.brd) mint.u.pending remaining))
        =.  boards  (~(put by boards) name.u.pending new-brd)
        :_  this
        :~  [%pass /iris/melt/[nonce] %arvo %i %request [%'POST' melt-url ~[['content-type' 'application/json']] `melt-octs] *outbound-config:iris]
        ==
      ?:  (gte selected-total needed)
        ::  have enough — proceed to send
        =/  remaining-rest  proofs-to-scan
        =.  remaining  (weld remaining remaining-rest)
        =/  melt-body=@t
          %:  en:json:html
            %:  build-melt-request:ca
              quote-id
              %+  turn  selected
              |=(p=cashu-proof [amount.p id.p secret.p c.p])
            ==
          ==
        =/  melt-octs=octs  [(met 3 melt-body) melt-body]
        =/  mint-clean=tape  (clean-mint-url:ca mint.u.pending)
        =/  melt-url=@t  (crip (weld mint-clean "/v1/melt/bolt11"))
        =.  pending-melts
          %+  ~(put by pending-melts)  nonce
          u.pending(step %execute, quote-id quote-id, fee-reserve fee-res, proofs-used selected)
        =/  new-brd  u.brd(wallet (~(put by wallet.u.brd) mint.u.pending remaining))
        =.  boards  (~(put by boards) name.u.pending new-brd)
        :_  this
        :~  [%pass /iris/melt/[nonce] %arvo %i %request [%'POST' melt-url ~[['content-type' 'application/json']] `melt-octs] *outbound-config:iris]
        ==
      ::  add this proof and continue
      %=  $
        selected  [i.proofs-to-scan selected]
        selected-total  (add selected-total amount.i.proofs-to-scan)
        proofs-to-scan  t.proofs-to-scan
      ==
    ::
        %execute
      ::  melt completed — check result
      =/  melt-result  (parse-melt-response:ca jon)
      ?~  melt-result
        ~&  >>>  [%ecash-melt-bad-response-format name.u.pending]
        ::  melt failed — return proofs to wallet
        =/  brd  (~(get by boards) name.u.pending)
        =.  pending-melts  (~(del by pending-melts) nonce)
        ?~  brd  `this
        =/  existing=(list cashu-proof)  (~(gut by wallet.u.brd) mint.u.pending ~)
        =/  new-brd  u.brd(wallet (~(put by wallet.u.brd) mint.u.pending (weld existing proofs-used.u.pending)))
        `this(boards (~(put by boards) name.u.pending new-brd))
      ?.  paid.u.melt-result
        ~&  >>>  [%ecash-melt-not-paid name.u.pending state.u.melt-result]
        ::  melt failed — return proofs to wallet
        =/  brd  (~(get by boards) name.u.pending)
        =.  pending-melts  (~(del by pending-melts) nonce)
        ?~  brd  `this
        =/  existing=(list cashu-proof)  (~(gut by wallet.u.brd) mint.u.pending ~)
        =/  new-brd  u.brd(wallet (~(put by wallet.u.brd) mint.u.pending (weld existing proofs-used.u.pending)))
        `this(boards (~(put by boards) name.u.pending new-brd))
      ::  success — proofs already removed from wallet
      ~&  [%ecash-melt-success name.u.pending]
      =.  pending-melts  (~(del by pending-melts) nonce)
      `this
    ==
  ::
  ::  -- NUT-04 mint (Lightning invoice) handlers --
  ::
      [%iris %mint-keys @ ~]
    =/  nonce=@t  i.t.t.wire
    =/  pending  (~(get by pending-mints) nonce)
    ?~  pending
      ~&  >>>  [%ln-mint-keys-unknown-nonce nonce]
      `this
    ?.  ?=([%iris %http-response *] sign-arvo)
      ~&  >>>  [%ln-mint-keys-bad-response name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  =client-response:iris  client-response.sign-arvo
    ?.  ?=([%finished *] client-response)  `this
    =/  response=response-header:http  response-header.client-response
    =/  body=(unit octs)  ?~(full-file.client-response ~ `data.u.full-file.client-response)
    ?.  =(200 status-code.response)
      ~&  >>>  [%ln-mint-keys-rejected name.u.pending status-code.response]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ?~  body
      ~&  >>>  [%ln-mint-keys-empty name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  resp-json  (de:json:html q.u.body)
    ?~  resp-json
      ~&  >>>  [%ln-mint-keys-bad-json name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ::  parse /v1/keysets response: {keysets: [{id, unit, active, ...}]}
    =/  jon  u.resp-json
    ?.  ?=([%o *] jon)
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  ks  (~(get by p.jon) 'keysets')
    ?~  ks
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ?.  ?=([%a *] u.ks)
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ::  find first active keyset with unit=sat
    =/  matching=(list @t)
      %+  murn  p.u.ks
      |=  item=json
      ^-  (unit @t)
      ?.  ?=([%o *] item)  ~
      =/  active  (~(get by p.item) 'active')
      =/  unit-val  (~(get by p.item) 'unit')
      =/  id-val  (~(get by p.item) 'id')
      ?.  ?=([~ %b *] active)  ~
      ?.  =(%.y p.u.active)  ~
      ?.  ?=([~ %s *] unit-val)  ~
      ?.  =('sat' p.u.unit-val)  ~
      ?~  id-val  ~
      ?.  ?=([%s *] u.id-val)  ~
      (some p.u.id-val)
    =/  kid=@t  ?~(matching '' i.matching)
    ?:  =('' kid)
      ~&  >>>  [%ln-mint-no-active-keyset name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ::  now fetch the actual keys for this keyset
    =.  pending-mints
      (~(put by pending-mints) nonce u.pending(keyset-id kid, step %quote))
    =/  mint-clean=tape  (clean-mint-url:ca mint.u.pending)
    =/  keys-url=@t  (crip (weld mint-clean "/v1/keys/{(trip kid)}"))
    :_  this
    :~  [%pass /iris/mint-keyset/[nonce] %arvo %i %request [%'GET' keys-url ~ ~] *outbound-config:iris]
    ==
  ::
      [%iris %mint-keyset @ ~]
    =/  nonce=@t  i.t.t.wire
    =/  pending  (~(get by pending-mints) nonce)
    ?~  pending
      `this
    ?.  ?=([%iris %http-response *] sign-arvo)
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  =client-response:iris  client-response.sign-arvo
    ?.  ?=([%finished *] client-response)  `this
    =/  response=response-header:http  response-header.client-response
    =/  body=(unit octs)  ?~(full-file.client-response ~ `data.u.full-file.client-response)
    ?.  =(200 status-code.response)
      ~&  >>>  [%ln-mint-keyset-rejected name.u.pending status-code.response]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ?~  body
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  resp-json  (de:json:html q.u.body)
    ?~  resp-json
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ::  parse keys and cache them
    =/  jon  u.resp-json
    ?.  ?=([%o *] jon)
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  keys-val=(unit json)
      =/  ks  (~(get by p.jon) 'keysets')
      ?~  ks  (~(get by p.jon) 'keys')
      ?.  ?=([%a *] u.ks)  (~(get by p.jon) 'keys')
      =/  first  (snag 0 p.u.ks)
      ?.  ?=([%o *] first)  (~(get by p.jon) 'keys')
      (~(get by p.first) 'keys')
    ?~  keys-val
      ~&  >>>  [%ln-mint-keyset-no-keys name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ?.  ?=([%o *] u.keys-val)
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  key-map=(map @ud @t)
      %-  ~(rep by p.u.keys-val)
      |=  [[amt-key=@t hex-val=json] acc=(map @ud @t)]
      ?.  ?=([%s *] hex-val)  acc
      =/  amt=@ud  (roll (trip amt-key) |=([c=@ a=@ud] (add (mul a 10) (sub c '0'))))
      ?:  =(0 amt)  acc
      (~(put by acc) amt p.hex-val)
    =/  brd  (~(get by boards) name.u.pending)
    ?~  brd
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  new-brd  u.brd(mint-keysets (~(put by mint-keysets.u.brd) keyset-id.u.pending key-map))
    =.  boards  (~(put by boards) name.u.pending new-brd)
    ::  now request mint quote
    =/  quote-body=@t  (en:json:html (build-mint-quote-request:ca amount.u.pending 'sat'))
    =/  quote-octs=octs  [(met 3 quote-body) quote-body]
    =/  mint-clean=tape  (clean-mint-url:ca mint.u.pending)
    =/  quote-url=@t  (crip (weld mint-clean "/v1/mint/quote/bolt11"))
    :_  this
    :~  [%pass /iris/mint-quote/[nonce] %arvo %i %request [%'POST' quote-url ~[['content-type' 'application/json']] `quote-octs] *outbound-config:iris]
    ==
  ::
      [%iris %mint-quote @ ~]
    =/  nonce=@t  i.t.t.wire
    =/  pending  (~(get by pending-mints) nonce)
    ?~  pending
      ~&  >>>  [%ln-mint-quote-unknown-nonce nonce]
      `this
    ?.  ?=([%iris %http-response *] sign-arvo)
      ~&  >>>  [%ln-mint-quote-bad-response name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  =client-response:iris  client-response.sign-arvo
    ?.  ?=([%finished *] client-response)  `this
    =/  response=response-header:http  response-header.client-response
    =/  body=(unit octs)  ?~(full-file.client-response ~ `data.u.full-file.client-response)
    ?.  =(200 status-code.response)
      =/  err-body=@t
        ?~  body  'no body'
        (crip (scag 500 (trip q.u.body)))
      ~&  >>>  [%ln-mint-quote-rejected name.u.pending status-code.response err-body]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ?~  body
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  resp-json  (de:json:html q.u.body)
    ?~  resp-json
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  quote-result  (parse-mint-quote:ca u.resp-json)
    ?~  quote-result
      ~&  >>>  [%ln-mint-quote-bad-format name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ::  convert unix expiry to @da (unix epoch = ~1970.1.1)
    =/  expiry-da=@da  (add ~1970.1.1 (mul expiry.u.quote-result (bex 64)))
    ::  update pending state
    =.  pending-mints
      %+  ~(put by pending-mints)  nonce
      u.pending(quote-id quote.u.quote-result, bolt11 request.u.quote-result, expiry expiry-da, step %check-quote)
    ::  send invoice to payer via subscription
    =/  invoice-path=path  /invoice/[name.u.pending]/[nonce]
    =/  upd=update  [%lightning-invoice nonce request.u.quote-result amount.u.pending expiry.u.quote-result]
    ::  start polling timer
    :_  this
    :~  [%give %fact ~[invoice-path] %furum-update !>(upd)]
        [%pass /timer/mint/[nonce] %arvo %b %wait (add now.bowl ~s5)]
    ==
  ::
      [%timer %mint @ ~]
    =/  nonce=@t  i.t.t.wire
    =/  pending  (~(get by pending-mints) nonce)
    ?~  pending
      `this
    ?.  ?=([%behn %wake *] sign-arvo)
      `this
    ::  check if expired
    ?:  (gth now.bowl expiry.u.pending)
      ~&  >>>  [%ln-mint-expired name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ::  poll quote status
    =/  mint-clean=tape  (clean-mint-url:ca mint.u.pending)
    =/  check-url=@t  (crip (weld mint-clean "/v1/mint/quote/bolt11/{(trip quote-id.u.pending)}"))
    :_  this
    :~  [%pass /iris/mint-check/[nonce] %arvo %i %request [%'GET' check-url ~ ~] *outbound-config:iris]
    ==
  ::
      [%iris %mint-check @ ~]
    =/  nonce=@t  i.t.t.wire
    =/  pending  (~(get by pending-mints) nonce)
    ?~  pending
      `this
    ?.  ?=([%iris %http-response *] sign-arvo)
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  =client-response:iris  client-response.sign-arvo
    ?.  ?=([%finished *] client-response)  `this
    =/  response=response-header:http  response-header.client-response
    =/  body=(unit octs)  ?~(full-file.client-response ~ `data.u.full-file.client-response)
    ?.  =(200 status-code.response)
      ::  check failed, retry later
      :_  this
      :~  [%pass /timer/mint/[nonce] %arvo %b %wait (add now.bowl ~s5)]
      ==
    ?~  body
      :_  this
      :~  [%pass /timer/mint/[nonce] %arvo %b %wait (add now.bowl ~s5)]
      ==
    =/  resp-json  (de:json:html q.u.body)
    ?~  resp-json
      :_  this
      :~  [%pass /timer/mint/[nonce] %arvo %b %wait (add now.bowl ~s5)]
      ==
    =/  quote-result  (parse-mint-quote:ca u.resp-json)
    ?~  quote-result
      :_  this
      :~  [%pass /timer/mint/[nonce] %arvo %b %wait (add now.bowl ~s5)]
      ==
    ?:  =(state.u.quote-result 'PAID')
      ::  invoice paid — generate blinded outputs and mint tokens
      =/  brd  (~(get by boards) name.u.pending)
      ?~  brd
        =.  pending-mints  (~(del by pending-mints) nonce)
        `this
      =/  amounts=(list @ud)  (split-amount:ca amount.u.pending)
      =/  idx=@ud  0
      =/  secrets=(list @t)  ~
      =/  bfactors=(list @)  ~
      =/  mint-outputs=(list [amount=@ud id=@t b-hex=@t])  ~
      |-  ^-  (quip card _this)
      ?:  (gte idx (lent amounts))
        ::  all outputs generated, send mint request
        =/  mint-req=json  (build-mint-request:ca quote-id.u.pending (flop mint-outputs))
        =/  mint-body=@t  (en:json:html mint-req)
        =/  mint-octs=octs  [(met 3 mint-body) mint-body]
        =/  mint-clean=tape  (clean-mint-url:ca mint.u.pending)
        =/  mint-url=@t  (crip (weld mint-clean "/v1/mint/bolt11"))
        =.  pending-mints
          (~(put by pending-mints) nonce u.pending(step %mint-tokens, secrets (flop secrets), blinding-factors (flop bfactors)))
        :_  this
        :~  [%pass /iris/mint-exec/[nonce] %arvo %i %request [%'POST' mint-url ~[['content-type' 'application/json']] `mint-octs] *outbound-config:iris]
        ==
      =/  amt=@ud  (snag idx amounts)
      =/  eny-seed=@  (sham [eny.bowl nonce idx now.bowl])
      =/  [b-hex=@t secret=@t blinding-factor=@]  (make-output:ca amt keyset-id.u.pending eny-seed)
      %=  $
        idx  +(idx)
        secrets  [secret secrets]
        bfactors  [blinding-factor bfactors]
        mint-outputs  [[amt keyset-id.u.pending b-hex] mint-outputs]
      ==
    ::  not paid yet — schedule another check
    :_  this
    :~  [%pass /timer/mint/[nonce] %arvo %b %wait (add now.bowl ~s5)]
    ==
  ::
      [%iris %mint-exec @ ~]
    =/  nonce=@t  i.t.t.wire
    =/  pending  (~(get by pending-mints) nonce)
    ?~  pending
      `this
    ?.  ?=([%iris %http-response *] sign-arvo)
      ~&  >>>  [%ln-mint-exec-bad-response name.u.pending]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  =client-response:iris  client-response.sign-arvo
    ?.  ?=([%finished *] client-response)  `this
    =/  response=response-header:http  response-header.client-response
    =/  body=(unit octs)  ?~(full-file.client-response ~ `data.u.full-file.client-response)
    ?.  =(200 status-code.response)
      =/  err-body=@t
        ?~  body  'no body'
        (crip (scag 500 (trip q.u.body)))
      ~&  >>>  [%ln-mint-exec-rejected name.u.pending status-code.response err-body]
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ?~  body
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  resp-json  (de:json:html q.u.body)
    ?~  resp-json
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    ::  parse signatures and unblind (same format as swap response)
    =/  sigs  (parse-swap-response:ca u.resp-json)
    =/  brd  (~(get by boards) name.u.pending)
    ?~  brd
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this
    =/  key-map=(map @ud @t)  (~(gut by mint-keysets.u.brd) keyset-id.u.pending *(map @ud @t))
    =/  mint-keys=(map @ud [x=@ y=@])
      %-  ~(rep by key-map)
      |=  [[amt=@ud hex=@t] acc=(map @ud [x=@ y=@])]
      =/  result  (mule |.((hex-to-point:ca hex)))
      ?.  ?=([%& *] result)
        ~&  >>>  [%invalid-mint-key amt hex]
        acc
      (~(put by acc) amt p.result)
    =/  new-proofs=(list cashu-proof)
      %:  finalize-proofs:ca
        sigs
        secrets.u.pending
        blinding-factors.u.pending
        mint-keys
      ==
    ::  add proofs to wallet
    =/  existing-proofs=(list cashu-proof)  (~(gut by wallet.u.brd) mint.u.pending ~)
    =/  updated-wallet  (~(put by wallet.u.brd) mint.u.pending (weld existing-proofs new-proofs))
    =/  new-brd  u.brd(wallet updated-wallet)
    ::  grant paid access
    =/  pay  payment.new-brd
    ?~  pay
      =.  pending-mints  (~(del by pending-mints) nonce)
      `this(boards (~(put by boards) name.u.pending new-brd))
    =/  existing  (~(get by paid.new-brd) who.u.pending)
    =/  base=@da  ?~(existing now.bowl ?:((gth u.existing now.bowl) u.existing now.bowl))
    =/  paid-until=@da  (add base interval.u.pay)
    =/  final-brd  new-brd(paid (~(put by paid.new-brd) who.u.pending paid-until))
    =.  pending-mints  (~(del by pending-mints) nonce)
    ~&  >>>  [%ln-mint-success name.u.pending who.u.pending (lent new-proofs) paid-until]
    =/  notify-act=action  [%notify 'New paid subscriber' (crip "{(scow %p who.u.pending)} paid for access to {(trip name.u.pending)}") ~ (sy %payments ~)]
    :_  this(boards (~(put by boards) name.u.pending final-brd))
    :~  (give-board-update name.u.pending [%paid-update who.u.pending paid-until])
        [%give %kick ~[/invoice/[name.u.pending]/[nonce]] ~]
        [%pass /notify/payment %agent [our.bowl %furum] %poke %furum-action !>(notify-act)]
    ==
  ==
::
++  on-fail  on-fail:def
--
