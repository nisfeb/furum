::  lib/furum.hoon: rendering and parsing helpers for %furum
::
/-  *furum
|%
::
::  icon image as base64 JPEG
::
++  furum-icon-b64
  ^-  cord
  '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'
::
::  CSS as a cord (no interpolation issues with braces)
::
++  furum-css
  ^-  @t
  '''
  * { box-sizing: border-box; }
  html, body { max-width: 100%; overflow-x: hidden; }
  body { font-family: Verdana, Geneva, sans-serif; font-size: 16px;
         color: #1a1a2e; background: #f0eee8; margin: 0; padding: 0;
         line-height: 1.55; }
  #hd { background: #cc2020; padding: 8px 16px; line-height: 32px; }
  #hd a { color: #fff; text-decoration: none; font-weight: bold;
           font-size: 18px; }
  #hd .nav { font-weight: normal; font-size: 16px; }
  #hd .nav a { color: #ffdede; font-weight: normal; font-size: 16px; }
  .ct { padding: 16px; max-width: 960px; overflow-wrap: break-word;
         word-wrap: break-word; }
  a { color: #8b1a1a; }
  .ti a { text-decoration: none; font-size: 18px; color: #1a1a2e; }
  .ti a:visited { color: #6a6a7a; }
  .host { font-size: 14px; color: #5a7a8a; overflow-wrap: break-word;
           word-break: break-all; }
  .me { color: #5a7a8a; font-size: 14px; padding-left: 5px; }
  .me a { color: #5a7a8a; }
  .cm { border-left: 2px solid #d0ccc4; padding-left: 12px;
         margin: 10px 0 10px 12px; }
  .cm-meta { color: #5a7a8a; font-size: 14px; margin-bottom: 5px; }
  .cm-meta a { color: #5a7a8a; }
  .va { color: #8a8a9a; cursor: pointer; border: none;
         background: none; padding: 0; font-size: 18px; }
  .va:hover { color: #cc2020; }
  .rw { padding: 5px 0; display: flex; align-items: baseline; }
  .rk { width: 36px; text-align: right; margin-right: 8px;
         color: #5a7a8a; font-size: 15px; }
  .score { display: inline; }
  textarea { width: 100%; max-width: 540px; height: 160px; font-family: monospace;
              font-size: 16px; }
  input[type=text], input[type=url] { width: 100%; max-width: 440px;
                                        font-size: 16px; padding: 5px; }
  .btn { margin-top: 10px; padding: 8px 24px; cursor: pointer;
          background: #cc2020; color: #fff; border: none; font-size: 16px; }
  .btn:hover { background: #a01818; }
  .post-body { padding: 12px 0; max-width: 100%; white-space: pre-wrap;
                font-size: 16px; line-height: 1.6; overflow-wrap: break-word;
                word-wrap: break-word; }
  table.mod { border-collapse: collapse; font-size: 16px; }
  table.mod td, table.mod th { padding: 8px 16px; text-align: left;
                                 border-bottom: 1px solid #d0ccc4; }
  .err { color: #cc2020; padding: 20px; font-size: 16px; }
  .sort { font-size: 14px; color: #5a7a8a; margin-bottom: 10px; }
  .sort a { color: #8b1a1a; text-decoration: none; }
  .sort a:hover { text-decoration: underline; }
  .sort strong { color: #1a1a2e; }
  .tag { font-size: 14px; color: #cc2020; margin-left: 2px; }
  .dark-toggle { float: right; font-size: 15px; }
  .dark-toggle button { background: none; border: none; cursor: pointer;
                         font-size: 15px; padding: 0; color: #ffdede; }
  body.dark { background: #0a0a14; color: #b8b8c8; }
  body.dark #hd { background: #1a0808; border-bottom: 1px solid #cc2020; }
  body.dark #hd a { color: #cc2020; }
  body.dark #hd .nav a { color: #8a6a6a; }
  body.dark #hd .dark-toggle button { color: #8a6a6a; }
  body.dark a { color: #5a8a9a; }
  body.dark .ti a { color: #d0d0dd; }
  body.dark .ti a:visited { color: #555568; }
  body.dark .host, body.dark .me, body.dark .cm-meta { color: #4a6a7a; }
  body.dark .me a, body.dark .cm-meta a { color: #4a6a7a; }
  body.dark .cm { border-left-color: #1e2838; }
  body.dark .va { color: #4a4a5a; }
  body.dark .va:hover { color: #cc2020; }
  body.dark .rk { color: #4a4a5a; }
  body.dark textarea, body.dark input[type=text], body.dark input[type=url],
  body.dark select { background: #141428; color: #b8b8c8; border: 1px solid #2a2a40; }
  body.dark .btn { background: #cc2020; color: #fff; border: none; }
  body.dark .btn:hover { background: #a01818; }
  body.dark table.mod td, body.dark table.mod th { border-bottom-color: #1e2838; }
  body.dark .err { color: #cc2020; }
  body.dark .sort { color: #4a6a7a; }
  body.dark .sort a { color: #5a8a9a; }
  body.dark .sort strong { color: #b8b8c8; }
  body.dark hr { border-color: #1e2838; }
  '''
