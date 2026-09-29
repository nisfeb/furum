::  tests for lib/furum-board: a board survives the trip into grubs and
::  back, the buckets hold what they should, and each host action checks
::  what the agent asserted
::
/+  *test, *furum-types, fb=furum-board
|%
++  now  ~2026.1.1
++  host  ~zod
::  run actions in order from nothing; each must be allowed
::
++  play
  |=  acts=(list [who=@p =action])
  ^-  [(unit board) limits]
  =|  st=[brd=(unit board) lim=limits]
  |-
  ?~  acts  st
  =/  r  (act:fb who.i.acts host now action.i.acts brd.st lim.st)
  ?>  ?=(%& -.r)
  $(acts t.acts, st p.r)
::  one more action on a board; its refusal, or ~ when allowed
::
++  deny
  |=  [brd=(unit board) lim=limits who=@p =action]
  ^-  (unit [@ud @t])
  =/  r  (act:fb who host now action brd lim)
  ?:(?=(%& -.r) ~ `p.r)
::
++  trip
  |=  brd=board
  (load:fb (turn ~(tap by (grubs:fb brd)) |=([p=path v=*] [p v])))
::
::  a board with a reply, an upvoted post, a downvoted post and a
::  downvoted comment comes back from its grubs exactly, and a comment
::  deleted since keeps its id spent
::
++  test-round-trip
  =/  [b=(unit board) *]
    %-  play
    :~  [host %create-board %b 'B' 'd' %poster]
        [host %set-role %b ~nec %mod]
        [host %set-sidebar %b 'side']
        [host %set-prune %b `[2 ~d7]]
        [~nec %new-post %b 'one' ~ `'body']
        [host %new-post %b 'two' `'https://x.example' ~]
        [~nec %new-comment %b 0 ~ 'c0']
        [host %new-comment %b 0 `0 'c1']
        [host %new-comment %b 0 ~ 'c2']
        [host %delete-comment %b 0 2]
        [~nec %upvote %b [%post 1]]
        [host %downvote %b [%comment 0 1]]
        [host %downvote %b [%post 0]]
        [host %pin-post %b 1 &]
    ==
  =/  brd=board  (need b)
  ;:  weld
    (expect-eq !>(&+brd) !>((trip brd)))
    (expect-eq !>(3) !>((~(got by next-comment-ids.brd) 0)))
    (expect-eq !>(2) !>(comment-count:(~(got by posts.brd) 0)))
  ==
::
::  posts, threads and votes sit in buckets of 100 by post id: post 99 in
::  b0, post 100 in b1, and the votes on post 100's comments beside it. A
::  post with no comment yet has no thread, and nothing unvoted is kept
::
++  test-buckets
  =|  b=board
  =/  pc  |=(id=@ud [id host 't' ~ ~ now ~ ~ 0])
  =.  b
    %=  b
      posts             (my ~[[99 (pc 99)] [100 (pc 100)]])
      comments          (my ~[[100 (my ~[[0 [0 ~ host 'c' now (sy ~[~nec]) ~]]])]])
      next-comment-ids  (my ~[[100 1] [99 0]])
    ==
  =/  keys  ~(tap in ~(key by (grubs:fb b)))
  %+  expect-eq
    !>  %-  sy
        ^-  (list path)
        :~  /pub/card  /pub/roles  /pub/conf  /content/pins  /content/sidebar
            /content/posts/b0  /content/posts/b1
            /content/threads/b1  /content/votes/b1
        ==
  !>((sy keys))
::
::  a grub no shape fits stops the load, by name, rather than being read
::  as empty, which the writer would then write back; one it doesn't know
::  is ignored, and a board has a card
::
++  test-load-refuses
  =|  b=board
  =/  gs  ~(tap by (grubs:fb b))
  ;:  weld
    %+  expect-eq  !>(|+'unreadable: /content/posts/b0')
      !>((load:fb [[/content/posts/b0 [%2 ~]] gs]))
    (expect-eq !>(&+b) !>((load:fb [[/stray 42] gs])))
    (expect-eq !>(|+'no card') !>((load:fb ~)))
  ==
::
::  who may do what: the host alone makes, opens and deletes a board; a
::  mod pins and sets roles; a reader can't post; only an author edits
::
++  test-who-may
  =/  [b=(unit board) l=limits]
    %-  play
    :~  [host %create-board %b 'B' '' %poster]
        [host %set-role %b ~bus %reader]
        [~nec %new-post %b 'nec' ~ ~]
    ==
  ;:  weld
    (expect-eq !>(`[403 'only the host may create a board']) !>((deny ~ ~ ~nec %create-board %c 'C' '' %poster)))
    (expect-eq !>(`[400 'board names may only use a-z, 0-9 and -']) !>((deny ~ ~ host %create-board %'A' 'A' '' %poster)))
    (expect-eq !>(`[409 'you already host a board with that name']) !>((deny b l host %create-board %b 'B' '' %poster)))
    (expect-eq !>(`[403 'only the host may delete a board']) !>((deny b l ~nec %delete-board %b)))
    (expect-eq !>(`[403 'only a moderator may pin']) !>((deny b l ~nec %pin-post %b 0 &)))
    (expect-eq !>(`[403 'only a moderator may set roles']) !>((deny b l ~nec %set-role %b ~nec %mod)))
    (expect-eq !>(`[403 'your role on this board cannot post']) !>((deny b l ~bus %new-post %b 't' ~ ~)))
    (expect-eq !>(`[403 'only the author can edit this post']) !>((deny b l host %edit-post %b 0 'x' ~)))
    (expect-eq !>(`[403 'only its author or a moderator may delete a post']) !>((deny b l ~bus %delete-post %b 0)))
    (expect-eq !>(~) !>((deny b l host %delete-post %b 0)))
    (expect-eq !>(`[404 'board not found']) !>((deny ~ ~ host %new-post %b 't' ~ ~)))
  ==
::
::  a second post within the cooldown is refused; a mod's is not, and
::  records no cooldown; a comment on a missing post or a reply to a
::  missing comment is refused
::
++  test-limits-and-targets
  =/  [b=(unit board) l=limits]
    %-  play
    :~  [host %create-board %b 'B' '' %poster]
        [~nec %new-post %b 'nec' ~ ~]
    ==
  =/  mod  (act:fb host host now [%new-post %b 'host' ~ ~] b l)
  =/  commented  (act:fb ~bus host now [%new-comment %b 0 ~ 'c'] b l)
  ;:  weld
    ::  a poster's comment starts a cooldown too
    %+  expect-eq  !>(`[429 'you\'re commenting too fast — please wait a bit and try again'])
      !>(?.(?=(%& -.commented) ~ (deny brd.p.commented lim.p.commented ~bus %new-comment %b 0 ~ 'again')))
    %+  expect-eq  !>(`[429 'you\'re posting too fast — please wait a bit and try again'])
      !>((deny b l ~nec %new-post %b 'again' ~ ~))
    (expect-eq !>(~) !>((deny b l host %new-post %b 'host' ~ ~)))
    (expect-eq !>(`l) !>(?.(?=(%& -.mod) ~ `lim.p.mod)))
    (expect-eq !>(`[404 'post not found']) !>((deny b l host %new-comment %b 9 ~ 'c')))
    (expect-eq !>(`[404 'no such comment to reply to']) !>((deny b l host %new-comment %b 0 `3 'c')))
    (expect-eq !>(`[400 'a comment holds 1 to 10,000 bytes']) !>((deny b l host %new-comment %b 0 ~ '')))
  ==
::
::  the host's own settings: only the host edits a board or opens it, a
::  board keeps a title, a paid board stays closed, the sidebar holds
::  10,000 bytes and no more, and a pin comes off again
::
++  test-host-settings
  =/  [b=(unit board) l=limits]
    %-  play
    :~  [host %create-board %b 'B' '' %poster]
        [~nec %new-post %b 'nec' ~ ~]
        [host %pin-post %b 0 &]
        [host %pin-post %b 0 |]
    ==
  =/  paid=(unit board)
    =/  pb=board  (need b)
    `pb(payment `[100 ~d30 ~])
  =/  txt  |=(n=@ud (crip (reap n 'a')))
  ;:  weld
    (expect-eq !>(~) !>(pinned:(need b)))
    (expect-eq !>(`[403 'only the host may edit a board']) !>((deny b l ~nec %edit-board-info %b 'T' '')))
    (expect-eq !>(`[400 'a board needs a title']) !>((deny b l host %edit-board-info %b '' '')))
    (expect-eq !>(`[403 'only the host may open a board']) !>((deny b l ~nec %set-public %b &)))
    (expect-eq !>(`[400 'a paid board cannot be public']) !>((deny paid l host %set-public %b &)))
    (expect-eq !>(~) !>((deny paid l host %set-public %b |)))
    (expect-eq !>(~) !>((deny b l host %set-sidebar %b (txt 10.000))))
    (expect-eq !>(`[400 'the sidebar holds at most 10,000 bytes']) !>((deny b l host %set-sidebar %b (txt 10.001))))
    (expect-eq !>(`[403 'only a moderator may set roles']) !>((deny b l ~nec %remove-role %b ~nec)))
    %+  expect-eq  !>(`[400 'a post needs a title (300 bytes at most) and a body of 40,000'])
      !>((deny b l ~nec %edit-post %b 0 '' ~))
  ==
::
::  paying: only the host sets a price, gives access or takes it; a price
::  closes a public board, and a board with no price opens to anyone
::  again only when made public
::
++  test-payment
  =/  [b=(unit board) l=limits]
    %-  play
    :~  [host %create-board %b 'B' '' %poster]
        [host %set-public %b &]
    ==
  =/  pay=payment-config  [100 ~d30 ~]
  =/  priced  (act:fb host host now [%set-payment %b `pay] b l)
  =/  given   (act:fb host host now [%grant-paid %b ~nec ~2026.2.1] b l)
  =/  gone
    ?.  ?=(%& -.given)  given
    (act:fb host host now [%revoke-paid %b ~nec] brd.p.given l)
  =/  get  |=(r=(each [brd=(unit board) lim=limits] [@ud @t]) ?>(?=(%& -.r) (need brd.p.r)))
  ;:  weld
    (expect-eq !>(`[403 'only the host may set a price']) !>((deny b l ~nec %set-payment %b `pay)))
    (expect-eq !>(`[403 'only the host may give access']) !>((deny b l ~nec %grant-paid %b ~nec ~2026.2.1)))
    (expect-eq !>(`[403 'only the host may take access away']) !>((deny b l ~nec %revoke-paid %b ~nec)))
    (expect-eq !>([`pay |]) !>([payment public.info]:(get priced)))
    (expect-eq !>((my ~[[~nec ~2026.2.1]])) !>(paid:(get given)))
    (expect-eq !>(~) !>(paid:(get gone)))
  ==
::
::  who hears of what: the host of another's post; a post's author of a
::  comment; a comment's author of a reply. Never the actor, and nobody
::  twice when the parent's author wrote the post too
::
++  test-notes
  =/  [b=(unit board) *]
    %-  play
    :~  [host %create-board %b 'B' '' %poster]
        [host %set-role %b ~nec %mod]
        [~nec %new-post %b 'nec post' ~ ~]
        [~bus %new-comment %b 0 ~ 'bus comment']
        [~nec %new-comment %b 0 ~ 'nec comment']
    ==
  =/  brd=board  (need b)
  =/  url  `'/apps/furum/b/~zod/b/0'
  =/  to  |=(n=(list note-out) (turn n |=(o=note-out to.o)))
  ;:  weld
    %+  expect-eq
      !>(~[[host 'New post on your board' '~nec posted \'nec post\' to b' url (sy ~[%new-posts])]])
      !>((notes-for:fb ~nec [%new-post %b 'nec post' ~ ~] brd))
    (expect-eq !>(~) !>((notes-for:fb host [%new-post %b 'mine' ~ ~] brd)))
    ::  a comment on ~nec's post, replying to ~bus: both hear
    (expect-eq !>(~[~nec ~bus]) !>((to (notes-for:fb host [%new-comment %b 0 `0 'x'] brd))))
    ::  ~nec replying to ~bus on its own post: only ~bus
    (expect-eq !>(~[~bus]) !>((to (notes-for:fb ~nec [%new-comment %b 0 `0 'x'] brd))))
    ::  ~bus answering itself on ~nec's post: only ~nec
    (expect-eq !>(~[~nec]) !>((to (notes-for:fb ~bus [%new-comment %b 0 `0 'x'] brd))))
    ::  the host answering ~nec's own comment on ~nec's post: ~nec once
    (expect-eq !>(~[~nec]) !>((to (notes-for:fb host [%new-comment %b 0 `1 'x'] brd))))
    (expect-eq !>(~) !>((to (notes-for:fb host [%upvote %b [%post 0]] brd))))
  ==
::
::  a vote replaces the voter's last one on that target; remove clears it
::
++  test-votes
  =/  [b=(unit board) *]
    %-  play
    :~  [host %create-board %b 'B' '' %poster]
        [host %new-post %b 't' ~ ~]
        [~nec %upvote %b [%post 0]]
        [~bus %upvote %b [%post 0]]
        [~nec %downvote %b [%post 0]]
        [~bus %remove-vote %b [%post 0]]
    ==
  =/  p  (~(got by posts:(need b)) 0)
  (expect-eq !>([~ (sy ~[~nec])]) !>([up-votes.p down-votes.p]))
--
