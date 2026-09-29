::  tests for lib/furum-theme: a theme's colours derived as talon derives
::  them, talon's settings read as talon writes them, and what a page
::  draws with
::
/+  *test, th=furum-theme
|%
++  role  role:th
::  talon's own entries, as its SettingsSyncImpl writes them to %settings
++  talon-themes-json
  '''
  {"themes":[{"id":"a1","name":"Dusk","dark":true,"primary":"#FBBF24","secondary":"#A5B4FC","tertiary":"#34D399","background":"#0F0D1A","surface":"#1A1625"},{"id":"b2","name":"Broken","dark":false,"primary":"#FFFFFF"}],"activeId":"a1"}
  '''
::
::  colours read and written as "#rrggbb", and nothing else read
::
++  test-colours
  ;:  weld
    (expect-eq !>(`0xfb.bf24) !>((parse:th '#FBBF24')))
    (expect-eq !>(`0xfb.bf24) !>((parse:th 'fbbf24')))
    (expect-eq !>(~) !>((parse:th '#fbbf2')))
    (expect-eq !>(~) !>((parse:th '#fbbf2g')))
    (expect-eq !>(~) !>((parse:th '')))
    (expect-eq !>('#0a0b0c') !>((hexa:th 0xa.0b0c)))
    (expect-eq !>(0x80.8080) !>((mix:th 0x0 0xff.ffff 500)))
    (expect-eq !>(0xff.ffff) !>((mix:th 0x0 0xff.ffff 1.000)))
    (expect-eq !>(0) !>((lum:th 0x0)))
    (expect-eq !>(10.000) !>((lum:th 0xff.ffff)))
    ::  pure red, green and blue weigh as Compose weighs them
    (expect-eq !>(~[2.126 7.152 722]) !>(~[(lum:th 0xff.0000) (lum:th 0xff00) (lum:th 0xff)]))
  ==
::
::  a theme's scheme, by talon's rules: its picked colours as they are;
::  ink on a light colour and paper on a dark one; containers toward the
::  background (dark) or white (light); the header in the primary colour
::  (light) or the surface (dark)
::
++  test-custom
  =/  dusk=theme:th  ['a1' 'Dusk' & '#FBBF24' '#A5B4FC' '#34D399' '#0F0D1A' '#1A1625']
  =/  day=theme:th  ['d' 'Day' | '#4338CA' '#059669' '#DC2626' '#FAFAF9' '#FFFFFF']
  =/  d  (custom:th dusk)
  =/  l  (custom:th day)
  ;:  weld
    (expect-eq !>(0xfb.bf24) !>((role d 'primary')))
    (expect-eq !>(ink:th) !>((role d 'on-primary')))
    (expect-eq !>(paper:th) !>((role d 'text')))
    (expect-eq !>(0xa5.b4fc) !>((role d 'link')))
    (expect-eq !>((mix:th 0xfb.bf24 0xf.0d1a 600)) !>((role d 'pin')))
    (expect-eq !>(0x1a.1625) !>((role d 'hd')))
    (expect-eq !>(0xfb.bf24) !>((role d 'hd-text')))
    (expect-eq !>(paper:th) !>((role l 'on-primary')))
    (expect-eq !>(ink:th) !>((role l 'text')))
    (expect-eq !>((mix:th 0x43.38ca 0xff.ffff 800)) !>((role l 'pin')))
    (expect-eq !>(0x43.38ca) !>((role l 'hd')))
    (expect-eq !>(paper:th) !>((role l 'hd-text')))
    ::  hover, input and a container's text blend toward the light (dark
    ::  themes) or the dark (light ones)
    (expect-eq !>((mix:th 0xfb.bf24 0xff.ffff 150)) !>((role d 'primary-hover')))
    (expect-eq !>((mix:th 0x43.38ca 0x0 150)) !>((role l 'primary-hover')))
    (expect-eq !>((mix:th 0x1a.1625 0x0 300)) !>((role d 'input')))
    (expect-eq !>(0xff.ffff) !>((role l 'input')))
    (expect-eq !>((mix:th 0x34.d399 0xff.ffff 750)) !>((role d 'on-note')))
    (expect-eq !>((mix:th 0xdc.2626 0x0 650)) !>((role l 'on-note')))
    ::  a colour that won't read falls back to the built-in one
    %+  expect-eq  !>((role (built-in:th |) 'bg'))
      !>((role (custom:th day(background 'nope')) 'bg'))
  ==
