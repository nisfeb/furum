::  lib/furum-theme: furum's look, as talon draws its own.
::
::  A theme is five colours a person picks (primary, secondary, tertiary,
::  background, surface) and whether it is dark; every other colour a
::  page uses is derived from them by talon's rules (its
::  ui/theme/CustomTheme.kt), so a theme made in talon reads the same
::  here. An accent, when on, repaints the primary colour. The built-in
::  theme is furum's own, light and dark. A page asks for its colours by
::  role, as CSS variables; +draw writes them.
::
::  ponytail: talon blends colours in Oklab (Compose's lerp), this in
::  sRGB, so a derived shade can differ from talon's by a little; the
::  picked colours, and which text colour sits on each, are the same.
::  Oklab needs a cube root, which @rd lacks.
::
|%
::  a theme as talon keeps it: colours as "#RRGGBB"
+$  theme
  $:  id=@t
      name=@t
      dark=?
      primary=@t
      secondary=@t
      tertiary=@t
      background=@t
      surface=@t
  ==
::  the saved themes, and the one in use (~: the built-in)
+$  themes  [list=(list theme) active=(unit @t)]
::  an accent, as talon keeps it: on (unset reads as off), and where its
::  colour comes from
+$  accent  [on=(unit ?) how=?(%brand %profile %custom) hex=(unit @t)]
::  light, dark, or as the device is set
+$  mode  ?(%system %light %dark)
::  a page's colours, by role (a CSS variable each)
+$  scheme  (list [role=@t rgb=@ux])
::  what a page draws with: its CSS, and the colour the browser bar takes,
::  for each media query it applies under ('' for all)
+$  look  [style=@t bars=(list [media=@t hex=@t])]
::
::  ==  colours
::
::  +parse: "#RRGGBB" (or without the #, any case) as 0xRRGGBB
++  parse
  |=  t=@t
  ^-  (unit @ux)
  =/  s=tape  (cass (trip t))
  =?  s  ?=([%'#' *] s)  t.s
  ?.  =(6 (lent s))  ~
  (rush (crip s) hex)
::
++  hexa
  |=  c=@ux
  ^-  @t
  (crip ['#' ((x-co:co 6) c)])
::
++  red  |=(c=@ux (cut 3 [2 1] c))
++  grn  |=(c=@ux (cut 3 [1 1] c))
++  blu  |=(c=@ux (cut 3 [0 1] c))
++  rgb  |=([r=@ g=@ b=@] ^-(@ux (con (lsh [3 2] r) (con (lsh [3 1] g) b))))
::
::  +mix: a to b by t thousandths, per channel, rounded
++  mix
  |=  [a=@ux b=@ux t=@ud]
  ^-  @ux
  =/  one
    |=  [x=@ y=@]
    (div (add (add (mul x (sub 1.000 t)) (mul y t)) 500) 1.000)
  (rgb (one (red a) (red b)) (one (grn a) (grn b)) (one (blu a) (blu b)))
::
::  +lum: relative luminance in ten-thousandths, as Compose's
::  Color.luminance: linear light (sRGB's curve, +lin) weighted
++  lum
  |=  c=@ux
  ^-  @ud
  %+  div
    :(add (mul 2.126 (lin (red c))) (mul 7.152 (lin (grn c))) (mul 722 (lin (blu c))))
  10.000
::
::  +lin: an sRGB channel as linear light, in ten-thousandths (the
::  standard curve, tabulated: @rd has no power)
++  lin
  |=  v=@
  ^-  @ud
  %+  snag  v
  ^-  (list @ud)
  :~  0  3  6  9  12  15  18  21  24  27  30  33  37  40  44  48
    52  56  60  65  70  75  80  86  91  97  103  110  116  123  130  137
    144  152  160  168  176  185  194  203  212  222  232  242  252  262  273  284
    296  307  319  331  343  356  369  382  395  409  423  437  452  467  482  497
    513  529  545  561  578  595  612  630  648  666  685  704  723  742  762  782
    802  823  844  865  887  908  931  953  976  999  1.022  1.046  1.070  1.095  1.119  1.144
    1.170  1.195  1.221  1.248  1.274  1.301  1.329  1.356  1.384  1.413  1.441  1.470  1.500  1.529  1.559  1.590
    1.620  1.651  1.683  1.714  1.746  1.779  1.812  1.845  1.878  1.912  1.946  1.981  2.016  2.051  2.086  2.122
    2.159  2.195  2.232  2.270  2.307  2.346  2.384  2.423  2.462  2.502  2.542  2.582  2.623  2.664  2.705  2.747
    2.789  2.831  2.874  2.918  2.961  3.005  3.050  3.095  3.140  3.185  3.231  3.278  3.325  3.372  3.419  3.467
    3.515  3.564  3.613  3.663  3.712  3.763  3.813  3.864  3.916  3.968  4.020  4.072  4.125  4.179  4.233  4.287
    4.342  4.397  4.452  4.508  4.564  4.621  4.678  4.735  4.793  4.851  4.910  4.969  5.029  5.089  5.149  5.210
    5.271  5.333  5.395  5.457  5.520  5.583  5.647  5.711  5.776  5.841  5.906  5.972  6.038  6.105  6.172  6.240
    6.308  6.376  6.445  6.514  6.584  6.654  6.724  6.795  6.867  6.939  7.011  7.084  7.157  7.231  7.305  7.379
    7.454  7.529  7.605  7.682  7.758  7.835  7.913  7.991  8.070  8.148  8.228  8.308  8.388  8.469  8.550  8.632
    8.714  8.796  8.879  8.963  9.047  9.131  9.216  9.301  9.387  9.473  9.560  9.647  9.734  9.823  9.911  10.000
  ==
::
++  ink    0x1c.1917
++  paper  0xfa.faf9
++  white  0xff.ffff
++  black  0x0
::
::  ==  schemes
::
::  furum's own colours, light and dark: the pages as they have always
::  looked
++  built-in
  |=  dark=?
  ^-  scheme
  ?.  dark
    :~  ['bg' 0xf0.eee8]  ['text' 0x1a.1a2e]  ['title' 0x1a.1a2e]
        ['surface' 0xf6.f0e8]  ['on-surface' 0x1a.1a2e]
        ['muted' 0x5a.7a8a]  ['faint' 0x8a.8a9a]  ['visited' 0x6a.6a7a]
        ['line' 0xd0.ccc4]  ['line-strong' 0xdd.dddd]
        ['input' 0xff.ffff]  ['tab' 0xf5.f5f5]  ['tab-on' 0xff.ffff]
        ['primary' 0xcc.2020]  ['on-primary' 0xff.ffff]  ['primary-hover' 0xa0.1818]
        ['link' 0x8b.1a1a]  ['side-link' 0xcc.2020]  ['tertiary' 0xcc.8020]
        ['pin' 0xf5.f0e0]  ['note' 0xfd.f5e6]  ['on-note' 0x1a.1a2e]  ['wallet' 0xf0.f9ff]
        ['hd' 0xcc.2020]  ['hd-text' 0xff.ffff]  ['hd-nav' 0xff.dede]
    ==
  :~  ['bg' 0xa.0a14]  ['text' 0xb8.b8c8]  ['title' 0xd0.d0dd]
      ['surface' 0x1a.1e28]  ['on-surface' 0xb8.b8c8]
      ['muted' 0x4a.6a7a]  ['faint' 0x4a.4a5a]  ['visited' 0x55.5568]
      ['line' 0x1e.2838]  ['line-strong' 0x2a.3040]
      ['input' 0x14.1428]  ['tab' 0x2a.2a2a]  ['tab-on' 0x1a.1a1a]
      ['primary' 0xcc.2020]  ['on-primary' 0xff.ffff]  ['primary-hover' 0xa0.1818]
      ['link' 0x5a.8a9a]  ['side-link' 0xf0.8080]  ['tertiary' 0xcc.8020]
      ['pin' 0x14.140a]  ['note' 0x1a.1808]  ['on-note' 0xff.eeba]  ['wallet' 0x1a.2a3a]
      ['hd' 0x1a.0808]  ['hd-text' 0xcc.2020]  ['hd-nav' 0x8a.6a6a]
  ==
::
++  role
  |=  [s=scheme r=@t]
  ^-  @ux
  (fall (bind (find ~[r] (turn s head)) |=(i=@ud rgb:(snag i s))) 0x0)
::
++  put
  |=  [s=scheme r=@t c=@ux]
  ^-  scheme
  (turn s |=([k=@t v=@ux] ?:(=(k r) [k c] [k v])))
::
::  +custom: a theme's whole scheme from its five colours, by talon's
::  rules: the text on a colour is ink or paper by its luminance;
::  containers blend toward the background (dark) or white; the rest
::  of the surface ramp blends toward the text
++  custom
  |=  t=theme
  ^-  scheme
  =/  base  (built-in dark.t)
  =/  pick  |=([h=@t r=@t] (fall (parse h) (role base r)))
  =/  p  (pick primary.t 'primary')
  =/  s  (pick secondary.t 'link')
  =/  e  (pick tertiary.t 'tertiary')
  =/  b  (pick background.t 'bg')
  =/  u  (pick surface.t 'surface')
  =/  on  |=(c=@ux ?:((gth (lum c) 4.000) ink paper))
  =/  toward  ?:(dark.t white black)
  =/  box  |=(c=@ux ?:(dark.t (mix c b 600) (mix c white 800)))
  =/  on-box  |=(c=@ux ?:(dark.t (mix c white 750) (mix c black 650)))
  =/  on-s  (on u)
  =/  on-b  (on b)
  =/  hd  ?:(dark.t u p)
  =/  hd-text  ?:(dark.t p (on p))
  :~  ['bg' b]  ['text' on-b]  ['title' on-b]
      ['surface' u]  ['on-surface' on-s]
      ['muted' (mix on-s u 350)]  ['faint' (mix on-s u 550)]  ['visited' (mix on-s u 350)]
      ['line' (mix u on-s 150)]  ['line-strong' (mix u on-s 400)]
      ['input' ?:(dark.t (mix u black 300) white)]  ['tab' (mix u toward 60)]  ['tab-on' u]
      ['primary' p]  ['on-primary' (on p)]  ['primary-hover' (mix p toward 150)]
      ['link' s]  ['side-link' p]  ['tertiary' e]
      ['pin' (box p)]  ['note' (box e)]  ['on-note' (on-box e)]  ['wallet' (box s)]
      ['hd' hd]  ['hd-text' hd-text]  ['hd-nav' (mix hd-text hd 250)]
  ==
::
::  +tint: an accent over a scheme, as talon lays one: the primary
::  colour and its text (ink or white, by luminance), and whatever
::  else was drawn in the primary colour; containers keep theirs
++  tint
  |=  [s=scheme a=@ux dark=?]
  ^-  scheme
  =/  old  (role s 'primary')
  =/  on-a  ?:((gth (lum a) 5.000) ink white)
  =.  s  (put (put s 'primary' a) 'on-primary' on-a)
  =.  s  (put s 'primary-hover' (mix a ?:(dark white black) 150))
  =?  s  =(old (role s 'side-link'))  (put s 'side-link' a)
  ?:  =(old (role s 'hd'))
    =.  s  (put (put s 'hd' a) 'hd-text' on-a)
    (put s 'hd-nav' (mix on-a a 250))
  ?.  =(old (role s 'hd-text'))  s
  =.  s  (put s 'hd-text' a)
  (put s 'hd-nav' (mix a (role s 'hd') 250))
::
::  ==  pages
::
++  vars
  |=  s=scheme
  ^-  tape
  %-  zing
  (turn s |=([r=@t c=@ux] "--{(trip r)}:{(trip (hexa c))};"))
::
::  +draw: what a page draws with. A theme brings its own light or dark;
::  the built-in one follows the mode, and as the device is set, both,
::  under a media query.
++  draw
  |=  [=mode active=(unit theme) accent=(unit @ux)]
  ^-  look
  =/  paint
    |=  [s=scheme dark=?]
    ?~(accent s (tint s u.accent dark))
  =/  one
    |=  [s=scheme dark=?]
    ^-  look
    =/  s  (paint s dark)
    :-  (crip ":root\{color-scheme:{?:(dark "dark" "light")};{(vars s)}}")
    ~[['' (hexa (role s 'hd'))]]
  ?^  active  (one (custom u.active) dark.u.active)
  ?-  mode
    %light  (one (built-in |) |)
    %dark   (one (built-in &) &)
      %system
    =/  l  (paint (built-in |) |)
    =/  d  (paint (built-in &) &)
    :_  :~  ['(prefers-color-scheme: light)' (hexa (role l 'hd'))]
            ['(prefers-color-scheme: dark)' (hexa (role d 'hd'))]
        ==
    %-  crip
    ;:  weld
      ":root\{color-scheme:light dark;{(vars l)}}"
      "@media (prefers-color-scheme: dark)\{:root\{{(vars d)}}}"
    ==
  ==
::
::  ==  talon's settings, as its %settings entries hold them (JSON text)
::
::  +talon-themes: the `themes` entry: saved themes and the active one;
::  a theme that won't read is left out
++  talon-themes
  |=  txt=@t
  ^-  (unit themes)
  ?~  jon=(de:json:html txt)  ~
  ?.  ?=([%o *] u.jon)  ~
  =/  o  p.u.jon
  =/  str  |=([m=(map @t json) k=@t] =/(v (~(get by m) k) ?.(?=([~ %s *] v) ~ `p.u.v)))
  =/  ts=(list json)
    =/  v  (~(get by o) 'themes')
    ?.(?=([~ %a *] v) ~ p.u.v)
  :+  ~
    %+  murn  ts
    |=  j=json
    ^-  (unit theme)
    ?.  ?=([%o *] j)  ~
    =/  m  p.j
    =/  f  |=(k=@t (str m k))
    =/  d  (~(get by m) 'dark')
    ?.  ?=([~ %b *] d)  ~
    =/  got  (turn ~['id' 'name' 'primary' 'secondary' 'tertiary' 'background' 'surface'] f)
    ?.  (levy got |=(u=(unit @t) ?=(^ u)))  ~
    =/  v  (turn got |=(u=(unit @t) (need u)))
    `[(snag 0 v) (snag 1 v) p.u.d (snag 2 v) (snag 3 v) (snag 4 v) (snag 5 v) (snag 6 v)]
  (str o 'activeId')
::
::  +talon-accent: the `accent` entry
++  talon-accent
  |=  txt=@t
  ^-  (unit accent)
  ?~  jon=(de:json:html txt)  ~
  ?.  ?=([%o *] u.jon)  ~
  =/  o  p.u.jon
  =/  on  (~(get by o) 'enabled')
  =/  how  (~(get by o) 'mode')
  =/  h  (~(get by o) 'customHex')
  :-  ~
  :+  ?.(?=([~ %b *] on) ~ `p.u.on)
    ?+  how  %profile
      [~ %s %'Brand']   %brand
      [~ %s %'Custom']  %custom
    ==
  ?.(?=([~ %s *] h) ~ `p.u.h)
::
::  +profile-color: the colour on a %contacts profile (contacts' v1 JSON):
::  a typed field ({type, value}) or a bare string, as @ux ("0xff.5050")
::  or "#ff5050"
++  profile-color
  |=  jon=json
  ^-  (unit @ux)
  ?.  ?=([%o *] jon)  ~
  =/  c  (~(get by p.jon) 'color')
  =/  txt=(unit @t)
    ?:  ?=([~ %s *] c)  `p.u.c
    ?.  ?=([~ %o *] c)  ~
    =/  v  (~(get by p.u.c) 'value')
    ?.(?=([~ %s *] v) ~ `p.u.v)
  ?~  txt  ~
  ?^  x=(slaw %ux u.txt)  x
  (parse u.txt)
::
::  +accent-color: an accent's colour, when it is on and has one
++  accent-color
  |=  [a=accent profile=(unit @ux)]
  ^-  (unit @ux)
  ?.  =(`& on.a)  ~
  ?-  how.a
    %brand    ~
    %profile  profile
    %custom   ?~(hex.a ~ (parse u.hex.a))
  ==
::
::  +active: the theme in use, when the one named is saved
++  active
  |=  t=themes
  ^-  (unit theme)
  ?~  active.t  ~
  =/  hit  (skim list.t |=(h=theme =(id.h u.active.t)))
  ?~(hit ~ `i.hit)
--
