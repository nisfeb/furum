::  tests for lib/furum: link safety, input parsing and the orderings
::  users see
::
/+  *test, *furum-types, fl=furum, th=furum-theme
|%
++  mk-post
  |=  [id=@ud at=@da up=@ud dn=@ud]
  ^-  post
  =|  p=post
  %=  p
    id          id
    created     at
    up-votes    (sy (turn (scag up (gulf 1 20)) |=(i=@ `@p`i)))
    down-votes  (sy (turn (scag dn (gulf 101 120)) |=(i=@ `@p`i)))
  ==
::
::  only http(s) and furum-relative urls may become links; every other
::  scheme, however it is cased or padded, becomes "#"
::
++  test-safe-url
  =/  ok  `(list @t)`~['http://a.com' 'https://a.com/x' 'HTTPS://A.COM' '/apps/furum/b/~zod/x/1']
  =/  no
    `(list @t)`~['javascript:alert(1)' 'JavaScript:alert(1)' ' javascript:x' 'data:text/html,x' '//evil.com' '/apps/furumx' '']
  ;:  weld
    (expect-eq !>(~[%.y %.y %.y %.y]) !>((turn ok safe-url:fl)))
    (expect-eq !>(~[%.n %.n %.n %.n %.n %.n %.n]) !>((turn no safe-url:fl)))
    (expect-eq !>("#") !>((safe-href:fl 'javascript:alert(1)')))
    (expect-eq !>("https://a.com/x") !>((safe-href:fl 'https://a.com/x')))
  ==
::
::  no view links a stored javascript: url: feed, board row, pinned row,
::  post page and notifications. the feed once did. the same views do
::  link an https url, so a page that rendered nothing can't pass.
::
++  test-rendered-links
  =/  now  ~2026.1.1
  =/  bi=board-info  [%b 'B' '' ~zod now %poster %.n]
  =/  pages
    |=  url=@t
    ^-  (list tape)
    =/  p=post  (mk-post 0 now 0 0)
    =.  p  p(title 'T', url `url)
    =/  lk  (draw:th %system ~ ~)
    :~  (en-xml:html (render-feed:fl ~[[~zod %b p]] ~zod now lk 1 ~))
        (en-xml:html (render-board:fl ~zod bi ~[p] ~zod now %.n %.y lk %new %.n 1 ~ ~ ''))
        (en-xml:html (render-board:fl ~zod bi ~[p] ~zod now %.n %.y lk %new %.n 1 (sy ~[0]) ~ ''))
        (en-xml:html (render-post-page:fl ~zod bi p ~ ~zod now %.n %.y lk ~ ~))
        (en-xml:html (render-notifications:fl ~[['T' 'b' `url now %.n]] now lk))
    ==
  =/  has  |=(k=tape |=(t=tape ?=(^ (find k (cass t)))))
  ;:  weld
    %+  expect-eq  !>(~[%.n %.n %.n %.n %.n])
      !>((turn (pages 'JavaScript:alert(1)') (has "href=\"javascript:")))
    %+  expect-eq  !>(~[%.y %.y %.y %.y %.y])
      !>((turn (pages 'https://ok.example/x') (has "href=\"https://ok.example/x\"")))
  ==
::
::  the loading page draws in the reader's theme, as every other page
::  does, rather than flashing the browser's white
::
++  test-loading-themed
  =/  page  |=(=look:th (en-xml:html (render-loading:fl "/apps/furum/b/~zod/b" look)))
  =/  has  |=([k=tape t=tape] ?=(^ (find k t)))
  =/  dk  (page (draw:th %dark ~ ~))
  ;:  weld
    (expect-eq !>(%.y) !>((has "--bg:#0a0a14;" dk)))
    (expect-eq !>(%.y) !>((has "name=\"theme-color\" content=\"#1a0808\"" dk)))
    (expect-eq !>(%.y) !>((has "prefers-color-scheme: dark" (page (draw:th %system ~ ~)))))
  ==
::
::  body text links only http(s) urls, and keeps the text around them
::
++  test-linkify
  =/  html  |=(t=tape (en-xml:html (linkify-div:fl "b" t)))
  =/  good  (html "see https://a.com/x now")
  ;:  weld
    (expect-eq !>(%.y) !>(?=(^ (find "<a href=\"https://a.com/x\"" good))))
    (expect-eq !>(%.y) !>(?=(^ (find "see <a" good))))
    (expect-eq !>(%.y) !>(?=(^ (find "</a> now" good))))
    (expect-eq !>(~) !>((find "<a" (html "javascript:alert(1)"))))
  ==
