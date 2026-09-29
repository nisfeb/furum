::  tests for lib/furum-registry: the board directory's rules
::
/+  *test, *furum-types, fr=furum-registry
|%
++  reg  ~bus
++  here  /apps/furum
++  run
  |=  acts=(list [who=@p act=registry-action])
  ^-  registry-store
  =|  st=registry-store
  |-
  ?~  acts  st
  =/  r  (reg-act:fr who.i.acts reg here act.i.acts st)
  ?>  ?=(%& -.r)
  $(acts t.acts, st p.r)
++  deny
  |=  [st=registry-store who=@p act=registry-action]
  ^-  (unit [@ud @t])
  =/  r  (reg-act:fr who reg here act st)
  ?:(?=(%& -.r) ~ `p.r)
::
::  a name belongs to its first registrant, who can retitle it without
::  losing its tags or curation, and who alone can take it down; each
::  registrant's install path is kept
::
++  test-register
  =/  st
    %-  run
    :~  [~nec %register %b 'B' 'd']
        [reg %tag-board %b %news]
        [reg %curate-board %b &]
        [~nec %register %b 'B2' 'd2']
    ==
  ;:  weld
    %+  expect-eq  !>(`[%b 'B2' 'd2' ~nec (sy ~[%news]) &])
      !>((~(get by dir.st) %b))
    (expect-eq !>(`here) !>((~(get by hosts.st) ~nec)))
    (expect-eq !>(`[409 'another ship registered that name first']) !>((deny st ~wes %register %b 'mine' '')))
    (expect-eq !>(`[403 'only its host may unregister a board']) !>((deny st ~wes %unregister %b)))
    (expect-eq !>(~) !>((deny st ~nec %unregister %b)))
    (expect-eq !>(`[400 'board names may only use a-z, 0-9 and -']) !>((deny st ~wes %register %'B B' '' '')))
    %+  expect-eq  !>(|+[400 'an install path that long is not one'])
      !>((reg-act:fr ~wes reg (reap 17 %a) [%register %c 'C' ''] st))
    (expect-eq !>(%&) !>(-:(reg-act:fr ~wes reg (reap 16 %a) [%register %c 'C' ''] st)))
  ==
::
::  the registry and its admins curate; only the registry names admins
::
++  test-curation
  =/  st  (run ~[[~nec %register %b 'B' ''] [reg %add-registry-admin ~wes]])
  ;:  weld
    (expect-eq !>(~) !>((deny st ~wes %curate-board %b &)))
    (expect-eq !>(`[403 'only the registry and its admins may curate']) !>((deny st ~nec %tag-board %b %x)))
    (expect-eq !>(`[403 'only the registry may name admins']) !>((deny st ~wes %add-registry-admin ~nec)))
    (expect-eq !>(~) !>((deny st reg %remove-registry-admin ~wes)))
    ::  curating a board that isn't there changes nothing
    (expect-eq !>(~) !>((deny st reg %tag-board %zz %x)))
  ==
--
