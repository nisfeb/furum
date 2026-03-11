::  lib/cashu.hoon: Cashu wallet operations (NUT-00/NUT-03/NUT-05)
::
::  Standard-compliant BDHKE using zuse's jetted secp256k1 operations.
::  Implements hash-to-curve, blinding, unblinding per NUT-00 spec.
::
|%
::  secp256k1 field prime
++  secp-p
  0xffff.ffff.ffff.ffff.ffff.ffff.ffff.ffff.
  ffff.ffff.ffff.ffff.ffff.fffe.ffff.fc2f
::  secp256k1 curve order
++  secp-n
  0xffff.ffff.ffff.ffff.ffff.ffff.ffff.fffe.
  baae.dce6.af48.a03b.bfd2.5e8c.d036.4141
::  secp256k1 generator point
++  secp-g
  ^-  [x=@ y=@]
  :*  x=0x79be.667e.f9dc.bbac.55a0.6295.ce87.0b07.
        029b.fcdb.2dce.28d9.59f2.815b.16f8.1798
      y=0x483a.da77.26a3.c465.5da4.fbfc.0e11.08a8.
        fd17.b448.a685.5419.9c47.d08f.fb10.d4b8
  ==
::
::  -- Hex helpers --
::
++  hex-to-bytes
  |=  hex=@t
  ^-  @
  %+  roll  (trip hex)
  |=  [c=@ acc=@]
  =/  nib
    ?:  &((gte c '0') (lte c '9'))  (sub c '0')
    ?:  &((gte c 'a') (lte c 'f'))  (add 10 (sub c 'a'))
    ?:  &((gte c 'A') (lte c 'F'))  (add 10 (sub c 'A'))
    ~|(%bad-hex-char !!)
  (add (mul acc 16) nib)
::
++  bytes-to-hex
  |=  [val=@ width=@ud]
  ^-  @t
  =/  hex-chars=tape  "0123456789abcdef"
  =/  out=tape
    =/  idx=@ud  0
    =/  acc=tape  ~
    |-  ^-  tape
    ?:  =(idx width)  acc
    =/  byte  (cut 3 [(sub (dec width) idx) 1] val)
    =/  hi  (snag (div byte 16) hex-chars)
    =/  lo  (snag (mod byte 16) hex-chars)
    $(idx +(idx), acc (snoc (snoc acc hi) lo))
  (crip out)
::
::  -- Point decompression (pure Hoon, replaces zuse) --
::
::  Decompress a 33-byte compressed secp256k1 point to affine [x y]
++  ec-decompress
  |=  compressed=@
  ^-  [x=@ y=@]
  =/  prefix=@  (cut 3 [32 1] compressed)
  ?>  |(=(2 prefix) =(3 prefix))
  =/  x=@  (end [3 32] compressed)
  =/  fop  ~(. fo secp-p)
  =/  x3  (pro:fop x (pro:fop x x))
  =/  y2  (sum:fop x3 7)
  ::  y = y2^((p+1)/4) mod p  (works since p ≡ 3 mod 4)
  =/  y=@  (~(exp fo secp-p) (div (add secp-p 1) 4) y2)
  ::  verify y^2 == y2
  ?>  =((pro:fop y y) y2)
  ::  adjust parity to match prefix
  =/  need-odd=?  =(3 prefix)
  =?  y  !=(=(1 (mod y 2)) need-odd)
    (sub secp-p y)
  [x y]
::
::  -- Point serialization --
::
::  Parse compressed hex point ("02abc..." / "03abc...", 66 chars) to point
++  hex-to-point
  |=  hex=@t
  ^-  [x=@ y=@]
  =/  chars=tape  (trip hex)
  ?>  =(66 (lent chars))
  =/  prefix=@t  (crip (scag 2 chars))
  ?>  |(=(prefix '02') =(prefix '03'))
  =/  compressed=@  (hex-to-bytes hex)
  (ec-decompress compressed)
::
::  Compress point to hex string
++  point-to-hex
  |=  pt=[x=@ y=@]
  ^-  @t
  ::  manual compression: 02 if y even, 03 if y odd, then x big-endian
  =/  prefix=@  ?:(=(0 (mod y.pt 2)) 2 3)
  =/  compressed=@  (add (lsh [3 32] prefix) x.pt)
  (bytes-to-hex compressed 33)