::
::  URL parsing: split URL into path segments and query params
::
++  parse-request-url
  |=  url=@t
  ^-  [pax=(list @t) args=(map @t @t)]
  =/  ut=tape  (trip url)
  ::  split on ?
  =/  qidx  (find "?" ut)
  =/  path-tape=tape  ?~(qidx ut (scag u.qidx ut))
  =/  query-tape=tape  ?~(qidx ~ (slag +(u.qidx) ut))
  ::  split path on / and drop empties
  =/  segs=(list tape)  (split-on path-tape '/')
  =/  pax=(list @t)
    (skip (turn segs crip) |=(a=@t =(a '')))
  ::  parse query string
  =/  args=(map @t @t)  (parse-query query-tape)
  [pax args]
::
::  split a tape on a character
::
++  split-on
  |=  [t=tape c=@tD]
  ^-  (list tape)
  ?:  =(~ t)  ["" ~]
  =/  idx  (find [c ~] t)
  ?~  idx  [t ~]
  [(scag u.idx t) $(t (slag +(u.idx) t))]
::
::  parse query string "key=val&key2=val2" into map
::
++  parse-query
  |=  qs=tape
  ^-  (map @t @t)
  ?~  qs  *(map @t @t)
  =/  pairs=(list tape)  (split-on qs '&')
  %+  roll  pairs
  |=  [pair=tape acc=(map @t @t)]
  =/  kv=(list tape)  (split-on pair '=')
  ?~  kv  acc
  ?~  t.kv  (~(put by acc) (crip (urld i.kv)) '')
  (~(put by acc) (crip (urld i.kv)) (crip (urld i.t.kv)))
::
::  parse form-urlencoded POST body
::
++  parse-form
  |=  bod=(unit octs)
  ^-  (map @t @t)
  ?~  bod  *(map @t @t)
  (parse-query (trip (cut 3 [0 p.u.bod] q.u.bod)))
::
::  URL decode a tape
::
++  urld
  |=  t=tape
  ^-  tape
  ?~  t  ~
  ?:  =('+' i.t)
    [' ' $(t t.t)]
  ?.  =('%' i.t)
    [i.t $(t t.t)]
  ?~  t.t  ~
  ?~  t.t.t  ~
  =/  hi  (hex-char i.t.t)
  =/  lo  (hex-char i.t.t.t)
  ?~  hi  [i.t $(t t.t)]
  ?~  lo  [i.t $(t t.t)]
  [`@tD`(add (mul u.hi 16) u.lo) $(t t.t.t.t)]
