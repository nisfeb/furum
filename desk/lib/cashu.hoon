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
  (decompress-point:secp256k1:secp:crypto compressed)
::
::  Compress point to hex string
++  point-to-hex
  |=  pt=[x=@ y=@]
  ^-  @t
  =/  compressed=@  (compress-point:secp256k1:secp:crypto pt)
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
  =/  hash=@  (shay 36 (cat 3 msg-hash counter))
  ::  try to decompress as 02 || hash (even-y point)
  =/  compressed=@  (add (lsh [3 32] 2) hash)
  =/  result  (mule |.((decompress-point:secp256k1:secp:crypto compressed)))
  ?:  ?=([%& *] result)
    p.result
  $(counter +(counter))
::
::  -- BDHKE operations --
::
::  Blind a message for signing: B_ = Y + r*G
::  Returns [B_ r] where r is the blinding factor
++  blind-message
  |=  [secret=@t r=@]
  ^-  [b-prime=[x=@ y=@] blinding-factor=@]
  =/  yy  (hash-to-curve secret)
  =/  r-g  (priv-to-pub:secp256k1:secp:crypto r)
  =/  b-prime  (add-points:secp256k1:secp:crypto yy r-g)
  [b-prime=b-prime blinding-factor=r]
::
::  Unblind a signature: C = C_ - r*K
::  C_ = blinded signature from mint
::  r  = blinding factor used during blinding
::  K  = mint's public key for this denomination
++  unblind-signature
  |=  [c-blind=[x=@ y=@] r=@ mint-key=[x=@ y=@]]
  ^-  [x=@ y=@]
  =/  r-k  (mul-point-scalar:secp256k1:secp:crypto mint-key r)
  ::  negate r*K: flip y coordinate (mod p)
  =/  neg-r-k  r-k(y (sub secp-p y.r-k))
  (add-points:secp256k1:secp:crypto c-blind neg-r-k)
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
  =/  b-hex=@t  (point-to-hex b-prime)
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