::
::  -- Hash-to-curve (NUT-00 spec) --
::
::  Domain separator per Cashu NUT-00
++  domain-separator  'Secp256k1_HashToCurve_Cashu_'
::
++  hash-to-curve
  |=  message=@
  ^-  [x=@ y=@]
  =/  domain=@  domain-separator
  =/  domain-len=@ud  (met 3 domain)
  =/  msg-len=@ud  (met 3 message)
  =/  msg-hash=@  (shay (add domain-len msg-len) (cat 3 domain message))
  =/  counter=@ud  0
  |-
  ?>  (lth counter 65.536)
  ::  SHA-256(msg_hash || counter_le32)
  ::  counter as 4-byte LE is just the atom value; shay reads 36 bytes
  =/  hash=@  (rev 3 32 (shay 36 (cat 3 msg-hash counter)))
  ::  try to decompress as 02 || hash (even-y point)
  =/  compressed=@  (add (lsh [3 32] 2) hash)
  =/  result  (mule |.((ec-decompress compressed)))
  ?:  ?=([%& *] result)
    p.result
  $(counter +(counter))
::
::  -- Elliptic curve point addition (affine, secp256k1) --
::
::  Uses Hoon stdlib fo core for modular field arithmetic.
::  Replaces zuse add-points which produces invalid results.
::
++  ec-add
  |=  [p1=[x=@ y=@] p2=[x=@ y=@]]
  ^-  [x=@ y=@]
  =/  fop  ~(. fo secp-p)
  ?:  &(=(x.p1 x.p2) =(y.p1 y.p2))
    ::  point doubling: lam = 3*x1^2 / (2*y1)
    =/  lam  (fra:fop (pro:fop 3 (pro:fop x.p1 x.p1)) (pro:fop 2 y.p1))
    =/  x3  (dif:fop (dif:fop (pro:fop lam lam) x.p1) x.p2)
    =/  y3  (dif:fop (pro:fop lam (dif:fop x.p1 x3)) y.p1)
    [x3 y3]
  ::  point addition: lam = (y2 - y1) / (x2 - x1)
  =/  lam  (fra:fop (dif:fop y.p2 y.p1) (dif:fop x.p2 x.p1))
  =/  x3  (dif:fop (dif:fop (pro:fop lam lam) x.p1) x.p2)
  =/  y3  (dif:fop (pro:fop lam (dif:fop x.p1 x3)) y.p1)
  [x3 y3]
::
::  Scalar multiplication via double-and-add
::
++  ec-mul
  |=  [pt=[x=@ y=@] k=@]
  ^-  [x=@ y=@]
  =/  res=[x=@ y=@]  pt
  =/  acc=[x=@ y=@]  pt
  =/  first=?  &
  =/  bits=@ud  (met 0 k)
  =/  idx=@ud  0
  |-
  ?:  =(idx bits)  res
  ?:  =(1 (cut 0 [idx 1] k))
    ?:  first
      $(idx +(idx), res acc, acc (ec-add acc acc), first |)
    $(idx +(idx), res (ec-add res acc), acc (ec-add acc acc))
  $(idx +(idx), acc (ec-add acc acc))
::
::  -- BDHKE operations --
::
::  Blind a message for signing: B_ = Y + r*G
::  Returns [B_ r] where r is the blinding factor
++  blind-message
  |=  [secret=@t r=@]
  ^-  [b-prime=[x=@ y=@] blinding-factor=@]
  ::  reduce r modulo curve order to ensure valid scalar
  =/  r-mod=@  (mod r secp-n)
  =?  r-mod  =(0 r-mod)  1
  =/  yy  (hash-to-curve secret)
  =/  r-g  (ec-mul secp-g r-mod)
  =/  b-prime  (ec-add yy r-g)
  [b-prime=b-prime blinding-factor=r-mod]
::
::  Unblind a signature: C = C_ - r*K
::  C_ = blinded signature from mint
::  r  = blinding factor used during blinding
::  K  = mint's public key for this denomination
++  unblind-signature
  |=  [c-blind=[x=@ y=@] r=@ mint-key=[x=@ y=@]]
  ^-  [x=@ y=@]
  =/  r-k  (ec-mul mint-key r)
  ::  negate r*K: flip y coordinate (mod p)
  =/  neg-r-k  r-k(y (sub secp-p y.r-k))
  =/  result  (ec-add c-blind neg-r-k)
  result
::
::  -- NUT-03 swap request/response builders --
::
::  Build a single blinded output for swap
::  Returns [B_hex secret blinding-factor]
++  make-output
  |=  [amount=@ud keyset-id=@t eny=@]
  ^-  [b-hex=@t secret=@t blinding-factor=@]
  ::  generate random secret (32 bytes hex)
  =/  secret=@t  (bytes-to-hex (shax eny) 32)
  ::  use hash of eny as blinding factor (ensure non-zero, < curve order)
  =/  r=@  (shax (cat 3 eny 'blind'))
  =/  [b-prime=[x=@ y=@] blinding-factor=@]  (blind-message secret r)
  ::  verify the point is valid by round-trip: compress then decompress
  =/  b-hex=@t  (point-to-hex b-prime)
  =/  check  (mule |.((hex-to-point b-hex)))
  ?.  ?=([%& *] check)
    ::  point invalid, retry with different entropy
    $(eny (shax (cat 3 eny 'retry')))
  [b-hex secret blinding-factor]