::
++  hex-char
  |=  c=@tD
  ^-  (unit @)
  ?:  &((gte c '0') (lte c '9'))  `(sub c '0')
  ?:  &((gte c 'a') (lte c 'f'))  `(add 10 (sub c 'a'))
  ?:  &((gte c 'A') (lte c 'F'))  `(add 10 (sub c 'A'))
  ~
::
::  time ago display
::
++  time-ago
  |=  [now=@da then=@da]
  ^-  tape
  ?:  (lte now then)  "just now"
  =/  diff=@dr  (sub now then)
  =/  parts=tarp  (yell diff)
  ?:  (gth d.parts 0)
    "{(a-co:co d.parts)}d ago"
  ?:  (gth h.parts 0)
    "{(a-co:co h.parts)}h ago"
  ?:  (gth m.parts 0)
    "{(a-co:co m.parts)}m ago"
  "{(a-co:co s.parts)}s ago"
::
::  net votes for a post
::
++  net-votes
  |=  =post
  ^-  @sd
  =/  up=@ud  ~(wyt in up-votes.post)
  =/  dn=@ud  ~(wyt in down-votes.post)
  ?:  (gte up dn)
    (sun:si (sub up dn))
  (new:si %.n (sub dn up))
::
::  sort posts by creation time (newest first)
::
++  sort-posts-by-new
  |=  posts=(list post)
  ^-  (list post)
  %+  sort  posts
  |=  [a=post b=post]
  (gth created.a created.b)
::
::  sort posts by net votes descending, tiebreak newest
::
++  sort-posts-by-top
  |=  posts=(list post)
  ^-  (list post)
  %+  sort  posts
  |=  [a=post b=post]
  =/  va=@ud
    =/  up  ~(wyt in up-votes.a)
    =/  dn  ~(wyt in down-votes.a)
    ?:((gte up dn) (sub up dn) 0)
  =/  vb=@ud
    =/  up  ~(wyt in up-votes.b)
    =/  dn  ~(wyt in down-votes.b)
    ?:((gte up dn) (sub up dn) 0)
  ?:  =(va vb)
    (gth created.a created.b)
  (gth va vb)
::
::  HN-style score: (votes) / (hours_since + 2)^2
::  uses @rs single-precision float
::
++  score-post
  |=  [now=@da =post]
  ^-  @rs
  =/  up=@ud  ~(wyt in up-votes.post)
  =/  dn=@ud  ~(wyt in down-votes.post)
  =/  net=@ud  ?:((gte up dn) (sub up dn) 0)
  =/  votes=@rs  (sun:rs net)
  ::  hours since creation
  =/  age=@dr  ?:((gth now created.post) (sub now created.post) *@dr)
  =/  parts=tarp  (yell age)
  =/  total-hours=@ud  (add (mul d.parts 24) h.parts)
  =/  hours-plus=@rs  (add:rs (sun:rs total-hours) (sun:rs 2))
  ::  denominator = (hours+2)^2
  =/  denom=@rs  (mul:rs hours-plus hours-plus)
  ::  avoid division by zero
  ?:  =(denom .0)
    votes
  (div:rs votes denom)
::
::  sort posts by HN-style hot score descending
::
++  sort-posts-by-hot
  |=  [now=@da posts=(list post)]
  ^-  (list post)
  %+  sort  posts
  |=  [a=post b=post]
  =/  sa=@rs  (score-post now a)
  =/  sb=@rs  (score-post now b)
  (gth:rs sa sb)
::
::  dispatch to sort function by mode
::
++  sort-posts-dispatch
  |=  [mode=?(%hot %new %top) now=@da posts=(list post)]
  ^-  (list post)
  ?-  mode
    %hot  (sort-posts-by-hot now posts)
    %new  (sort-posts-by-new posts)
    %top  (sort-posts-by-top posts)
  ==
::
::  parse sort param from query string
::
++  parse-sort
  |=  args=(map @t @t)
  ^-  ?(%hot %new %top)
  =/  raw=@t  (~(gut by args) 'sort' 'hot')
  ?+  raw  %hot
    %'hot'  %hot
    %'new'  %new
    %'top'  %top
  ==
::
::  flatten comments into depth-ordered list for rendering
::  returns (list [depth=@ud =comment])
::
++  flatten-comments
  |=  comments=(map comment-id comment)
  ^-  (list [@ud comment])
  =/  clist=(list comment)  ~(val by comments)
  ::  group by parent
  =/  by-parent=(map (unit comment-id) (list comment))
    %+  roll  clist
    |=  [c=comment acc=(map (unit comment-id) (list comment))]
    =/  existing  (~(gut by acc) parent.c ~)
    (~(put by acc) parent.c [c existing])
  ::  walk tree depth-first
  (walk-children 0 ~ by-parent)
::
++  walk-children
  |=  [depth=@ud parent=(unit comment-id) by-parent=(map (unit comment-id) (list comment))]
  ^-  (list [@ud comment])
  =/  kids=(list comment)  (~(gut by by-parent) parent ~)
  =/  sorted=(list comment)
    %+  sort  kids
    |=  [a=comment b=comment]
    (lth created.a created.b)
  %-  zing
  %+  turn  sorted
  |=  c=comment
  [[depth c] (walk-children +(depth) `id.c by-parent)]
::
::  convert manx to octs for HTTP response
::
++  manx-to-octs
  |=  =manx
  ^-  octs
  =/  html=@t  (crip (en-xml:html manx))
  [(met 3 html) html]
::
::  page shell: wrap content in full HTML page
::
++  page-shell
  |=  [title=@t content=marl board-ctx=(unit [href=tape label=tape]) public=? dark=?]
  ^-  manx
  =/  style-node=manx
    [[%style ~] [[[%$ [%$ (trip furum-css)]~] ~] ~]]
  =/  sw-script=tape  (trip 'if("serviceWorker" in navigator)navigator.serviceWorker.register("/apps/furum/sw",{scope:"/apps/furum"})')
  =/  sw-node=manx
    [[%script ~] [[[%$ [%$ sw-script] ~] ~] ~]]
  =/  body-attrs=mart
    ?:(dark ~[['class' "dark"]] ~)
  =/  toggle-label=tape
    ?:(dark "light" "dark")
  =/  nav-link=manx
    ?~  board-ctx
      ;a/"/apps/furum/create": new board
    ;a(href href.u.board-ctx): {label.u.board-ctx}
  =/  right-section=manx
    ?:  public
      ;span.dark-toggle
        ;a(href "/apps/furum/about", style "color: #ffdede; text-decoration: none; margin-right: 16px"): I Have Urbit
        ;a(href "https://urbit.org/overview/running-urbit", style "color: #ffdede; text-decoration: none"): Get on Urbit
      ==
    ;span.dark-toggle
      ;form(method "post", action "/apps/furum/dark-mode", style "display:inline")
        ;button(type "submit"): {toggle-label}
      ==
    ==
  =/  body-node=manx
    :_  :~
      ;div#hd
        ;+  right-section
        ;+  ?:  public
              ;span(style "color: #fff; font-weight: bold; font-size: 18px"): furum
            ;a/"/apps/furum": furum
        ;+  ?.  public
              ;span.nav
                ;+  ;/("  |  ")
                ;+  nav-link
              ==
            ;span;
      ==
      ;div.ct
        ;*  content
      ==
    ==
    [%body body-attrs]
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;meta(name "apple-mobile-web-app-capable", content "yes");
      ;meta(name "apple-mobile-web-app-status-bar-style", content "black-translucent");
      ;meta(name "theme-color", content "#cc2020");
      ;link(rel "manifest", href "/apps/furum/manifest");
      ;link(rel "apple-touch-icon", href "/apps/furum/icon");
      ;title: {(trip title)}
      ;+  style-node
      ;+  sw-node
    ==
    ;+  body-node
  ==
