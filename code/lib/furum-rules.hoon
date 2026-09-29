::  lib/furum-rules.hoon: the pure decisions: who may do what, limits,
::  pruning, and the crash backoff. They live here, not in the nexus, so
::  the suites in tests/nexus can reach them.
::
/<  *  /lib/furum-types.hoon
|%
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
::  +prune-at: the next slot of a fixed 6h grid, when auto-prune runs
::
++  prune-at
  |=  now=@da
  ^-  @da
  (add (sub now (mod now ~h6)) ~h6)
::
::  +prunable: the posts auto-prune deletes now: created at or before the
::  cutoff, below the minimum net score, and not pinned
::
++  prunable
  |=  [brd=board cfg=prune-config now=@da]
  ^-  (list post-id)
  =/  cutoff=@da  (sub now after.cfg)
  %+  murn  ~(tap by posts.brd)
  |=  [id=post-id =post]
  ^-  (unit post-id)
  ?:  (~(has in pinned.brd) id)  ~
  ?:  (gth created.post cutoff)  ~
  =/  up=@ud  ~(wyt in up-votes.post)
  =/  dn=@ud  ~(wyt in down-votes.post)
  =/  score=@ud  ?:((gte up dn) (sub up dn) 0)
  ?:  (gte score min-score.cfg)  ~
  `id
::
::  +group-ships: who may read a paid board's content besides its host:
::  its moderators, and its members whose time hasn't run out
::
++  group-ships
  |=  [brd=board now=@da]
  ^-  (set @p)
  %-  ~(uni in (silt (murn ~(tap by roles.brd) |=([w=@p r=role] ?.(=(%mod r) ~ `w)))))
  (silt (murn ~(tap by paid.brd) |=([w=@p u=@da] ?.((gth u now) ~ `w))))
::
::  +open-paths: what every ship may read of the boards we host: each
::  board's pub/, and a free board's content/. A paid board's content is
::  its group's alone.
::
++  open-paths
  |=  boards=(list [name=@ta paid=?])
  ^-  (list path)
  %-  zing
  %+  turn  boards
  |=  [name=@ta paid=?]
  ?:  paid  ~[/boards/[name]/pub]
  ~[/boards/[name]/pub /boards/[name]/content]
::
::  +next-expiry: when a member of the board next runs out, if one will
::
++  next-expiry
  |=  [brd=board now=@da]
  ^-  (unit @da)
  =/  later=(list @da)  (sort (skim ~(val by paid.brd) |=(u=@da (gth u now))) lth)
  ?~  later  ~
  `i.later
::
::  +sane-text: non-empty and at most max bytes; bounds what a remote
::  poke can store on the host
::
++  sane-text
  |=  [txt=@t max=@ud]
  ^-  ?
  &((gth (met 3 txt) 0) (lte (met 3 txt) max))
::
++  sane-post
  |=  [title=@t url=(unit @t) body=(unit @t)]
  ^-  ?
  ?&  (sane-text title 300)
      ?~(url & (sane-text u.url 2.048))
      ?~(body & (sane-text u.body 40.000))
  ==
::
++  sane-comment
  |=  body=@t
  ^-  ?
  (sane-text body 10.000)
::
::  +cross-site: the browser marked this request as from another site.
::  eyre's session cookie has no SameSite, so such a post would arrive
::  authenticated. no header: not a browser, so no cookie was borrowed.
::
++  cross-site
  |=  headers=(list [key=@t value=@t])
  ^-  ?
  =/  site  (get-header:http 'sec-fetch-site' headers)
  ?&(?=(^ site) !=('same-origin' u.site))
::
++  rate-limit-base  ~s10
++  rate-limit-max   ~m10
::
::  +check-rate-limit: returns %.y if action is allowed
::
++  check-rate-limit
  |=  [who=@p name=board-name brd=board now=@da limits=(map [@p board-name] [last=@da cooldown=@dr])]
  ^-  ?
  ?:  (is-mod who brd)  %.y
  =/  entry  (~(get by limits) [who name])
  ?~  entry  %.y
  (gte (sub now last.u.entry) cooldown.u.entry)
::
::  +update-rate-limit: record an action timestamp, escalate or decay cooldown
::
::  if elapsed >= cooldown*4: reset to base (cooled off)
::  otherwise: double the cooldown (capped at max)
::
++  update-rate-limit
  |=  [who=@p name=board-name now=@da limits=(map [@p board-name] [last=@da cooldown=@dr])]
  ^-  (map [@p board-name] [last=@da cooldown=@dr])
  =/  entry  (~(get by limits) [who name])
  =/  new-cd=@dr
    ?~  entry  rate-limit-base
    =/  elapsed=@dr  (sub now last.u.entry)
    ?:  (gte elapsed (mul 4 cooldown.u.entry))
      rate-limit-base
    (min rate-limit-max (mul 2 cooldown.u.entry))
  (~(put by limits) [who name] [now new-cd])
::
::  ==  json, read without crashing
::
++  gj                                          ::  a key's value, or null
  |=  [jon=json k=@t]
  ^-  json
  ?.  ?=([%o *] jon)  ~
  (fall (~(get by p.jon) k) ~)
++  set-key                                     ::  a key set on an object
  |=  [jon=json k=@t v=json]
  ^-  json
  ?.  ?=([%o *] jon)  [%o (~(gas by *(map @t json)) ~[[k v]])]
  [%o (~(put by p.jon) k v)]
++  gn                                          ::  a whole number
  |=  [jon=json k=@t]
  ^-  (unit @ud)
  =/  v=json  (gj jon k)
  ?.  ?=([%n *] v)  ~
  (rush p.v dem)
::  epoch milliseconds; a time before the epoch is 0, not an underflow
::
++  ms-of
  |=  t=@da
  ^-  @ud
  ?:  (lth t ~1970.1.1)  0
  (div (mul 1.000 (sub t ~1970.1.1)) ~s1)
++  da-of-ms  |=(ms=@ud ^-(@da (add ~1970.1.1 (div (mul ms ~s1) 1.000))))
::  ==  after a crash: orrery's +rise-plan (version 60)
::
::  +rise-plan: a crashed fiber's crashes in a row and when it tries
::  again, from its row in rise.json: 1, 2, 4 and up to 60 minutes, the
::  count starting over after two quiet hours, longer than the longest
::  wait, so the waits stay at an hour rather than cycling back to a
::  minute. A restart that is not a crash (a poke refused while waiting)
::  keeps the wait it had.
::
++  rise-plan
  |=  [row=json crash=? now=@da]
  ^-  [n=@ud until=@da]
  =/  was=@ud  (fall (gn row 'n') 0)
  =/  n=@ud
    ?.  crash  was
    ?:((gth now (add (da-of-ms (fall (gn row 'last_ms') 0)) ~h2)) 1 +(was))
  :-  n
  ?.  crash  (da-of-ms (fall (gn row 'until_ms') 0))
  (add now (min ~h1 (mul ~m1 (bex (dec (min n 7))))))
::  +rise-row: a fiber's row in rise.json
::
++  rise-row
  |=  [plan=[n=@ud until=@da] now=@da]
  ^-  json
  %-  pairs:enjs:format
  :~  ['n' (numb:enjs:format n.plan)]
      ['last_ms' (numb:enjs:format (ms-of now))]
      ['until_ms' (numb:enjs:format (ms-of until.plan))]
  ==
--
