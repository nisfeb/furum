::  sur/furum.hoon: type definitions for %furum
::
|%
::  identity types
::
+$  board-name    @tas
+$  post-id       @ud
+$  comment-id    @ud
+$  role          ?(%mod %poster %reader)
::
::  board metadata
::
+$  board-info
  $:  name=board-name
      title=@t
      description=@t
      host=@p
      created=@da
      default-role=role
      public=?
  ==
::
::  a post
::
+$  post
  $:  id=post-id
      author=@p
      title=@t
      url=(unit @t)
      body=(unit @t)
      created=@da
      up-votes=(set @p)
      down-votes=(set @p)
      comment-count=@ud
  ==
::
::  a comment
::
+$  comment
  $:  id=comment-id
      parent=(unit comment-id)
      author=@p
      body=@t
      created=@da
      up-votes=(set @p)
      down-votes=(set @p)
  ==
::
::  vote target discriminator
::
+$  vote-target
  $%  [%post id=post-id]
      [%comment post=post-id id=comment-id]
  ==
::
::  full board state (on host ship)
::
+$  payment-config
  $:  price=@ud
      interval=@dr
      mint=(unit @t)
  ==
::
::  a stored cashu proof (host wallet)
::
+$  cashu-proof
  $:  amount=@ud
      id=@t
      secret=@t
      c=@t
  ==
::
+$  board
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
::  registry directory entry
::
+$  directory-entry
  $:  name=board-name
      title=@t
      description=@t
      host=@p
      tags=(set @tas)
      curated=?
  ==
::
::  client-side cached board
::
+$  cached-board
  $:  info=board-info
      roles=(map @p role)
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      pinned=(set post-id)
      sidebar=@t
      payment=(unit payment-config)
      paid-until=(unit @da)
  ==
::
::  actions: pokes to a board host
::
+$  action
  $%  ::  board management (host ship only)
      [%create-board name=board-name title=@t description=@t default-role=role]
      [%delete-board name=board-name]
      ::  moderation
      [%set-role name=board-name who=@p =role]
      [%remove-role name=board-name who=@p]
      ::  content
      [%new-post name=board-name title=@t url=(unit @t) body=(unit @t)]
      [%delete-post name=board-name id=post-id]
      [%edit-post name=board-name id=post-id title=@t body=(unit @t)]
      ::  comments
      [%new-comment name=board-name post=post-id parent=(unit comment-id) body=@t]
      [%delete-comment name=board-name post=post-id id=comment-id]
      ::  board settings
      [%set-public name=board-name public=?]
      ::  pinning
      [%pin-post name=board-name id=post-id pinned=?]
      ::  sidebar
      [%set-sidebar name=board-name sidebar=@t]
      ::  payment
      [%set-payment name=board-name payment=(unit payment-config)]
      [%submit-payment name=board-name mint=@t tokens=@t]
      [%melt-to-lightning name=board-name mint=@t invoice=@t]
      [%request-lightning-invoice name=board-name nonce=@t]
      [%revoke-paid name=board-name who=@p]
      [%clear-wallet name=board-name]
      ::  subscriptions
      [%resub host=@p name=board-name]
      ::  following
      [%follow-board host=@p name=board-name]
      [%unfollow-board host=@p name=board-name]
      ::  preferences
      [%toggle-dark-mode ~]
      ::  votes
      [%upvote name=board-name target=vote-target]
      [%downvote name=board-name target=vote-target]
      [%remove-vote name=board-name target=vote-target]
  ==
::
::  registry actions: pokes to the registry ship
::
+$  registry-action
  $%  [%register name=board-name title=@t description=@t]
      [%unregister name=board-name]
      [%tag-board name=board-name tag=@tas]
      [%untag-board name=board-name tag=@tas]
      [%curate-board name=board-name curated=?]
      [%add-registry-admin who=@p]
      [%remove-registry-admin who=@p]
  ==
::
::  updates: subscription facts from a board host
::
+$  update
  $%  [%initial info=board-info roles=(map @p role) posts=(list post) comments=(map post-id (map comment-id comment)) pinned=(set post-id) sidebar=@t payment=(unit payment-config) paid-until=(unit @da)]
      [%new-post =post]
      [%delete-post id=post-id]
      [%edit-post id=post-id title=@t body=(unit @t)]
      [%new-comment post=post-id =comment]
      [%delete-comment post=post-id id=comment-id]
      [%vote-update target=vote-target up-votes=(set @p) down-votes=(set @p)]
      [%role-update who=@p role=(unit role)]
      [%board-info-update info=board-info]
      [%pin-update id=post-id pinned=?]
      [%sidebar-update sidebar=@t]
      [%payment-config-update payment=(unit payment-config)]
      [%paid-update who=@p paid-until=@da]
      [%lightning-invoice nonce=@t bolt11=@t amount=@ud expiry=@ud]
  ==
::
::  registry updates: subscription facts from the registry
::
+$  registry-update
  $%  [%initial entries=(list directory-entry)]
      [%add =directory-entry]
      [%remove name=board-name]
      [%tag name=board-name tags=(set @tas)]
      [%curate name=board-name curated=?]
  ==
--