::
::  HOME PAGE: board directory
::
++  render-home
  |=  [entries=(list directory-entry) view=?(%all %curated %tag) active-tag=(unit @tas) all-tags=(set @tas) is-registry=? dark=?]
  ^-  manx
  =/  tag-list=(list @tas)
    %+  sort  ~(tap in all-tags)
    |=  [a=@tas b=@tas]
    (aor a b)
  =/  tag-links=marl
    %+  turn  tag-list
    |=  tag=@tas
    ^-  manx
    ;span
      ;+  ;/(" ")
      ;a(href "/apps/furum/tag/{(trip tag)}"): #{(trip tag)}
    ==
  =/  view-label=tape
    ?-  view
      %all      "All Boards"
      %curated  "Curated Boards"
      %tag      ?~(active-tag "Tagged" "#{(trip u.active-tag)}")
    ==
  =/  nav=manx
    ;div
      ;h3: Board Directory
      ;p
        ;a(href "/apps/furum"): all
        ;+  ;/(" | ")
        ;a(href "/apps/furum/curated"): curated
        ;*  tag-links
        ;+  ?:  is-registry
              ;span
                ;+  ;/(" | ")
                ;a(href "/apps/furum/registry"): admin
              ==
            ;span;
      ==
      ;p.me: Showing: {view-label}
    ==
  =/  board-rows=marl
    ?~  entries
      :~  ;p.me: No boards in this view.
      ==
    %+  turn  entries
    |=  entry=directory-entry
    ^-  manx
    =/  href=tape
      "/apps/furum/b/{(scow %p host.entry)}/{(trip name.entry)}"
    =/  tag-text=tape
      %+  roll  ~(tap in tags.entry)
      |=  [tag=@tas acc=tape]
      ?:(=(acc "") "#{(trip tag)}" "{acc} #{(trip tag)}")
    =/  tag-node=manx
      ?.  =(tag-text "")
        ;span.me: {" "}{tag-text}
      ;span;
    =/  curated-node=manx
      ?:  curated.entry
        ;span.me: {" "}[curated]
      ;span;
    ;div.rw
      ;div
        ;span.ti
          ;a(href href): {(trip title.entry)}
        ==
        ;span.host: {" "}({(scow %p host.entry)})
        ;+  tag-node
        ;+  curated-node
        ;div.me: {(trip description.entry)}
      ==
    ==
  %-  page-shell
  :*  'furum'  [nav board-rows]  ~  %.n  dark  ==