::
::  an accent repaints the primary colour, its text, and whatever else
::  was in the primary colour: the light header, the dark header's text;
::  containers and the dark sidebar's links keep theirs
::
++  test-tint
  =/  l  (tint:th (built-in:th |) 0x10.1541 |)
  =/  d  (tint:th (built-in:th &) 0xfb.bf24 &)
  ;:  weld
    (expect-eq !>(0x10.1541) !>((role l 'primary')))
    (expect-eq !>(0xff.ffff) !>((role l 'on-primary')))
    (expect-eq !>(0x10.1541) !>((role l 'hd')))
    (expect-eq !>(0xff.ffff) !>((role l 'hd-text')))
    (expect-eq !>(0x10.1541) !>((role l 'side-link')))
    (expect-eq !>((role (built-in:th |) 'pin')) !>((role l 'pin')))
    (expect-eq !>(ink:th) !>((role d 'on-primary')))
    (expect-eq !>(0xfb.bf24) !>((role d 'hd-text')))
    (expect-eq !>((role (built-in:th &) 'hd')) !>((role d 'hd')))
    (expect-eq !>((role (built-in:th &) 'side-link')) !>((role d 'side-link')))
    (expect-eq !>((mix:th 0x10.1541 0x0 150)) !>((role l 'primary-hover')))
    (expect-eq !>((mix:th 0xfb.bf24 0xff.ffff 150)) !>((role d 'primary-hover')))
  ==
::
::  what a page draws with: the device's light or dark (both, the dark
::  under a media query, and a browser bar colour for each), or one; a
::  theme brings its own; an accent shows in either
::
++  test-draw
  =/  sys  (draw:th %system ~ ~)
  =/  dk  (draw:th %dark ~ ~)
  =/  dusk=theme:th  ['a1' 'Dusk' & '#FBBF24' '#A5B4FC' '#34D399' '#0F0D1A' '#1A1625']
  =/  own  (draw:th %light `dusk ~)
  =/  tinted  (draw:th %system ~ `0x10.1541)
  =/  has  |=([l=look:th t=tape] ?=(^ (find t (trip style.l))))
  ;:  weld
    %+  expect-eq  !>(~[['(prefers-color-scheme: light)' '#cc2020'] ['(prefers-color-scheme: dark)' '#1a0808']])
      !>(bars.sys)
    (expect-eq !>(%.y) !>((has sys "@media (prefers-color-scheme: dark)")))
    (expect-eq !>(%.y) !>((has sys "color-scheme:light dark")))
    (expect-eq !>(~[['' '#1a0808']]) !>(bars.dk))
    (expect-eq !>(%.n) !>((has dk "@media")))
    (expect-eq !>(%.y) !>((has dk "--bg:#0a0a14;")))
    ::  a dark theme is dark whatever the mode
    (expect-eq !>(%.y) !>((has own "color-scheme:dark;")))
    (expect-eq !>(%.y) !>((has own "--primary:#fbbf24;")))
    (expect-eq !>(~[['' '#1a1625']]) !>(bars.own))
    (expect-eq !>(%.y) !>((has tinted "--hd:#101541;")))
    (expect-eq !>(%.n) !>((has tinted "#cc2020")))
  ==
::
::  talon's settings as talon writes them: saved themes (one that won't
::  read left out) and the active one; its accent, with talon's defaults
::  (unset reads as off, the profile colour)
::
++  test-talon-settings
  =/  ts  (talon-themes:th talon-themes-json)
  ;:  weld
    %+  expect-eq
      !>(`[~[['a1' 'Dusk' & '#FBBF24' '#A5B4FC' '#34D399' '#0F0D1A' '#1A1625']] `'a1'])
      !>(ts)
    (expect-eq !>(`[~ ~]) !>((talon-themes:th '{}')))
    (expect-eq !>(~) !>((talon-themes:th 'nope')))
    (expect-eq !>(`'Dusk') !>((bind (active:th (need ts)) |=(t=theme:th name.t))))
    (expect-eq !>(~) !>((active:th [list:(need ts) `'zz'])))
    %+  expect-eq  !>(`[`& %custom `'#101541'])
      !>((talon-accent:th '{"enabled":true,"mode":"Custom","customHex":"#101541"}'))
    (expect-eq !>(`[~ %profile ~]) !>((talon-accent:th '{"mode":"Profile"}')))
    (expect-eq !>(`[`| %brand ~]) !>((talon-accent:th '{"enabled":false,"mode":"Brand"}')))
    (expect-eq !>(`[~ %profile ~]) !>((talon-accent:th '{}')))
  ==
::
::  an accent's colour: only when it is on; the profile's, or its own
::
++  test-accent-color
  ;:  weld
    (expect-eq !>(~) !>((accent-color:th [~ %custom `'#101541'] ~)))
    (expect-eq !>(~) !>((accent-color:th [`| %custom `'#101541'] ~)))
    (expect-eq !>(`0x10.1541) !>((accent-color:th [`& %custom `'#101541'] ~)))
    (expect-eq !>(~) !>((accent-color:th [`& %brand `'#101541'] `0xff.5050)))
    (expect-eq !>(`0xff.5050) !>((accent-color:th [`& %profile ~] `0xff.5050)))
    (expect-eq !>(~) !>((accent-color:th [`& %profile ~] ~)))
    ::  a %contacts colour, typed (@ux) or bare
    %+  expect-eq  !>(`0xff.5050)
      !>((profile-color:th (need (de:json:html '{"color":{"type":"tint","value":"0xff.5050"}}'))))
    (expect-eq !>(`0xff.5050) !>((profile-color:th (need (de:json:html '{"color":"#ff5050"}')))))
    (expect-eq !>(~) !>((profile-color:th (need (de:json:html '{"nickname":"x"}')))))
  ==
--
