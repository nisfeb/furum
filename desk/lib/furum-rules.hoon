::  lib/furum-rules.hoon: the agent's pure decisions (access, limits,
::  pruning, cache merges). they live here, not in the agent, so the
::  suites in tests/lib can reach them.
::
/-  *furum
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
::  +prune-timer: arm a board's prune wake in the next slot of a fixed 6h
::  grid, cancelling that slot first. arming is then idempotent: reloads,
::  re-saves, and extra timer chains all collapse into one timer.
::
++  prune-timer
  |=  [name=board-name now=@da]
  ^-  (list card:agent:gall)
  =/  at=@da  (add (sub now (mod now ~h6)) ~h6)
  :~  [%pass /prune/[name] %arvo %b %rest at]
      [%pass /prune/[name] %arvo %b %wait at]
  ==
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
::  +merge-comment: a host's new-comment fact into our cached comments.
::  our own comment was inserted optimistically under a guessed id, so
::  drop that copy before adding the host's
::
++  merge-comment
  |=  [pc=(map comment-id comment) our=@p cmt=comment]
  ^-  (map comment-id comment)
  =?  pc  =(our author.cmt)
    %-  malt
    %+  skip  ~(tap by pc)
    |=  [* c=comment]
    ?&  =(our author.c)
        =(parent.c parent.cmt)
        =(body.c body.cmt)
    ==
  (~(put by pc) id.cmt cmt)
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
--
