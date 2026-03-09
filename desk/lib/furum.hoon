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
  body { font-family: Verdana, Geneva, sans-serif; font-size: 16px;
         color: #1a1a2e; background: #f0eee8; margin: 0; padding: 0;
         line-height: 1.55; }
  #hd { background: #cc2020; padding: 8px 16px; line-height: 32px; }
  #hd a { color: #fff; text-decoration: none; font-weight: bold;
           font-size: 18px; }
  #hd .nav { font-weight: normal; font-size: 16px; }
  #hd .nav a { color: #ffdede; font-weight: normal; font-size: 16px; }
  .ct { padding: 16px; max-width: 960px; }
  a { color: #8b1a1a; }
  .ti a { text-decoration: none; font-size: 18px; color: #1a1a2e; }
  .ti a:visited { color: #6a6a7a; }
  .host { font-size: 14px; color: #5a7a8a; }
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
  textarea { width: 540px; height: 160px; font-family: monospace;
              font-size: 16px; }
  input[type=text], input[type=url] { width: 440px; font-size: 16px;
                                        padding: 5px; }
  .btn { margin-top: 10px; padding: 8px 24px; cursor: pointer;
          background: #cc2020; color: #fff; border: none; font-size: 16px; }
  .btn:hover { background: #a01818; }
  .post-body { padding: 12px 0; max-width: 720px; white-space: pre-wrap;
                font-size: 16px; line-height: 1.6; }
  table.mod { border-collapse: collapse; font-size: 16px; }
  table.mod td, table.mod th { padding: 8px 16px; text-align: left;
                                 border-bottom: 1px solid #d0ccc4; }
  .err { color: #cc2020; padding: 20px; font-size: 16px; }
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
++  sort-posts
  |=  posts=(list post)
  ^-  (list post)
  %+  sort  posts
  |=  [a=post b=post]
  (gth created.a created.b)
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
  |=  [title=@t content=marl dark=?]
  ^-  manx
  =/  style-node=manx
    [[%style ~] [[[%$ [%$ (trip furum-css)]~] ~] ~]]
  =/  body-attrs=mart
    ?:(dark ~[['class' "dark"]] ~)
  =/  toggle-label=tape
    ?:(dark "light" "dark")
  =/  body-node=manx
    :_  :~
      ;div#hd
        ;span.dark-toggle
          ;form(method "post", action "/apps/furum/dark-mode", style "display:inline")
            ;button(type "submit"): {toggle-label}
          ==
        ==
        ;a/"/apps/furum": furum
        ;span.nav
          ;+  ;/("  |  ")
          ;a/"/apps/furum/create": new board
        ==
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
      ;title: {(trip title)}
      ;+  style-node
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
  %^  page-shell  'furum'
  [nav board-rows]
  dark
::
::  BOARD PAGE: list of posts
::
++  render-board
  |=  [host=@p =board-info posts=(list post) our=@p now=@da dark=?]
  ^-  manx
  =/  sorted  (sort-posts posts)
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  header=manx
    ;div
      ;h3: {(trip title.board-info)}
      ;p.me: {(trip description.board-info)}
      ;p
        ;a(href "{board-path}/submit"): submit post
        ;+  ;/("  |  ")
        ;a(href "{board-path}/mod"): moderate
      ==
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
    ;div.rw
      ;span.rk: {(a-co:co rank)}.
      ;form(method "post", action "{board-path}/vote", style "display:inline")
        ;input(type "hidden", name "target", value "post-{(a-co:co id.post)}");
        ;input(type "hidden", name "dir", value "up");
        ;button.va(type "submit"): ▲
      ==
      ;div
        ;span.ti
          ;a(href title-href): {(trip title.post)}
        ==
        ;+  ?~  url.post
              ;span;
            ;span.host: ({(trip u.url.post)})
        ;div.me
          ;+  ;/("{(a-co:co points)} points by {(scow %p author.post)} {(time-ago now created.post)} | ")
          ;a(href post-href): {(a-co:co comment-count.post)} comments
        ==
      ==
    ==
  %^  page-shell  (crip "furum - {(trip title.board-info)}")
  [header post-rows]
  dark
::
::  POST DETAIL PAGE: post with comments
::
++  render-post-page
  |=  [host=@p =board-info =post comments=(map comment-id comment) our=@p now=@da dark=?]
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
  %^  page-shell  (crip "furum - {(trip title.post)}")
  :~
    ;div
      ;form(method "post", action "{board-path}/vote", style "display:inline")
        ;input(type "hidden", name "target", value "post-{(a-co:co id.post)}");
        ;input(type "hidden", name "dir", value "up");
        ;button.va(type "submit"): ▲
      ==
      ;span.ti: {" "}{(trip title.post)}
      ;+  ?~  url.post
            ;span;
          ;a(href (trip u.url.post)): {(trip u.url.post)}
      ;div.me
        ;+  ;/("{(a-co:co points)} points by {(scow %p author.post)} {(time-ago now created.post)}")
      ==
      ;+  ?~  body.post
            ;span;
          ;div.post-body: {(trip u.body.post)}
    ==
    ;hr;
    ;form(method "post", action "{post-path}/comment")
      ;textarea(name "body", placeholder "add a comment...");
      ;br;
      ;input.btn(type "submit", value "add comment");
    ==
    ;hr;
    ;div
      ;*  (render-flat-comments flat-comments board-path id.post now)
    ==
  ==
  dark
::
::  render a flat list of depth-tagged comments
::
++  render-flat-comments
  |=  [cmts=(list [@ud comment]) board-path=tape post-id=post-id now=@da]
  ^-  marl
  %+  turn  cmts
  |=  [depth=@ud c=comment]
  ^-  manx
  =/  points=@ud
    =/  up  ~(wyt in up-votes.c)
    =/  dn  ~(wyt in down-votes.c)
    ?:((gte up dn) (sub up dn) 0)
  =/  indent=tape  (a-co:co (mul depth 20))
  ;div(style "margin-left: {indent}px")
    ;div.cm
      ;div.cm-meta
        ;form(method "post", action "{board-path}/vote", style "display:inline")
          ;input(type "hidden", name "target", value "comment-{(a-co:co post-id)}-{(a-co:co id.c)}");
          ;input(type "hidden", name "dir", value "up");
          ;button.va(type "submit"): ▲
        ==
        ;+  ;/(" {(scow %p author.c)} {(a-co:co points)} points {(time-ago now created.c)}")
      ==
      ;div: {(trip body.c)}
      ;details
        ;summary.me: reply
        ;form(method "post", action "{board-path}/{(a-co:co post-id)}/comment")
          ;input(type "hidden", name "parent", value "{(a-co:co id.c)}");
          ;textarea(name "body", rows "3", cols "60");
          ;br;
          ;input.btn(type "submit", value "reply");
        ==
      ==
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
  %^  page-shell  'furum - submit'
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
  dark
::
::  CREATE BOARD FORM
::
++  render-create
  |=  dark=?
  ^-  manx
  %^  page-shell  'furum - create board'
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
  dark
::
::  MODERATION PANEL
::
++  render-mod
  |=  [host=@p =board-info roles=(map @p role) dark=?]
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
  %^  page-shell  (crip "furum - mod {(trip name.board-info)}")
  :~
    ;h3: Moderate {(trip title.board-info)}
    ;p.me: Default role: {(trip (role-to-text default-role.board-info))}
    ;h4: Set User Role
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
    ;hr;
    ;h4: Current Roles
    role-section
  ==
  dark
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
  %^  page-shell  'furum - registry admin'
  :(welp header admin-section board-rows)
  dark
::
::  ERROR PAGE
::
++  render-error
  |=  [msg=tape dark=?]
  ^-  manx
  %^  page-shell  'furum - error'
  :~  ;div.err
        ;h3: Error
        ;p: {msg}
        ;p: ;a/"/apps/furum": back to home
      ==
  ==
  dark
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
