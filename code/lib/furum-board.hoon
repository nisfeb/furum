::  lib/furum-board.hoon: a board in the ball. +load assembles the Gall
::  agent's $board, the shape the pages and the rules take, from a board
::  directory's grubs; +grubs splits one back; +act is each host action
::  as a pure transition, ported from the agent's +handle-action.
::
/<  *   /lib/furum-types.hoon
/<  fr  /lib/furum-rules.hoon
/<  fl  /lib/furum.hoon
|%
::  a grub under a board's directory: its path there (name last), and
::  the noun it holds
::
+$  grub  [pax=path val=*]
::
++  bucket
  |=  id=post-id
  ^-  @ta
  (crip "b{(a-co:co (div id 100))}")
::
+$  parts
  $:  card=(unit board-info)
      roles=(map @p role)
      conf=board-conf
      pins=(set post-id)
      side=@t
      cores=(map post-id post-core)
      threads=(map post-id thread)
      votes=(map vote-target tally)
  ==
::
::  +load: a board from its directory's grubs, or why not. A grub that no
::  shape fits is named, never skipped: the writer must not write back a
::  board it could read only part of. Grubs it doesn't know are ignored.
::
++  load
  |=  gs=(list grub)
  ^-  (each board @t)
  =|  acc=parts
  |-  ^-  (each board @t)
  ?~  gs
    ?~  card.acc  |+'no card'
    &+(assemble acc)
  =*  pax  pax.i.gs
  =*  val  val.i.gs
  =/  bad  |+(cat 3 'unreadable: ' (spat pax))
  ?+    pax  $(gs t.gs)
      [%card ~]
    ?~  v=(mole |.(;;([%1 board-info] val)))  bad
    $(gs t.gs, card.acc `+.u.v)
  ::
      [%roles ~]
    ?~  v=(mole |.(;;([%1 (map @p role)] val)))  bad
    $(gs t.gs, roles.acc +.u.v)
  ::
      [%conf ~]
    ?~  v=(mole |.(;;([%1 board-conf] val)))  bad
    $(gs t.gs, conf.acc +.u.v)
  ::
      [%content %pins ~]
    ?~  v=(mole |.(;;([%1 (set post-id)] val)))  bad
    $(gs t.gs, pins.acc +.u.v)
  ::
      [%content %sidebar ~]
    ?~  v=(mole |.(;;([%1 @t] val)))  bad
    $(gs t.gs, side.acc +.u.v)
  ::
      [%content %posts @ ~]
    ?~  v=(mole |.(;;([%1 (map post-id post-core)] val)))  bad
    $(gs t.gs, cores.acc (~(uni by cores.acc) +.u.v))
  ::
      [%content %threads @ ~]
    ?~  v=(mole |.(;;([%1 (map post-id thread)] val)))  bad
    $(gs t.gs, threads.acc (~(uni by threads.acc) +.u.v))
  ::
      [%content %votes @ ~]
    ?~  v=(mole |.(;;([%1 (map vote-target tally)] val)))  bad
    $(gs t.gs, votes.acc (~(uni by votes.acc) +.u.v))
  ==
::
++  assemble
  |=  acc=parts
  ^-  board
  =/  posts=(map post-id post)
    %-  ~(urn by cores.acc)
    |=  [id=post-id c=post-core]
    ^-  post
    =/  t=tally  (~(gut by votes.acc) [%post id] *tally)
    =/  n=@ud  ?~(th=(~(get by threads.acc) id) 0 ~(wyt by comments.u.th))
    [id.c author.c title.c url.c body.c created.c up.t down.t n]
  =/  comments=(map post-id (map comment-id comment))
    %-  ~(urn by threads.acc)
    |=  [pid=post-id th=thread]
    %-  ~(urn by comments.th)
    |=  [cid=comment-id c=comment-core]
    ^-  comment
    =/  t=tally  (~(gut by votes.acc) [%comment pid cid] *tally)
    [id.c parent.c author.c body.c created.c up.t down.t]
  =|  brd=board
  %=  brd
    info              (need card.acc)
    roles             roles.acc
    next-post-id      next-post.conf.acc
    posts             posts
    comments          comments
    next-comment-ids  (~(run by threads.acc) |=(th=thread next.th))
    pinned            pins.acc
    sidebar           side.acc
    prune             prune.conf.acc
  ==
::
::  +grubs: a board as the grubs that hold it. A bucket with nothing in it
::  is left out; so is a post's thread before its first comment.
::
++  grubs
  |=  brd=board
  ^-  (map path *)
  =/  in-bucket
    |=  [dir=@ta id=post-id key=* val=* acc=(map path (map * *))]
    ^+  acc
    =/  pax=path  /content/[dir]/(bucket id)
    (~(put by acc) pax (~(put by (~(gut by acc) pax ~)) key val))
  =|  acc=(map path (map * *))
  =.  acc
    %+  roll  ~(tap by posts.brd)
    |=  [[id=post-id p=post] =_acc]
    =.  acc
      (in-bucket %posts id id `post-core`[id.p author.p title.p url.p body.p created.p] acc)
    ?:  &(=(~ up-votes.p) =(~ down-votes.p))  acc
    (in-bucket %votes id [%post id] `tally`[up-votes.p down-votes.p] acc)
  =.  acc
    %+  roll  ~(tap by next-comment-ids.brd)
    |=  [[pid=post-id next=comment-id] =_acc]
    ?:  =(0 next)  acc
    =/  cs=(map comment-id comment)  (~(gut by comments.brd) pid ~)
    =/  cores=(map comment-id comment-core)
      (~(run by cs) |=(c=comment `comment-core`[id.c parent.c author.c body.c created.c]))
    =.  acc  (in-bucket %threads pid pid `thread`[next cores] acc)
    %+  roll  ~(tap by cs)
    |=  [[cid=comment-id c=comment] =_acc]
    ?:  &(=(~ up-votes.c) =(~ down-votes.c))  acc
    (in-bucket %votes pid [%comment pid cid] `tally`[up-votes.c down-votes.c] acc)
  =/  out=(map path *)  (~(run by acc) |=(m=(map * *) [%1 m]))
  %-  ~(gas by out)
  ^-  (list [path *])
  :~  [/card [%1 info.brd]]
      [/roles [%1 roles.brd]]
      [/conf [%1 `board-conf`[next-post-id.brd prune.brd]]]
      [/content/pins [%1 pinned.brd]]
      [/content/sidebar [%1 sidebar.brd]]
  ==
::
::  +act: one host action on a board, by `who`. `old` is the board as it
::  stands (~ when there is none); the answer is the board after (~ once
::  deleted) and the rate limits after, or why the action is refused.
::  The agent asserted these checks; here each is a refusal a page can show.
::
++  act
  |=  [who=@p our=@p now=@da =action old=(unit board) lim=limits]
  ^-  (each [brd=(unit board) lim=limits] deny)
  ?:  ?=(%create-board -.action)
    ?.  =(who our)  |+[403 'only the host may create a board']
    ?.  (valid-board-name:fl name.action)
      |+[400 'board names may only use a-z, 0-9 and -']
    ?^  old  |+[409 'you already host a board with that name']
    =|  brd=board
    =.  info.brd
      :*  name.action
          (crip (scag 200 (trip title.action)))
          (crip (scag 2.000 (trip description.action)))
          our  now  default-role.action  |
      ==
    &+[`brd lim]
  ?~  old  |+[404 'board not found']
  =/  brd=board  u.old
  =/  done  |=(b=board &+[`b lim])
  =/  paid=?  (has-paid-access:fr who brd now)
  =/  mod=?  (is-mod:fr who brd)
  ?+    -.action  |+[400 'not a board action']
      %delete-board
    ?.  =(who our)  |+[403 'only the host may delete a board']
    &+[~ lim]
  ::
      %edit-board-info
    ?.  =(who our)  |+[403 'only the host may edit a board']
    ?:  =('' title.action)  |+[400 'a board needs a title']
    %-  done
    %=  brd
      title.info        (crip (scag 200 (trip title.action)))
      description.info  (crip (scag 2.000 (trip description.action)))
    ==
  ::
      %set-public
    ?.  =(who our)  |+[403 'only the host may open a board']
    ?:  &(public.action ?=(^ payment.brd))  |+[400 'a paid board cannot be public']
    (done brd(public.info public.action))
  ::
      %set-prune
    ?.  =(who our)  |+[403 'only the host may set auto-prune']
    (done brd(prune prune.action))
  ::
      %pin-post
    ?.  mod  |+[403 'only a moderator may pin']
    %-  done
    %=  brd
      pinned  ?:  pinned.action
                (~(put in pinned.brd) id.action)
              (~(del in pinned.brd) id.action)
    ==
  ::
      %set-sidebar
    ?.  mod  |+[403 'only a moderator may set the sidebar']
    ?:  (gth (met 3 sidebar.action) 10.000)  |+[400 'the sidebar holds at most 10,000 bytes']
    (done brd(sidebar sidebar.action))
  ::
      %set-role
    ?.  mod  |+[403 'only a moderator may set roles']
    (done brd(roles (~(put by roles.brd) who.action role.action)))
  ::
      %remove-role
    ?.  mod  |+[403 'only a moderator may set roles']
    (done brd(roles (~(del by roles.brd) who.action)))
  ::
      %new-post
    ?.  paid  |+[402 'this board needs a paid membership']
    ?.  (can-post:fr who brd)  |+[403 'your role on this board cannot post']
    ?.  (check-rate-limit:fr who name.action brd now lim)
      |+[429 'you\'re posting too fast — please wait a bit and try again']
    ?.  (sane-post:fr title.action url.action body.action)
      |+[400 'a post needs a title (300 bytes at most), a url of 2,048 and a body of 40,000']
    =/  id=post-id  next-post-id.brd
    :-  %&
    :_  ?:(mod lim (update-rate-limit:fr who name.action now lim))
    :-  ~
    %=  brd
      next-post-id  +(id)
      posts  (~(put by posts.brd) id [id who title.action url.action body.action now ~ ~ 0])
    ==
  ::
      %delete-post
    ?~  p=(~(get by posts.brd) id.action)  |+[404 'post not found']
    ?.  (can-delete:fr who author.u.p brd)  |+[403 'only its author or a moderator may delete a post']
    (done (drop-posts brd ~[id.action]))
  ::
      %edit-post
    ?.  paid  |+[402 'this board needs a paid membership']
    ?~  p=(~(get by posts.brd) id.action)  |+[404 'post not found']
    ?.  =(who author.u.p)  |+[403 'only the author can edit this post']
    ?.  (sane-post:fr title.action ~ body.action)
      |+[400 'a post needs a title (300 bytes at most) and a body of 40,000']
    (done brd(posts (~(put by posts.brd) id.action u.p(title title.action, body body.action))))
  ::
      %new-comment
    ?.  paid  |+[402 'this board needs a paid membership']
    ?.  (can-post:fr who brd)  |+[403 'your role on this board cannot comment']
    ?.  (check-rate-limit:fr who name.action brd now lim)
      |+[429 'you\'re commenting too fast — please wait a bit and try again']
    ?.  (sane-comment:fr body.action)  |+[400 'a comment holds 1 to 10,000 bytes']
    ?~  p=(~(get by posts.brd) post.action)  |+[404 'post not found']
    =/  pc=(map comment-id comment)  (~(gut by comments.brd) post.action ~)
    ?:  ?&(?=(^ parent.action) !(~(has by pc) u.parent.action))
      |+[404 'no such comment to reply to']
    =/  cid=comment-id  (~(gut by next-comment-ids.brd) post.action 0)
    :-  %&
    :_  ?:(mod lim (update-rate-limit:fr who name.action now lim))
    :-  ~
    %=  brd
      comments          (~(put by comments.brd) post.action (~(put by pc) cid [cid parent.action who body.action now ~ ~]))
      next-comment-ids  (~(put by next-comment-ids.brd) post.action +(cid))
      posts             (~(put by posts.brd) post.action u.p(comment-count +(comment-count.u.p)))
    ==
  ::
      %delete-comment
    =/  pc=(map comment-id comment)  (~(gut by comments.brd) post.action ~)
    ?~  c=(~(get by pc) id.action)  (done brd)
    ?.  (can-delete:fr who author.u.c brd)  |+[403 'only its author or a moderator may delete a comment']
    =.  comments.brd  (~(put by comments.brd) post.action (~(del by pc) id.action))
    ?~  p=(~(get by posts.brd) post.action)  (done brd)
    (done brd(posts (~(put by posts.brd) post.action u.p(comment-count (dec (max 1 comment-count.u.p))))))
  ::
      %upvote       ?.(paid |+[402 'this board needs a paid membership'] (done (vote brd target.action who %up)))
      %downvote     ?.(paid |+[402 'this board needs a paid membership'] (done (vote brd target.action who %down)))
      %remove-vote  ?.(paid |+[402 'this board needs a paid membership'] (done (vote brd target.action who %remove)))
  ==
::
::  +notes-for: who hears of an action, applied: the host, of a new
::  post by someone else; the post's author, of a comment on it; the
::  author of a comment, of a reply to it. Never the actor, and nobody
::  twice. `brd` is the board after the action.
::
++  notes-for
  |=  [who=@p =action brd=board]
  ^-  (list note-out)
  =/  host=@p  host.info.brd
  =/  at  |=(t=tape `(crip "/apps/furum/b/{(scow %p host)}/{(trip name.info.brd)}{t}"))
  ?+    -.action  ~
      %new-post
    ?:  =(who host)  ~
    ?:  =(0 next-post-id.brd)  ~
    :~  :*  host  'New post on your board'
            (crip "{(scow %p who)} posted '{(trip title.action)}' to {(trip name.action)}")
            (at "/{(a-co:co (dec next-post-id.brd))}")  (sy ~[%new-posts])
    ==  ==
  ::
      %new-comment
    ?~  p=(~(get by posts.brd) post.action)  ~
    =/  url  (at "/{(a-co:co post.action)}")
    =/  to-author=(list note-out)
      ?:  =(who author.u.p)  ~
      :~  :*  author.u.p  'New comment on your post'
              (crip "{(scow %p who)} commented on '{(trip title.u.p)}'")
              url  (sy ~[%comments])
      ==  ==
    ?~  parent.action  to-author
    ?~  c=(~(get by (~(gut by comments.brd) post.action ~)) u.parent.action)  to-author
    ?:  |(=(who author.u.c) =(author.u.c author.u.p))  to-author
    %+  snoc  to-author
    :*  author.u.c  'Reply to your comment'
        (crip "{(scow %p who)} replied to your comment on '{(trip title.u.p)}'")
        url  (sy ~[%comments])
    ==
  ==
::
::  +drop-posts: posts gone, with their threads
::
++  drop-posts
  |=  [brd=board ids=(list post-id)]
  ^-  board
  %+  roll  ids
  |=  [id=post-id b=_brd]
  %=  b
    posts             (~(del by posts.b) id)
    comments          (~(del by comments.b) id)
    next-comment-ids  (~(del by next-comment-ids.b) id)
  ==
::
::  +vote: one ship's vote on a post or comment; a vote on nothing is
::  nothing
::
++  vote
  |=  [brd=board target=vote-target who=@p dir=?(%up %down %remove)]
  ^-  board
  =/  cast
    |=  [up=(set @p) dn=(set @p)]
    ^-  [(set @p) (set @p)]
    :-  ?:(=(%up dir) (~(put in up) who) (~(del in up) who))
    ?:(=(%down dir) (~(put in dn) who) (~(del in dn) who))
  ?-    -.target
      %post
    ?~  p=(~(get by posts.brd) id.target)  brd
    =/  [up=(set @p) dn=(set @p)]  (cast up-votes.u.p down-votes.u.p)
    brd(posts (~(put by posts.brd) id.target u.p(up-votes up, down-votes dn)))
  ::
      %comment
    ?~  pc=(~(get by comments.brd) post.target)  brd
    ?~  c=(~(get by u.pc) id.target)  brd
    =/  [up=(set @p) dn=(set @p)]  (cast up-votes.u.c down-votes.u.c)
    =/  new=(map comment-id comment)  (~(put by u.pc) id.target u.c(up-votes up, down-votes dn))
    brd(comments (~(put by comments.brd) post.target new))
  ==
--
