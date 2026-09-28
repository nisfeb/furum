::  lib/furum-rules.hoon: the nexus's pure decisions, import-free so the
::  kit builds it on a clay test desk too. The agent's rules (desk/lib)
::  come across in phase 2 (docs/grubbery-migration.md).
::
|%
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