::
::  Build swap request JSON from user proofs and generated outputs
++  build-swap-request
  |=  [inputs=json outputs=(list [amount=@ud id=@t b-hex=@t])]
  ^-  json
  %-  pairs:enjs:format
  :~  ['inputs' inputs]
      :-  'outputs'
      :-  %a
      %+  turn  outputs
      |=  [amount=@ud id=@t b-hex=@t]
      %-  pairs:enjs:format
      :~  ['amount' (numb:enjs:format amount)]
          ['id' s+id]
          ['B_' s+b-hex]
      ==
  ==
::
::  Parse swap response: extract blinded signatures
++  parse-swap-response
  |=  jon=json
  ^-  (list [amount=@ud id=@t c-hex=@t])
  ?.  ?=([%o *] jon)  ~
  =/  sigs  (~(get by p.jon) 'signatures')
  ?~  sigs  ~
  ?.  ?=([%a *] u.sigs)  ~
  %+  turn  p.u.sigs
  |=  sig=json
  ^-  [amount=@ud id=@t c-hex=@t]
  ?.  ?=([%o *] sig)  [0 '' '']
  =/  amt=json  (~(gut by p.sig) 'amount' [%n '0'])
  =/  kid=json  (~(gut by p.sig) 'id' [%s ''])
  =/  c-val=json  (~(gut by p.sig) 'C_' [%s ''])
  =/  amount=@ud
    ?.  ?=([%n *] amt)  0
    (roll (trip p.amt) |=([c=@ a=@ud] (add (mul a 10) (sub c '0'))))
  =/  keyset-id=@t
    ?.  ?=([%s *] kid)  ''
    p.kid
  =/  c-hex=@t
    ?.  ?=([%s *] c-val)  ''
    p.c-val
  [amount keyset-id c-hex]
::
::  Unblind all signatures and produce final proofs
++  finalize-proofs
  |=  $:  sigs=(list [amount=@ud id=@t c-hex=@t])
          secrets=(list @t)
          blinding-factors=(list @)
          mint-keys=(map @ud [x=@ y=@])
      ==
  ^-  (list [amount=@ud id=@t secret=@t c=@t])
  =/  idx=@ud  0
  =/  acc=(list [amount=@ud id=@t secret=@t c=@t])  ~
  |-
  ?:  |((gte idx (lent sigs)) (gte idx (lent secrets)))
    (flop acc)
  =/  [amt=@ud kid=@t c-hex=@t]  (snag idx sigs)
  =/  secret=@t  (snag idx secrets)
  =/  r=@  (snag idx blinding-factors)
  =/  mint-key  (~(get by mint-keys) amt)
  ?~  mint-key
    $(idx +(idx))
  =/  c-blind  (hex-to-point c-hex)
  =/  c-unblind  (unblind-signature c-blind r u.mint-key)
  =/  c-final=@t  (point-to-hex c-unblind)
  $(idx +(idx), acc [[amt kid secret c-final] acc])
::
::  -- NUT-05 melt (Lightning withdrawal) --
::
::  Build melt quote request
++  build-melt-quote-request
  |=  [invoice=@t unit=@t]
  ^-  json
  %-  pairs:enjs:format
  :~  ['request' s+invoice]
      ['unit' s+unit]
  ==
::
::  Parse melt quote response
++  parse-melt-quote
  |=  jon=json
  ^-  (unit [quote=@t amount=@ud fee-reserve=@ud])
  ?.  ?=([%o *] jon)  ~
  =/  q  (~(get by p.jon) 'quote')
  =/  a  (~(get by p.jon) 'amount')
  =/  f  (~(get by p.jon) 'fee_reserve')
  ?~  q  ~
  ?~  a  ~
  ?~  f  ~
  :-  ~
  :+  ?:(?=([%s *] u.q) p.u.q '')
    ?:(?=([%n *] u.a) (roll (trip p.u.a) |=([c=@ a=@ud] (add (mul a 10) (sub c '0')))) 0)
  ?:(?=([%n *] u.f) (roll (trip p.u.f) |=([c=@ a=@ud] (add (mul a 10) (sub c '0')))) 0)