::
::  BOARD PAGE: list of posts
::
++  render-board
  |=  [host=@p =board-info posts=(list post) our=@p now=@da is-mod=? authed=? dark=? sort=?(%hot %new %top)]
  ^-  manx
  =/  sorted  (sort-posts-dispatch sort now posts)
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  mod-link=manx
    ?.  ?|(=(host our) is-mod)  ;span;
    ;span
      ;+  ;/("  |  ")
      ;a(href "{board-path}/mod"): moderate
    ==
  =/  nav-section=manx
    ?.  authed  ;p;
    ;p
      ;a(href "{board-path}/submit"): submit post
      ;+  mod-link
    ==
  =/  sort-hot=manx
    ?:  =(sort %hot)
      ;strong: hot
    ;a(href "{board-path}?sort=hot"): hot
  =/  sort-new=manx
    ?:  =(sort %new)
      ;strong: new
    ;a(href "{board-path}?sort=new"): new
  =/  sort-top=manx
    ?:  =(sort %top)
      ;strong: top
    ;a(href "{board-path}?sort=top"): top
  =/  sort-bar=manx
    ;div.sort
      ;span: sort:
      ;+  sort-hot
      ;+  ;/(" | ")
      ;+  sort-new
      ;+  ;/(" | ")
      ;+  sort-top
    ==
  =/  header=manx
    ;div
      ;h3: {(trip title.board-info)}
      ;p.me: {(trip description.board-info)}
      ;+  nav-section
      ;+  sort-bar
    ==
  =/  post-rows=marl
    ?~  sorted
      :~  ;p.me: No posts yet.
      ==
    =/  ranked  (rank-list sorted)
    %+  turn  ranked
    |=  [rank=@ud =post]
    ^-  manx
    =/  points=@ud
      =/  up  ~(wyt in up-votes.post)
      =/  dn  ~(wyt in down-votes.post)
      ?:((gte up dn) (sub up dn) 0)
    =/  post-href=tape  "{board-path}/{(a-co:co id.post)}"
    =/  title-href=tape
      ?^  url.post  (trip u.url.post)
      post-href
    =/  vote-btn=manx
      ?.  authed  ;span;
      ;form(method "post", action "{board-path}/vote", style "display:inline")
        ;input(type "hidden", name "target", value "post-{(a-co:co id.post)}");
        ;input(type "hidden", name "dir", value "up");
        ;button.va(type "submit"): ▲
      ==
    =/  url-host=manx
      ?~  url.post  ;span;
      ;span.host: ({(trip u.url.post)})
    =/  del-btn=manx
      ?.  ?&(authed ?|(=(our author.post) is-mod))  ;span;
      ;form(method "post", action "{post-href}/delete", style "display:inline")
        ;+  ;/(" | ")
        ;button.va(type "submit"): delete
      ==
    ;div.rw
      ;span.rk: {(a-co:co rank)}.
      ;+  vote-btn
      ;div
        ;span.ti
          ;a(href title-href): {(trip title.post)}
        ==
        ;+  url-host
        ;div.me
          ;+  ;/("{(a-co:co points)} points by {(scow %p author.post)} {(time-ago now created.post)} | ")
          ;a(href post-href): {(a-co:co comment-count.post)} comments
          ;+  del-btn
        ==
      ==
    ==
  %-  page-shell
  [(crip "furum - {(trip title.board-info)}") [header post-rows] `[board-path (trip title.board-info)] !authed dark]
::
::  POST DETAIL PAGE: post with comments
::
++  render-post-page
  |=  [host=@p =board-info =post comments=(map comment-id comment) our=@p now=@da is-mod=? authed=? dark=?]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  post-path=tape
    "{board-path}/{(a-co:co id.post)}"
  =/  points=@ud
    =/  up  ~(wyt in up-votes.post)
    =/  dn  ~(wyt in down-votes.post)
    ?:((gte up dn) (sub up dn) 0)
  =/  flat-comments  (flatten-comments comments)
  =/  comment-form=manx
    ?.  authed
      ;span;
    ;form(method "post", action "{post-path}/comment")
      ;textarea(name "body", placeholder "add a comment...");
      ;br;
      ;input.btn(type "submit", value "add comment");
    ==
  =/  vote-btn=manx
    ?.  authed  ;span;
    ;form(method "post", action "{board-path}/vote", style "display:inline")
      ;input(type "hidden", name "target", value "post-{(a-co:co id.post)}");
      ;input(type "hidden", name "dir", value "up");
      ;button.va(type "submit"): ▲
    ==
  =/  url-link=manx
    ?~  url.post  ;span;
    ;a(href (trip u.url.post)): {(trip u.url.post)}
  =/  edit-link=manx
    ?.  ?&(authed =(our author.post))  ;span;
    ;span
      ;+  ;/(" | ")
      ;a.me(href "{post-path}/edit"): edit
    ==
  =/  del-btn=manx
    ?.  ?&(authed ?|(=(our author.post) is-mod))  ;span;
    ;form(method "post", action "{post-path}/delete", style "display:inline")
      ;+  ;/(" | ")
      ;button.va(type "submit"): delete post
    ==
  =/  body-section=manx
    ?~  body.post  ;span;
    ;div.post-body: {(trip u.body.post)}
  =/  comment-list=marl
    (render-flat-comments flat-comments board-path id.post our is-mod authed now)
  =/  comment-div=manx
    ;div
      ;*  comment-list
    ==
  =/  post-detail=manx
    ;div
      ;+  vote-btn
      ;span.ti: {" "}{(trip title.post)}
      ;+  url-link
      ;div.me
        ;+  ;/("{(a-co:co points)} points by {(scow %p author.post)} {(time-ago now created.post)}")
        ;+  edit-link
        ;+  del-btn
      ==
      ;+  body-section
    ==
  =/  post-content=marl
    :~  post-detail
        ;hr;
        comment-form
        ;hr;
        comment-div
    ==
  %-  page-shell
  [(crip "furum - {(trip title.post)}") post-content `[board-path (trip title.board-info)] !authed dark]