::
::  board names are url-safe: 1 to 64 of a-z, 0-9 and -
::
++  test-valid-board-name
  =/  ok  `(list @t)`~['abc' '123' '---' 'az-09' 'my-board-2' (crip (reap 64 'a'))]
  =/  no  `(list @t)`~['' (crip (reap 65 'a')) 'Upper' 'has space' 'a/b' 'a_b' '..' 'café']
  ;:  weld
    (expect-eq !>(~[%.y %.y %.y %.y %.y %.y]) !>((turn ok valid-board-name:fl)))
    (expect-eq !>(~[%.n %.n %.n %.n %.n %.n %.n %.n]) !>((turn no valid-board-name:fl)))
  ==
::
::  ecash is swapped only at the board's own mint (a trailing slash aside),
::  or at the known public mints when the board names none
::
++  test-mint-accepted
  =/  own=payment-config  [100 ~d30 `'https://m.example/']
  =/  any=payment-config  [100 ~d30 ~]
  ;:  weld
    (expect-eq !>(%.y) !>((mint-accepted:fl own 'https://m.example')))
    (expect-eq !>(%.y) !>((mint-accepted:fl own 'https://m.example/')))
    (expect-eq !>(%.n) !>((mint-accepted:fl own 'https://mint.minibits.cash/Bitcoin')))
    (expect-eq !>(%.n) !>((mint-accepted:fl own 'https://evil.example')))
    (expect-eq !>(%.y) !>((mint-accepted:fl any 'https://mint.minibits.cash/Bitcoin/')))
    (expect-eq !>(%.n) !>((mint-accepted:fl any 'https://evil.example')))
  ==
::
::  forms decode as browsers encode them: + is a space, %XX a byte in
::  either case (so utf-8 and a body's line breaks survive), a bad escape
::  is kept as typed, never a crash; paths split on /
::
++  test-parse-form
  =/  form
    %-  parse-form:fl
    `(as-octs:mimes:html 'title=a+b%21&url=&body=caf%C3%A9&nl=a%0Ab%0ac%3F%3f&bad=%zz%-5%@1')
  ;:  weld
    (expect-eq !>(`'a b!') !>((~(get by form) 'title')))
    (expect-eq !>(`'') !>((~(get by form) 'url')))
    (expect-eq !>(`'café') !>((~(get by form) 'body')))
    (expect-eq !>(`(crip "a\0ab\0ac??")) !>((~(get by form) 'nl')))
    (expect-eq !>(`'%zz%-5%@1') !>((~(get by form) 'bad')))
    %+  expect-eq
      !>([`(list @t)`~['apps' 'furum' 'b' '~zod' 'x'] (my ~[['sort' 'new'] ['page' '2']])])
      !>((parse-request-url:fl '/apps/furum/b/~zod/x?sort=new&page=2'))
  ==
::
::  a vote form value names exactly one post or comment, at any id (ids
::  past 999 once failed: the parser wanted "1.000"); anything else is
::  refused rather than guessed at
::
++  test-parse-vote-target
  ;:  weld
    (expect-eq !>(`[%post 12]) !>((parse-vote-target:fl 'post-12')))
    (expect-eq !>(`[%comment 3 4]) !>((parse-vote-target:fl 'comment-3-4')))
    (expect-eq !>(`[%post 1.000]) !>((parse-vote-target:fl 'post-1000')))
    (expect-eq !>(`[%comment 1.000 12.345]) !>((parse-vote-target:fl 'comment-1000-12345')))
    (expect-eq !>(~) !>((parse-vote-target:fl 'post-')))
    (expect-eq !>(~) !>((parse-vote-target:fl 'post-x')))
    (expect-eq !>(~) !>((parse-vote-target:fl 'comment-3')))
    (expect-eq !>(~) !>((parse-vote-target:fl 'comment-a-4')))
    (expect-eq !>(~) !>((parse-vote-target:fl 'bogus-1')))
  ==
::
::  ?page= is a positive integer defaulting to 1, ?sort= defaults to hot,
::  and 30 posts fill a page
::
++  test-paging
  =/  arg  |=([k=@t v=@t] (my ~[[k v]]))
  =/  items  (gulf 1 31)
  ;:  weld
    (expect-eq !>(1) !>((parse-page:fl ~)))
    (expect-eq !>(1) !>((parse-page:fl (arg 'page' '0'))))
    (expect-eq !>(1) !>((parse-page:fl (arg 'page' '1'))))
    (expect-eq !>(3) !>((parse-page:fl (arg 'page' '3'))))
    (expect-eq !>(1) !>((parse-page:fl (arg 'page' 'x'))))
    (expect-eq !>(%hot) !>((parse-sort:fl ~)))
    (expect-eq !>(%top) !>((parse-sort:fl (arg 'sort' 'top'))))
    (expect-eq !>(%hot) !>((parse-sort:fl (arg 'sort' 'bogus'))))
    (expect-eq !>([31 (gulf 1 30)]) !>((paginate:fl 1 items)))
    (expect-eq !>([31 ~[31]]) !>((paginate:fl 2 items)))
  ==
::
::  a thread renders depth-first: replies under their parent, siblings
::  oldest first
::
++  test-flatten-comments
  =/  mk
    |=  [id=@ud parent=(unit @ud) at=@da]
    ^-  comment
    =|  c=comment
    c(id id, parent parent, created at)
  =/  cs
    %-  my
    :~  [1 (mk 1 ~ ~2026.1.2)]
        [2 (mk 2 ~ ~2026.1.1)]
        [3 (mk 3 `1 ~2026.1.3)]
        [4 (mk 4 `3 ~2026.1.4)]
        [5 (mk 5 `1 ~2026.1.2)]
    ==
  %+  expect-eq
    !>(`(list [@ud @ud])`~[[0 2] [0 1] [1 5] [1 3] [2 4]])
    !>((turn (flatten-comments:fl cs) |=([d=@ud c=comment] [d id.c])))
::
::  top ranks by net votes (never below zero), newer first on a tie; new
::  is newest first; hot prefers more votes at one age, youth at one
::  score, and the newer post at an equal score
::
++  test-sort-posts
  =/  now  ~2026.1.10
  =/  ps
    :~  (mk-post 1 ~2026.1.1 3 0)
        (mk-post 2 ~2026.1.2 3 0)
        (mk-post 3 ~2026.1.3 5 0)
        (mk-post 4 ~2026.1.4 1 4)
        (mk-post 5 ~2026.1.5 0 0)
    ==
  =/  ids  |=(l=(list post) (turn l |=(p=post id.p)))
  ;:  weld
    (expect-eq !>(~[3 2 1 5 4]) !>((ids (sort-posts-dispatch:fl %top now ps))))
    (expect-eq !>(~[5 4 3 2 1]) !>((ids (sort-posts-dispatch:fl %new now ps))))
    %+  expect-eq  !>(~[7 6 8])
      !>  %-  ids
      %^  sort-posts-dispatch:fl  %hot  now
      :~  (mk-post 6 (sub now ~h1) 1 0)
          (mk-post 7 (sub now ~h1) 2 0)
          (mk-post 8 (sub now ~h10) 2 0)
      ==
    ::  at an equal score, newer first: a board of unvoted posts sorts
    ::  in a total order, which +sort needs to stay fast
    %+  expect-eq  !>(~[11 10 9])
      !>  %-  ids
      %^  sort-posts-dispatch:fl  %hot  now
      :~  (mk-post 9 (sub now ~h3) 0 0)
          (mk-post 11 (sub now ~h1) 0 0)
          (mk-post 10 (sub now ~h2) 0 0)
      ==
  ==
::
::  counts read with thousands separators
::
++  test-commafy
  ;:  weld
    (expect-eq !>("0") !>((commafy:fl 0)))
    (expect-eq !>("999") !>((commafy:fl 999)))
    (expect-eq !>("1,000") !>((commafy:fl 1.000)))
    (expect-eq !>("1,234,567") !>((commafy:fl 1.234.567)))
  ==
::
::  only an http(s) url gets an inline image preview; an http:// buried in
::  another scheme once passed
::
++  test-is-image-url
  ;:  weld
    (expect-eq !>(%.y) !>((is-image-url:fl 'https://a.com/x.PNG')))
    (expect-eq !>(%.y) !>((is-image-url:fl 'http://a.com/x.jpg')))
    (expect-eq !>(%.n) !>((is-image-url:fl 'https://a.com/x.txt')))
    (expect-eq !>(%.n) !>((is-image-url:fl 'javascript:alert(1)//http://x.png')))
  ==
--
