::  lib/furum-registry.hoon: the board directory, on the ship that keeps
::  it. Each registry action is a pure transition, ported from the Gall
::  agent's +handle-registry-action.
::
/<  *   /lib/furum-types.hoon
/<  fl  /lib/furum.hoon
|%
::  +reg-act: one action by `who` on the registry `our` keeps. `here` is
::  where `who` says its furum is installed, kept so readers can find
::  its boards.
::
++  reg-act
  |=  [who=@p our=@p here=path act=registry-action st=registry-store]
  ^-  (each registry-store deny)
  =/  admin=?  |(=(who our) (~(has in admins.st) who))
  =/  entry
    |=  [name=board-name f=$-(directory-entry directory-entry)]
    ^-  (each registry-store deny)
    ?.  admin  |+[403 'only the registry and its admins may curate']
    ?~  e=(~(get by dir.st) name)  &+st
    &+st(dir (~(put by dir.st) name (f u.e)))
  ?-    -.act
      %register
    ?.  (valid-board-name:fl name.act)  |+[400 'board names may only use a-z, 0-9 and -']
    ?:  (gth (lent here) 16)  |+[400 'an install path that long is not one']
    =/  old  (~(get by dir.st) name.act)
    ::  a name belongs to its first registrant
    ?:  ?&(?=(^ old) !=(who host.u.old))  |+[409 'another ship registered that name first']
    =/  title=@t  (crip (scag 200 (trip title.act)))
    =/  desc=@t  (crip (scag 2.000 (trip description.act)))
    =/  e=directory-entry
      ?~  old  [name.act title desc who ~ |]
      u.old(title title, description desc)
    &+st(dir (~(put by dir.st) name.act e), hosts (~(put by hosts.st) who here))
  ::
      %unregister
    ?~  old=(~(get by dir.st) name.act)  &+st
    ?.  =(who host.u.old)  |+[403 'only its host may unregister a board']
    &+st(dir (~(del by dir.st) name.act))
  ::
      %tag-board     (entry name.act |=(e=directory-entry e(tags (~(put in tags.e) tag.act))))
      %untag-board   (entry name.act |=(e=directory-entry e(tags (~(del in tags.e) tag.act))))
      %curate-board  (entry name.act |=(e=directory-entry e(curated curated.act)))
  ::
      %add-registry-admin
    ?.  =(who our)  |+[403 'only the registry may name admins']
    &+st(admins (~(put in admins.st) who.act))
  ::
      %remove-registry-admin
    ?.  =(who our)  |+[403 'only the registry may name admins']
    &+st(admins (~(del in admins.st) who.act))
  ::
      %refresh-registry  &+st
  ==
--