::
::  render a flat list of depth-tagged comments
::
++  render-flat-comments
  |=  [cmts=(list [@ud comment]) board-path=tape post-id=post-id our=@p is-mod=? authed=? now=@da]
  ^-  marl
  %+  turn  cmts
  |=  [depth=@ud c=comment]
  ^-  manx
  =/  points=@ud
    =/  up  ~(wyt in up-votes.c)
    =/  dn  ~(wyt in down-votes.c)
    ?:((gte up dn) (sub up dn) 0)
  =/  indent=tape  (a-co:co (mul depth 20))
  =/  vote-btn=manx
    ?.  authed  ;span;
    ;form(method "post", action "{board-path}/vote", style "display:inline")
      ;input(type "hidden", name "target", value "comment-{(a-co:co post-id)}-{(a-co:co id.c)}");
      ;input(type "hidden", name "dir", value "up");
      ;button.va(type "submit"): ▲
    ==
  =/  del-btn=manx
    ?.  ?&(authed ?|(=(our author.c) is-mod))  ;span;
    ;form(method "post", action "{board-path}/{(a-co:co post-id)}/delete-comment", style "display:inline")
      ;input(type "hidden", name "comment-id", value "{(a-co:co id.c)}");
      ;+  ;/(" ")
      ;button.va(type "submit"): delete
    ==
  =/  reply-section=manx
    ?.  authed  ;span;
    ;details
      ;summary.me: reply
      ;form(method "post", action "{board-path}/{(a-co:co post-id)}/comment")
        ;input(type "hidden", name "parent", value "{(a-co:co id.c)}");
        ;textarea(name "body", rows "3", cols "60");
        ;br;
        ;input.btn(type "submit", value "reply");
      ==
    ==
  ;div(style "margin-left: {indent}px")
    ;div.cm
      ;div.cm-meta
        ;+  vote-btn
        ;+  ;/(" {(scow %p author.c)} {(a-co:co points)} points {(time-ago now created.c)}")
        ;+  del-btn
      ==
      ;div: {(trip body.c)}
      ;+  reply-section
    ==
  ==
::
::  SUBMIT POST FORM
::
++  render-submit
  |=  [host=@p name=board-name dark=?]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name)}"
  %-  page-shell
  :*  'furum - submit'
    ^-  marl
    :~
      ;h3: Submit to {(trip name)}
      ;form(method "post", action "{board-path}/submit")
        ;div
          ;label: title
          ;br;
          ;input(type "text", name "title", required "");
        ==
        ;br;
        ;div
          ;label: url (optional, for link posts)
          ;br;
          ;input(type "url", name "url");
        ==
        ;br;
        ;div
          ;label: text (optional, for text posts)
          ;br;
          ;textarea(name "body");
        ==
        ;br;
        ;input.btn(type "submit", value "submit");
      ==
    ==
    `[board-path (trip name)]
    %.n
    dark
  ==
::
::  EDIT POST FORM
::
++  render-edit-post
  |=  [host=@p name=board-name =post dark=?]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name)}"
  =/  post-path=tape
    "{board-path}/{(a-co:co id.post)}"
  =/  url-display=manx
    ?~  url.post  ;span;
    ;div
      ;label: link
      ;br;
      ;span.me: {(trip u.url.post)}
    ==
  =/  edit-form=manx
    ;form(method "post", action "{post-path}/edit")
      ;div
        ;label: title
        ;br;
        ;input(type "text", name "title", required "", value "{(trip title.post)}");
      ==
      ;br;
      ;div
        ;label: text (optional)
        ;br;
        ;textarea(name "body"): {?~(body.post "" (trip u.body.post))}
      ==
      ;br;
      ;input.btn(type "submit", value "save");
    ==
  =/  content=marl
    :~  ;h3: Edit post
        url-display
        ;br;
        edit-form
    ==
  %-  page-shell
  [%'furum - edit post' content `[board-path (trip name)] %.n dark]
::
::  CREATE BOARD FORM
::
++  render-create
  |=  dark=?
  ^-  manx
  %-  page-shell
  :*  'furum - create board'
    ^-  marl
    :~
      ;h3: Create a New Board
      ;form(method "post", action "/apps/furum/create")
        ;div
          ;label: name (url-safe, lowercase, no spaces)
          ;br;
          ;input(type "text", name "name", required "", pattern "[a-z0-9-]+");
        ==
        ;br;
        ;div
          ;label: title
          ;br;
          ;input(type "text", name "title", required "");
        ==
        ;br;
        ;div
          ;label: description
          ;br;
          ;textarea(name "description");
        ==
        ;br;
        ;div
          ;label: default role for new users
          ;br;
          ;select(name "default-role")
            ;option(value "poster", selected ""): poster (can post and comment)
            ;option(value "reader"): reader (can only vote)
          ==
        ==
        ;br;
        ;input.btn(type "submit", value "create board");
      ==
    ==
    ~
    %.n
    dark
  ==