::
::  Build melt execution request from stored proofs
++  build-melt-request
  |=  [quote-id=@t proofs=(list [amount=@ud id=@t secret=@t c=@t])]
  ^-  json
  %-  pairs:enjs:format
  :~  ['quote' s+quote-id]
      :-  'inputs'
      :-  %a
      %+  turn  proofs
      |=  [amount=@ud id=@t secret=@t c=@t]
      %-  pairs:enjs:format
      :~  ['amount' (numb:enjs:format amount)]
          ['id' s+id]
          ['secret' s+secret]
          ['C' s+c]
      ==
  ==
::
::  Parse melt response
++  parse-melt-response
  |=  jon=json
  ^-  (unit [state=@t paid=?])
  ?.  ?=([%o *] jon)  ~
  =/  st  (~(get by p.jon) 'state')
  ?~  st  ~
  =/  state=@t  ?:(?=([%s *] u.st) p.u.st '')
  `[state =(state 'PAID')]
::
::  -- NUT-04 mint (Lightning invoice) --
::
::  Build mint quote request
++  build-mint-quote-request
  |=  [amount=@ud unit=@t]
  ^-  json
  %-  pairs:enjs:format
  :~  ['amount' (numb:enjs:format amount)]
      ['unit' s+unit]
  ==
::
::  Parse mint quote response
++  parse-mint-quote
  |=  jon=json
  ^-  (unit [quote=@t request=@t state=@t expiry=@ud])
  ?.  ?=([%o *] jon)  ~
  =/  q  (~(get by p.jon) 'quote')
  =/  r  (~(get by p.jon) 'request')
  =/  s  (~(get by p.jon) 'state')
  =/  e  (~(get by p.jon) 'expiry')
  ?~  q  ~
  ?~  r  ~
  ?~  s  ~
  ?~  e  ~
  :-  ~
  :^    ?:(?=([%s *] u.q) p.u.q '')
      ?:(?=([%s *] u.r) p.u.r '')
    ?:(?=([%s *] u.s) p.u.s '')
  ?:(?=([%n *] u.e) (roll (trip p.u.e) |=([c=@ a=@ud] (add (mul a 10) (sub c '0')))) 0)
::
::  Build mint token request (NUT-04 step 2)
++  build-mint-request
  |=  [quote-id=@t outputs=(list [amount=@ud id=@t b-hex=@t])]
  ^-  json
  %-  pairs:enjs:format
  :~  ['quote' s+quote-id]
      :-  'outputs'
      :-  %a
      %+  turn  outputs
      |=  [amount=@ud id=@t b-hex=@t]
      %-  pairs:enjs:format
      :~  ['amount' (numb:enjs:format amount)]
          ['id' s+id]
          ['B_' s+b-hex]
      ==
  ==
::
::  -- Keyset parsing --
::
::  Parse mint keyset response: {keys: {amount_str: hex_pubkey, ...}}
++  parse-keyset
  |=  jon=json
  ^-  (map @ud [x=@ y=@])
  ?.  ?=([%o *] jon)  *(map @ud [x=@ y=@])
  =/  keys-val  (~(get by p.jon) 'keys')
  ?~  keys-val  *(map @ud [x=@ y=@])
  ?.  ?=([%o *] u.keys-val)  *(map @ud [x=@ y=@])
  %-  ~(rep by p.u.keys-val)
  |=  [[amt-key=@t hex-val=json] acc=(map @ud [x=@ y=@])]
  ?.  ?=([%s *] hex-val)  acc
  =/  amt=@ud  (roll (trip amt-key) |=([c=@ a=@ud] (add (mul a 10) (sub c '0'))))
  ?:  =(0 amt)  acc
  =/  pt-result  (mule |.((hex-to-point p.hex-val)))
  ?.  ?=([%& *] pt-result)  acc
  (~(put by acc) amt p.pt-result)
::
::  -- Amount splitting --
::
::  Split amount into powers of 2 (standard Cashu denomination)
++  split-amount
  |=  total=@ud
  ^-  (list @ud)
  ?:  =(0 total)  ~
  =/  acc=(list @ud)  ~
  =/  bit=@ud  0
  |-
  ?:  (gte (bex bit) (mul 2 total))
    acc
  ?:  =((mod (div total (bex bit)) 2) 1)
    $(bit +(bit), acc [(bex bit) acc])
  $(bit +(bit))
::
::  -- URL helpers --
::
++  clean-mint-url
  |=  mint=@t
  ^-  tape
  =/  clean=tape  (trip mint)
  =/  rev  (flop clean)
  =?  clean  ?=([%'/' *] rev)
    (snip clean)
  clean
--