::
::  MODERATION PANEL
::
++  render-mod
  |=  [host=@p =board-info roles=(map @p role) is-host=? dark=?]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  role-section=manx
    ?.  (gth ~(wyt by roles) 0)
      ;p.me: No explicit roles set. Everyone gets the default role.
    ;table.mod
      ;thead
        ;tr
          ;th: Ship
          ;th: Role
          ;th: Action
        ==
      ==
      ;tbody
        ;*
        %+  turn  ~(tap by roles)
        |=  [who=@p =role]
        ;tr
          ;td: {(scow %p who)}
          ;td: {(trip (role-to-text role))}
          ;td
            ;form(method "post", action "{board-path}/mod/remove-role", style "display:inline")
              ;input(type "hidden", name "who", value "{(scow %p who)}");
              ;input.btn(type "submit", value "remove");
            ==
          ==
        ==
      ==
    ==
  =/  pub-status=tape  ?:(public.board-info "This board is currently public." "This board is currently private.")
  =/  pub-label=tape  ?:(public.board-info "make private" "make public")
  =/  pub-section=manx
    ?.  is-host  ;span;
    ;div
      ;h4: Public Access
      ;p.me: Public boards can be read without authentication.
      ;form(method "post", action "{board-path}/mod/public")
        ;p: {pub-status}
        ;input.btn(type "submit", value pub-label);
      ==
      ;hr;
    ==
  =/  role-form=manx
    ;form(method "post", action "{board-path}/mod/role")
      ;div
        ;label: ship (@p)
        ;br;
        ;input(type "text", name "who", required "", placeholder "~sampel-palnet");
      ==
      ;br;
      ;div
        ;label: role
        ;br;
        ;select(name "role")
          ;option(value "reader"): reader
          ;option(value "poster"): poster
          ;option(value "mod"): moderator
        ==
      ==
      ;br;
      ;input.btn(type "submit", value "set role");
    ==
  =/  mod-content=marl
    :~  ;h3: Moderate {(trip title.board-info)}
        ;p.me: Default role: {(trip (role-to-text default-role.board-info))}
        pub-section
        ;h4: Set User Role
        role-form
        ;hr;
        ;h4: Current Roles
        role-section
    ==
  %-  page-shell
  [(crip "furum - mod {(trip name.board-info)}") mod-content `[board-path (trip title.board-info)] %.n dark]
::
::  REGISTRY ADMIN PAGE
::
++  render-registry-admin
  |=  [entries=(list directory-entry) admins=(set @p) is-host=? dark=?]
  ^-  manx
  =/  board-rows=marl
    ?~  entries
      :~  ;p.me: No boards registered.
      ==
    %+  turn  entries
    |=  entry=directory-entry
    ^-  manx
    =/  tag-text=tape
      %+  roll  ~(tap in tags.entry)
      |=  [tag=@tas acc=tape]
      ?:(=(acc "") (trip tag) "{acc}, {(trip tag)}")
    =/  name-text=tape  (trip name.entry)
    ;div.rw
      ;div(style "width: 100%")
        ;span.ti: {(trip title.entry)}
        ;span.host: {" "}({(scow %p host.entry)})
        ;span.me: {" "}curated: {?:(curated.entry "yes" "no")} | tags: {?:(=(tag-text "") "none" tag-text)}
        ;div(style "margin-top: 4px")
          ;form(method "post", action "/apps/furum/registry/curate", style "display:inline")
            ;input(type "hidden", name "name", value name-text);
            ;input(type "hidden", name "curated", value ?:(curated.entry "false" "true"));
            ;input.btn(type "submit", value ?:(curated.entry "uncurate" "curate"));
          ==
          ;form(method "post", action "/apps/furum/registry/tag", style "display:inline; margin-left: 8px")
            ;input(type "hidden", name "name", value name-text);
            ;input(type "text", name "tag", placeholder "add tag", style "width: 100px");
            ;input.btn(type "submit", value "tag");
          ==
          ;+  ?.  (gth ~(wyt in tags.entry) 0)
                ;span;
              ;span(style "margin-left: 8px")
                ;*
                %+  turn  ~(tap in tags.entry)
                |=  tag=@tas
                ^-  manx
                ;form(method "post", action "/apps/furum/registry/untag", style "display:inline; margin-left: 4px")
                  ;input(type "hidden", name "name", value name-text);
                  ;input(type "hidden", name "tag", value (trip tag));
                  ;input.btn(type "submit", value "x {(trip tag)}");
                ==
              ==
        ==
      ==
    ==
  =/  admin-list=(list @p)  ~(tap in admins)
  =/  admin-rows=marl
    %+  turn  admin-list
    |=  who=@p
    ^-  manx
    ;tr
      ;td: {(scow %p who)}
      ;td
        ;+  ?.  is-host
              ;span;
            ;form(method "post", action "/apps/furum/registry/remove-admin", style "display:inline")
              ;input(type "hidden", name "who", value "{(scow %p who)}");
              ;input.btn(type "submit", value "remove");
            ==
      ==
    ==
  =/  admin-table=manx
    ?.  (gth (lent admin-list) 0)
      ;p.me: No delegates added yet.
    ;table.mod
      ;thead
        ;tr
          ;th: Delegate
          ;th: Action
        ==
      ==
      ;tbody
        ;*  admin-rows
      ==
    ==
  =/  add-form=manx
    ?.  is-host
      ;p.me: Only the registry host can add or remove delegates.
    ;form(method "post", action "/apps/furum/registry/add-admin")
      ;div
        ;label: ship (@p)
        ;br;
        ;input(type "text", name "who", required "", placeholder "~sampel-palnet");
      ==
      ;br;
      ;input.btn(type "submit", value "add delegate");
    ==
  =/  admin-section=marl
    :~
      ;h4: Delegate Admins
      ;p.me: These ships can curate and tag boards.
      add-form
      admin-table
      ;hr;
    ==
  =/  header=marl
    :~
      ;h3: Registry Admin
      ;p.me: Manage board curation and tags.
      ;p
        ;a(href "/apps/furum"): back to directory
      ==
      ;hr;
    ==
  %-  page-shell
  :*  'furum - registry admin'  :(welp header admin-section board-rows)  ~  %.n  dark  ==
::
::  ERROR PAGE
::
++  render-error
  |=  [msg=tape dark=?]
  ^-  manx
  %-  page-shell
  :*  'furum - error'
    :~  ;div.err
          ;h3: Error
          ;p: {msg}
          ;p: ;a/"/apps/furum": back to home
        ==
    ==
    ~
    %.n
    dark
  ==
::
::  LOADING PAGE: auto-refreshes to target URL
::
++  render-loading
  |=  [url=tape dark=?]
  ^-  manx
  =/  refresh=tape  "2;url={url}"
  =/  style-node=manx
    [[%style ~] [[[%$ [%$ (trip furum-css)]~] ~] ~]]
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;meta(http-equiv "refresh", content refresh);
      ;title: furum - loading
      ;+  style-node
    ==
    ;body
      ;div.ct
        ;p.me: Loading board data...
      ==
    ==
  ==
::
::  ABOUT PAGE (public)
::
++  render-about
  |=  host=@p
  ^-  manx
  =/  host-p=tape  (scow %p host)
  %-  page-shell
  :*  'furum - about'
    ^-  marl
    :~
      ;div
        ;h3: What is furum?
        ;p
          ;+  ;/("furum is a decentralized forum that runs on ")
          ;a(href "https://urbit.org"): Urbit
          ;+  ;/(", a peer-to-peer computing network. Think Reddit or Hacker News, but every board is hosted on someone's personal server — no corporation in the middle.")
        ==
        ;h4: Why is this different?
        ;ul
          ;li: Self-hosted — every board lives on its owner's Urbit ship. Your content, your server, your rules.
          ;li: Uncensorable — no central authority can take down a board or ban a user from the network.
          ;li: Peer-to-peer — boards sync directly between ships. No cloud infrastructure required.
          ;li: Open source — furum is free software anyone can modify and redistribute.
        ==
        ;hr;
        ;h3: Install furum
        ;p: If you already have an Urbit ship running, you can install furum and start participating.
        ;h4: From your ship's dojo
        ;p: If you can reach this page, the host ship is distributing furum. Run this in your dojo:
        ;pre: |install {host-p} %furum
        ;p: That's it. Once installed, visit /apps/furum on your ship.
        ;h4: Self-hosted ship (Port, native, or CLI)
        ;ol
          ;li
            ;+  ;/("Make sure your ship is running and you can access the dojo (the command line in ")
            ;a(href "https://port.urbit.org"): Port
            ;+  ;/(", or your terminal).")
          ==
          ;li
            ;+  ;/("Run ")
            ;code: |install {host-p} %furum
          ==
          ;li: Visit your ship's URL at /apps/furum
        ==
        ;h4: Tlon hosted ship (tlon.network)
        ;ol
          ;li
            ;+  ;/("Log in to your ship at ")
            ;a(href "https://tlon.network"): tlon.network
          ==
          ;li: Open the Landscape app browser and search for furum, or use the dojo
          ;li
            ;+  ;/("In the dojo, run ")
            ;code: |install {host-p} %furum
          ==
          ;li: furum will appear in your app list
        ==
        ;hr;
        ;h4: Don't have Urbit yet?
        ;p
          ;+  ;/("Urbit is a personal server you own and control. Get started at ")
          ;a(href "https://urbit.org/overview/running-urbit"): urbit.org
          ;+  ;/(".")
        ==
      ==
    ==
    ~
    %.y
    %.n
  ==
::
::  helper: role to text
::
++  role-to-text
  |=  =role
  ^-  @t
  ?-  role
    %mod     'moderator'
    %poster  'poster'
    %reader  'reader'
  ==
::
::  helper: add rank numbers to a list
::
++  rank-list
  |=  posts=(list post)
  ^-  (list [@ud post])
  =/  idx=@ud  1
  |-
  ?~  posts  ~
  [[idx i.posts] $(posts t.posts, idx +(idx))]
::
::  helper: parse vote target from form value
::  format: "post-{id}" or "comment-{post-id}-{comment-id}"
::
++  parse-vote-target
  |=  val=@t
  ^-  (unit vote-target)
  =/  t=tape  (trip val)
  ?:  =("post-" (scag 5 t))
    =/  id  (rush (crip (slag 5 t)) dem:ag)
    ?~  id  ~
    `[%post u.id]
  ?:  =("comment-" (scag 8 t))
    =/  rest=tape  (slag 8 t)
    =/  parts=(list tape)  (split-on rest '-')
    ?~  parts  ~
    ?~  t.parts  ~
    =/  post-id  (rush (crip i.parts) dem:ag)
    =/  cmt-id  (rush (crip i.t.parts) dem:ag)
    ?~  post-id  ~
    ?~  cmt-id  ~
    `[%comment u.post-id u.cmt-id]
  ~
--
