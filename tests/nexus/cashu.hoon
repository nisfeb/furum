::  tests for lib/cashu: the ecash protocol a mint must agree with, checked
::  against the NUT specs' own vectors and field names
::
/+  *test, ca=cashu
|%
++  j  |=(t=@t (need (de:json:html t)))
::
::  our secrets map to the curve points a mint computes (NUT-00 vectors 2
::  and 3; vector 1's all-zero message is no atom). a mismatch fails every
::  payment, and a byte-order bug once did
::
++  test-hash-to-curve
  ;:  weld
    %+  expect-eq
      !>('022e7158e11c9506f1aa4248bf531298daa7febd6194f003edcd9b93ade6253acf')
      !>((point-to-hex:ca (hash-to-curve:ca (lsh [3 31] 1))))
    %+  expect-eq
      !>('026cdbe15362df59cd1dd3c9c11de8aedac2106eca69236ecd9fbe117af897be4f')
      !>((point-to-hex:ca (hash-to-curve:ca (lsh [3 31] 2))))
  ==
::
::  a blinded message is NUT-00's for the same secret and blinding factor
::
++  test-blind-message
  =/  blind
    |=  [x=@ r=@]
    (point-to-hex:ca b-prime:(blind-message:ca `@t`(rev 3 32 x) r))
  ;:  weld
    %+  expect-eq
      !>('033b1a9737a40cc3fd9b6af4b723632b76a67a36782596304612a6c2bfb5197e6d')
      !>  %+  blind
            0xd341.ee48.71f1.f889.041e.63cf.0d38.23c7.13ee.a6af.f01e.80f1.719f.08f9.e5be.98f6
          0x99fc.e584.39fc.3741.2ab3.468b.73db.0569.3225.88f6.2fb3.a491.82d6.7e23.d877.824a
    %+  expect-eq
      !>('029bdf2d716ee366eddf599ba252786c1033f47e230248a4612a5670ab931f1763')
      !>  %+  blind
            0xf1aa.f16c.2239.746f.3695.72c0.784d.9dd3.d032.d952.c2d9.9217.5873.fb58.fae3.1a60
          0xf784.76ea.7cc9.ade2.0f9e.05e5.8a80.4cf1.9533.f03e.a805.ece5.fee8.8c8e.2874.ba50
  ==
::
::  point multiplication matches NUT-00's blinded signatures, and
::  unblinding removes exactly the blinding factor: C_ - rK = kY
::
++  test-sign-and-unblind
  =/  k  0x7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f.7f7f
  =/  b  (hex-to-point:ca '02a9acc1e48c25eeeb9289b5031cc57da9fe72f3fe2861d264bdc074209b107ba2')
  =/  x  (lsh [3 31] 1)
  =/  r  0x1234.5678.9abc
  =/  b-prime  b-prime:(blind-message:ca `@t`x r)
  ;:  weld
    %+  expect-eq
      !>('0398bc70ce8184d27ba89834d19f5199c84443c31131e48d3c1214db24247d005d')
      !>((point-to-hex:ca (ec-mul:ca b k)))
    %+  expect-eq
      !>((ec-mul:ca (hash-to-curve:ca x) k))
      !>((unblind-signature:ca (ec-mul:ca b-prime k) r (ec-mul:ca secp-g:ca k)))
  ==
::
::  a mint's hex points parse whichever parity prefix they carry (half are
::  03) and in either case, and print back as the mint wrote them
::
++  test-point-hex
  =/  odd  '0398bc70ce8184d27ba89834d19f5199c84443c31131e48d3c1214db24247d005d'
  =/  even  '02a9acc1e48c25eeeb9289b5031cc57da9fe72f3fe2861d264bdc074209b107ba2'
  ;:  weld
    (expect-eq !>(odd) !>((point-to-hex:ca (hex-to-point:ca odd))))
    (expect-eq !>(even) !>((point-to-hex:ca (hex-to-point:ca even))))
    %+  expect-eq  !>((hex-to-point:ca even))
      !>((hex-to-point:ca (crip (cuss (trip even)))))
  ==
::
::  the mint's signatures become proofs a mint will honour: each C is the
::  signature with the blinding removed (k*Y for its secret). a signature
::  whose amount has no key is skipped, and a mint answering fewer or more
::  signatures than we sent yields proofs for what matches, not a crash
::
++  test-finalize-proofs
  =/  keys  (my ~[[1 (ec-mul:ca secp-g:ca 3)] [2 (ec-mul:ca secp-g:ca 5)]])
  =/  sign
    |=  [amt=@ud k=@ secret=@t r=@]
    ^-  [sig=[@ud @t @t] r=@ proof=[@ud @t @t @t]]
    =/  bm  (blind-message:ca secret r)
    :+  [amt '00ab' (point-to-hex:ca (ec-mul:ca b-prime.bm k))]
      blinding-factor.bm
    [amt '00ab' secret (point-to-hex:ca (ec-mul:ca (hash-to-curve:ca secret) k))]
  =/  one  (sign 1 3 's1' 7)
  =/  two  (sign 2 5 's2' 11)
  =/  bad  (sign 4 9 's3' 13)
  ;:  weld
    %+  expect-eq  !>(~[proof.one proof.two])
      !>((finalize-proofs:ca ~[sig.one sig.two] ~['s1' 's2'] ~[r.one r.two] keys))
    %+  expect-eq  !>(~[proof.one])
      !>((finalize-proofs:ca ~[sig.one] ~['s1' 's2'] ~[r.one r.two] keys))
    %+  expect-eq  !>(~[proof.one])
      !>((finalize-proofs:ca ~[sig.one sig.two] ~['s1'] ~[r.one] keys))
    %+  expect-eq  !>(~[proof.two])
      !>((finalize-proofs:ca ~[sig.bad sig.two] ~['s3' 's2'] ~[r.bad r.two] keys))
  ==
::
::  amounts split into distinct powers of two summing to the total: the
::  only denominations a mint signs
::
++  test-split-amount
  =/  split  |=(n=@ud (sort (split-amount:ca n) lth))
  ;:  weld
    (expect-eq !>(~) !>((split 0)))
    (expect-eq !>(~[1]) !>((split 1)))
    (expect-eq !>(~[1 4 8]) !>((split 13)))
    (expect-eq !>(~[64]) !>((split 64)))
    (expect-eq !>(~[4 32 64]) !>((split 100)))
  ==
::
::  a mint's keys, under keysets or bare, parse to amount -> pubkey, the
::  big denominations too (1024 and up were once dropped, losing those
::  proofs); an empty keyset list or a key that isn't an amount is
::  skipped, not a crash
::
++  test-parse-keys
  ;:  weld
    %+  expect-eq  !>(`(my ~[[1 '02aa'] [2 '02bb']]))
      !>((parse-keys:ca (j '{"keysets":[{"id":"00ab","unit":"sat","keys":{"1":"02aa","2":"02bb"}}]}')))
    %+  expect-eq  !>(`(my ~[[4 '02cc'] [1.024 '02cd'] [1.048.576 '02ce']]))
      !>((parse-keys:ca (j '{"keys":{"4":"02cc","1024":"02cd","1048576":"02ce"}}')))
    %+  expect-eq  !>(`(my ~[[8 '02ee']]))
      !>((parse-keys:ca (j '{"keys":{"abc":"02dd","0":"02ff","8":"02ee"}}')))
    (expect-eq !>(~) !>((parse-keys:ca (j '{"keysets":[]}'))))
    (expect-eq !>(~) !>((parse-keys:ca (j '[1]'))))
  ==
::
::  a mint's answers parse by the NUT-03/04/05 field names. a quote with a
::  null expiry reads 0, which the agent takes as no expiry; one without a
::  quote id is refused
::
++  test-mint-responses
  ;:  weld
    %+  expect-eq  !>(~[[2 '009a' '02ab'] [8 '009a' '02cd']])
      !>((parse-swap-response:ca (j '{"signatures":[{"amount":2,"id":"009a","C_":"02ab"},{"amount":8,"id":"009a","C_":"02cd"}]}')))
    %+  expect-eq  !>(`['q1' 'lnbc1' 'UNPAID' 1.701.704.757])
      !>((parse-mint-quote:ca (j '{"quote":"q1","request":"lnbc1","state":"UNPAID","expiry":1701704757}')))
    %+  expect-eq  !>(`['q1' 'lnbc1' 'PAID' 0])
      !>((parse-mint-quote:ca (j '{"quote":"q1","request":"lnbc1","state":"PAID","expiry":null}')))
    (expect-eq !>(~) !>((parse-mint-quote:ca (j '{"request":"lnbc1","state":"PAID","expiry":1}'))))
    %+  expect-eq  !>(`['q2' 100 2])
      !>((parse-melt-quote:ca (j '{"quote":"q2","amount":100,"fee_reserve":2,"state":"UNPAID"}')))
    (expect-eq !>(`['PAID' %.y]) !>((parse-melt-response:ca (j '{"state":"PAID"}'))))
    (expect-eq !>(`['PENDING' %.n]) !>((parse-melt-response:ca (j '{"state":"PENDING"}'))))
  ==
::
::  what we send a mint carries the field names NUT-03/04/05 require
::
++  test-mint-requests
  =/  out  ~[[8 '009a' '02ab']]
  ;:  weld
    %+  expect-eq
      !>((j '{"inputs":[],"outputs":[{"amount":8,"id":"009a","B_":"02ab"}]}'))
      !>((build-swap-request:ca a+~ out))
    %+  expect-eq
      !>((j '{"quote":"q","outputs":[{"amount":8,"id":"009a","B_":"02ab"}]}'))
      !>((build-mint-request:ca 'q' out))
    %+  expect-eq
      !>((j '{"quote":"q","inputs":[{"amount":8,"id":"009a","secret":"s","C":"02cd"}],"outputs":[{"amount":8,"id":"009a","B_":"02ab"}]}'))
      !>((build-melt-request:ca 'q' ~[[8 '009a' 's' '02cd']] out))
    %+  expect-eq  !>((j '{"outputs":[{"amount":8,"id":"009a","B_":"02ab"}]}'))
      !>((build-restore-request:ca out))
    %+  expect-eq  !>((j '{"amount":100,"unit":"sat"}'))
      !>((build-mint-quote-request:ca 100 'sat'))
    %+  expect-eq  !>((j '{"request":"lnbc1","unit":"sat"}'))
      !>((build-melt-quote-request:ca 'lnbc1' 'sat'))
  ==
::
::  a mint's keysets (NUT-02): the active sat one signs new outputs, and
::  spending proofs costs their keysets' fees per thousand, rounded up,
::  whether a proof names its keyset in full or by a short id
::
++  test-keysets-and-fees
  =/  ks
    %-  parse-keysets:ca
    %-  j
    '''
    {"keysets":[{"id":"00aa","unit":"usd","active":true,"input_fee_ppk":0},
    {"id":"00bb","unit":"sat","active":false,"input_fee_ppk":1000},
    {"id":"010c51bf","unit":"sat","active":true,"input_fee_ppk":100},
    {"id":"00dd","unit":"sat"}]}
    '''
  ;:  weld
    %+  expect-eq
      !>(`(list keyset:ca)`~[['00aa' 'usd' & 0] ['00bb' 'sat' | 1.000] ['010c51bf' 'sat' & 100] ['00dd' 'sat' | 0]])
      !>(ks)
    (expect-eq !>(`['010c51bf' 'sat' & 100]) !>((active-sat:ca ks)))
    (expect-eq !>(~) !>((active-sat:ca (scag 2 ks))))
    (expect-eq !>(0) !>((input-fee:ca ks ~)))
    (expect-eq !>(1) !>((input-fee:ca ks ~['010c51bf'])))
    (expect-eq !>(1) !>((input-fee:ca ks (reap 10 '010c'))))
    (expect-eq !>(2) !>((input-fee:ca ks (reap 11 '010c'))))
    (expect-eq !>(1) !>((input-fee:ca ks ~['00bb' '00aa' '0f' ''])))
    (expect-eq !>(2) !>((input-fee:ca ks ~['00bb' '010c'])))
    ::  a proof that names no keyset pays no keyset's fee
    (expect-eq !>(0) !>((input-fee:ca ~[['00bb' 'sat' | 1.000]] ~[''])))
    (expect-eq !>(~) !>((parse-keysets:ca (j '{"keysets":[{"id":"00aa"}]}'))))
  ==
::
::  a restore answer (NUT-09) pairs each output the mint signed with its
::  signature, and only those come back as proofs; an answer without its
::  outputs (a swap's, arriving late) is no restore answer
::
++  test-restore
  =/  k  7
  =/  keys  (my ~[[1 (point-to-hex:ca (ec-mul:ca secp-g:ca k))] [2 (point-to-hex:ca (ec-mul:ca secp-g:ca k))]])
  =/  outs  (new-outs:ca ~[1 2] '00ab' 42)
  =/  sign
    |=  o=out:ca
    (point-to-hex:ca (ec-mul:ca (hex-to-point:ca b.o) k))
  =/  two=out:ca  (snag 1 outs)
  =/  answer=json
    %-  pairs:enjs:format
    :~  ['outputs' [%a ~[(pairs:enjs:format ~[['B_' s+b.two] ['amount' n+'2'] ['id' s+'00ab']])]]]
        ['signatures' [%a ~[(pairs:enjs:format ~[['C_' s+(sign two)] ['amount' n+'2'] ['id' s+'00ab']])]]]
    ==
  =/  got  (need (parse-restore:ca answer))
  ;:  weld
    (expect-eq !>((my ~[[b.two [2 '00ab' (sign two)]]])) !>(got))
    %+  expect-eq
      !>(~[[2 '00ab' secret.two (point-to-hex:ca (ec-mul:ca (hash-to-curve:ca secret.two) k))]])
      !>((restored-proofs:ca outs got keys))
    (expect-eq !>(~) !>((restored-proofs:ca outs ~ keys)))
    (expect-eq !>(~) !>((parse-restore:ca (j '{"signatures":[]}'))))
    (expect-eq !>(`~) !>((parse-restore:ca (j '{"outputs":[],"signatures":[]}'))))
    (expect-eq !>(~) !>((parse-restore:ca (j '{"outputs":[{"B_":"02"}],"signatures":[]}'))))
  ==
::
::  our outputs are one per amount under the keyset asked for, each with
::  its own secret, and the mint's signatures on them unblind to proofs a
::  mint would take: C = k*Y
::
++  test-outputs-to-proofs
  =/  k  11
  =/  keys  (my ~[[1 (point-to-hex:ca (ec-mul:ca secp-g:ca k))] [4 (point-to-hex:ca (ec-mul:ca secp-g:ca k))]])
  =/  outs  (new-outs:ca ~[4 1] '00ab' 9)
  =/  sigs  (turn outs |=(o=out:ca [amount.o id.o (point-to-hex:ca (ec-mul:ca (hex-to-point:ca b.o) k))]))
  ;:  weld
    (expect-eq !>(~[4 1]) !>((turn outs |=(o=out:ca amount.o))))
    (expect-eq !>(%.y) !>((levy outs |=(o=out:ca =('00ab' id.o)))))
    (expect-eq !>(2) !>(~(wyt in (silt (turn outs |=(o=out:ca secret.o))))))
    (expect-eq !>(~[[4 '00ab' b:(snag 0 outs)] [1 '00ab' b:(snag 1 outs)]]) !>((out-reqs:ca outs)))
    %+  expect-eq
      !>((turn outs |=(o=out:ca [amount.o '00ab' secret.o (point-to-hex:ca (ec-mul:ca (hash-to-curve:ca secret.o) k))])))
      !>((outs-proofs:ca outs sigs keys))
    ::  a melt's change comes back on however many blank outputs it needs
    (expect-eq !>(~[[2 '00ab' '02ab']]) !>((parse-melt-change:ca (j '{"state":"PAID","change":[{"amount":2,"id":"00ab","C_":"02ab"}]}'))))
    (expect-eq !>(~) !>((parse-melt-change:ca (j '{"state":"PAID"}'))))
    (expect-eq !>(1) !>((blank-count:ca 0)))
    (expect-eq !>(1) !>((blank-count:ca 1)))
    (expect-eq !>(2) !>((blank-count:ca 2)))
    (expect-eq !>(10) !>((blank-count:ca 1.000)))
  ==
::
::  checkstate (NUT-07) files proofs by Y = hash_to_curve(secret), and
::  the verdict on a melt's proofs is the furthest any of them got
::
++  test-checkstate
  =/  y  '022e7158e11c9506f1aa4248bf531298daa7febd6194f003edcd9b93ade6253acf'
  =/  st  |=(v=(list @t) (malt (turn (gulf 1 (lent v)) |=(i=@ [`@t`i (snag (dec i) v)]))))
  ;:  weld
    (expect-eq !>(y) !>((proof-y:ca (lsh [3 31] 1))))
    %+  expect-eq  !>((pairs:enjs:format ~[['Ys' [%a ~[s+y]]]]))
      !>((build-checkstate-request:ca ~[(proof-y:ca (lsh [3 31] 1))]))
    %+  expect-eq  !>(`(my ~[['02aa' 'SPENT'] ['02bb' 'UNSPENT']]))
      !>((parse-checkstate:ca (j '{"states":[{"Y":"02aa","state":"SPENT","witness":null},{"Y":"02bb","state":"UNSPENT"}]}')))
    (expect-eq !>(~) !>((parse-checkstate:ca (j '{"detail":"no"}'))))
    (expect-eq !>(`'SPENT') !>((verdict:ca (st ~['UNSPENT' 'PENDING' 'SPENT']) 3)))
    (expect-eq !>(`'PENDING') !>((verdict:ca (st ~['UNSPENT' 'PENDING']) 2)))
    (expect-eq !>(`'UNSPENT') !>((verdict:ca (st ~['UNSPENT' 'UNSPENT']) 2)))
    (expect-eq !>(~) !>((verdict:ca (st ~['UNSPENT']) 2)))
    (expect-eq !>(~) !>((verdict:ca (st ~['UNSPENT' 'ODD']) 2)))
  ==
::
::  a payer's token as the paywall sends it: whole proofs only, 1 to
::  100 of them, their sum and keyset ids
::
++  test-token-inputs
  =/  one  '{"amount":8,"id":"00ab","secret":"s1","C":"02aa"}'
  =/  two  '{"amount":2,"id":"00cd","secret":"s2","C":"02bb"}'
  =/  tok  |=(ps=(list @t) (rap 3 '{"inputs":[' (rap 3 (join ',' ps)) ']}' ~))
  ;:  weld
    %+  expect-eq  !>(`[18 ~['00ab' '00cd' '00ab']])
      !>((bind (token-inputs:ca (tok ~[one two one])) |=([* t=@ud i=(list @t)] [t i])))
    (expect-eq !>(~) !>((token-inputs:ca (tok ~))))
    (expect-eq !>(~) !>((token-inputs:ca (tok (reap 101 one)))))
    (expect-eq !>(%.y) !>(?=(^ (token-inputs:ca (tok (reap 100 one))))))
    %+  expect-eq  !>(`[1.024 ~['00ab']])
      !>((bind (token-inputs:ca (tok ~['{"amount":1024,"id":"00ab","secret":"s","C":"02"}'])) |=([* t=@ud i=(list @t)] [t i])))
    (expect-eq !>(~) !>((token-inputs:ca (tok ~[one '{"amount":0,"id":"00ab","secret":"s","C":"02"}']))))
    (expect-eq !>(~) !>((token-inputs:ca (tok ~[one '{"amount":1,"id":"00ab","secret":"s"}']))))
    (expect-eq !>(~) !>((token-inputs:ca (tok ~[one '{"amount":"1","id":"00ab","secret":"s","C":"02"}']))))
    (expect-eq !>(~) !>((token-inputs:ca (tok ~[one '7']))))
    (expect-eq !>(~) !>((token-inputs:ca '{"proofs":[]}')))
    (expect-eq !>(~) !>((token-inputs:ca 'cashuA')))
    ::  64 KiB is the most a token may be, to the byte
    =/  pad  |=(n=@ud =/(t (tok ~[one]) (cat 3 t (fil 3 (sub n (met 3 t)) ' '))))
    ;:  weld
      (expect-eq !>(%.y) !>(?=(^ (token-inputs:ca (pad 65.536)))))
      (expect-eq !>(~) !>((token-inputs:ca (pad 65.537))))
    ==
    ::  an amount that isn't a whole number
    (expect-eq !>(~) !>((token-inputs:ca (tok ~['{"amount":1.5,"id":"00ab","secret":"s","C":"02"}']))))
  ==
::
::  a withdrawal's proofs: the largest first, until they pay what is
::  needed and the fee for spending them too
::
++  test-select-proofs
  =/  ks=(list keyset:ca)  ~[['00ab' 'sat' & 500]]
  =/  p  |=(a=@ud `proof:ca`[a '00ab' (scot %ud a) '02'])
  =/  have  ~[(p 1) (p 8) (p 2) (p 4)]
  =/  amts  |=(u=(unit (list proof:ca)) (bind u |=(l=(list proof:ca) (turn l |=(q=proof:ca amount.q)))))
  ;:  weld
    (expect-eq !>(`~[8]) !>((amts (select-proofs:ca have 7 ks))))
    (expect-eq !>(`~[4 8]) !>((amts (select-proofs:ca have 8 ks))))
    (expect-eq !>(`~[2 4 8]) !>((amts (select-proofs:ca have 12 ks))))
    (expect-eq !>(`~[1 2 4 8]) !>((amts (select-proofs:ca have 13 ks))))
    (expect-eq !>(~) !>((amts (select-proofs:ca have 14 ks))))
    (expect-eq !>(`~[2 4 8]) !>((amts (select-proofs:ca have 14 ~))))
    (expect-eq !>(`~) !>((amts (select-proofs:ca have 0 ~))))
  ==
::
::  a nutshell mint's own answer for its keys (0.21, a v2 keyset id)
::  parses whole: all 64 amounts
::
++  test-nutshell-keys
  =/  k
    %-  parse-keys:ca
    %-  j
    '''
    {"keysets":[{"id":"010a51bf8580554bce03c563b96786b5dec29f1a4d21ec4050a7c4b827b4f8d30a","unit":"sat","active":true,"input_fee_ppk":100,"keys":{"1":"0287fc209e632a19835141b41c6c3e485f050515fee6723f2c88a7c2bb95248e95","2":"035da6ada5ba427f2625cb0fa05cb38e38b4ed5ea2733e625a4286e741e1246291","4":"0269abe041e5f944616ef9e8f243f5a719763751f7bcc38313cc7e419265e2b45d","8":"02c36452e65926574f7031cebc754a23c19b172d2e06e6ee94e320a137773f6a82","16":"02fbd7179916bec8a40445280b8e5d3d01793ee0aba4a2439d92857f0c9a9555c4","32":"03ed3a4c4341a2a9cb00999e91b52d3ceb9e887150e5df00007d301a07476744d5","64":"02278f51bee3467f4b7a81004d16433ebea02acf4b97bd3585f0a5d361b7ce9416","128":"021d6b2f2ccc3a87ad88b0bc50c9b48d9225fc37fa5293a7436dc9c902453e408e","256":"03648035b63a55fa3f8f08698932a5e61dce61433ecdabb463dd23450ae0073083","512":"0334c21afeaf71825845166f83f8911b99c84c2cc6d0e6d524adda86172ea3d51a","1024":"02953cfce7578fc60d6acba3a6e0c1871e4f4e348c5c549eb5b54dbcc950992705","2048":"032d4c2f70cbe0b36a505c2d3eb4c220022c4862089617d563b482a64953992b25","4096":"03ea0fa969b9984f39a0d0f40131bd507426b1b39dc25837dde64a3a44859a567d","8192":"0319be256eb8da1ccf7600cb72bd992c46c0f7f6e6f7e40df7b2249fd808758ed2","16384":"0234d00fca72dcb12827df917921ec8835d839988214c01f9dff33708b65cf4212","32768":"034de340d3606d257fb9be07c1472175606c8b2273fc88957fa7eb91a72126eeb7","65536":"0300514e639e5665300681d9fa964f4ed910377c0c40d1f89e9cfaf34ff4175f57","131072":"03f5355f922896563c38bc9e394a2d8e979f5be08ae663d2e2c443b000bfa3f571","262144":"020b76196338794baf904240298a7bdb3344c85c4b3e33ba434a9355fabd010e54","524288":"026a9be295eebd6e4203c28b56ed747b350136debc19e5a8c2c25c84c474356679","1048576":"037dd961947b23c8107672c5bd4c711eba9a754f544e2280553ae3c43cda8d10ea","2097152":"031b1bcc85653099c76a054ee515405e4e187955e394eecf7ebd5cf522498b3e03","4194304":"0233cf4a6e76ebb157674e695d84990e1868a699807879a648969908876e0fee29","8388608":"035ce04d47a0f3a156e7cfda71123779fa2b785ffa2c0b460b285ae2594e160687","16777216":"03f9c239cdc67a4a1e83b352cfa851f56e0a577e3de21fb1bbf6be912078530336","33554432":"022c0f76bb38da7813e06c6cf93f39eded4ec0563aecbaf229eaeb6516713f8ec1","67108864":"03d25766b37d935e67fddf139a4092572ed0e3826466c690a405110b61d364d4df","134217728":"03e01893ba41656d1f669359612b9d451bb713b874d42a309c71c84e3d1aaede88","268435456":"02bcb651929791c2e0905f24518ef2e6061dcc2b7f9320cad8e24bcd20bdc35de4","536870912":"021a9b3981ffbfd20aff9d704004aaed9ed4da965f24081e698f0be6a8bba069b3","1073741824":"02164c3bebc7a6a47cb0b4dd200f71c007101fd9cef31f4e78e1395e91f32c9d9b","2147483648":"03a08d4fda9101f508eae7e90f504d91b859640a6401b8909d4ff5c7ca6cdb91f5","4294967296":"02bc1e0f64d96b4915f907d8e425c39deef624f71abd6aea01e17cc6c281825d64","8589934592":"024b65dab26c1270257f850f23b1ae15d90b20e360d6f3b5ccbaffbbeea866c29e","17179869184":"029d67e5022a5841fc9d2f01cc859330d3b6246703ee7a2fe1586bc1b12afd8644","34359738368":"0273b3f895b207e97fa72d9db776089532b598e901c334a74a558fe70a85504993","68719476736":"02921071ef1c1fef3246527195693249dbc51bd2ebbfab95b8f7190ba5323c82ef","137438953472":"03ecd29b37cdd02fd270220fee6a0da364071cfb70f542d67ebb08775f54ca65d1","274877906944":"02680be38b4c6a62460121541c1357618a3597eea9de70cea06907fa387f67a3ea","549755813888":"0319c7705c1451ecd4fb50cfdf94bc168c0f892d2f2c55de118c1ba9935ddbb9ab","1099511627776":"0216c6fd502da1409a09351d4aa286ea7fa5a27be66dd80afa08d0b734136c6f5b","2199023255552":"034f875ee288b74623a879735e59b25f3d2e8509e0c514e3b074938fa9ffb45fba","4398046511104":"03e6d48be3fc4d08bff75f37353bf8d32854ee27c6367156abe74fdadba8493c61","8796093022208":"033870a9af9ef9e1194d1b66ccb8e8b5f9f6453f5407ce9675314bb583d7e40ee7","17592186044416":"021530412f80f90bfbc11656890cd3113615d50b53761e7ca76bf41e877ffea997","35184372088832":"027e7758e22ec784f5a796015ae0d20053f39df9b8621674a9a93bf19dff458627","70368744177664":"02ad1d4f2fcb0b8fac8b40a770901b15be05abe263434d6af2179a4539decc8ded","140737488355328":"037de73362c16ac308d848d7e9631db5b688048351844678ceeeee6c427a1275ca","281474976710656":"036f3b2a08eed8318bce9a20d10917f89492e02f02a118e416d560802f30c77f22","562949953421312":"02f8d5ff9b8f18e98cd2cee219c33b1519e369f699619d94a6095540bcd169504c","1125899906842624":"02d319985cecb776f87c1f02168f354819a4386e5639858bbf9096b0c61b2dd497","2251799813685248":"02b34310e825cd1590ea7a89b1f759ea9366f284f18e35b0ef23183bb37cfa165d","4503599627370496":"02dc3d3c5ae15d0135e71d96fb6ab80f425c3beb211767b1746865e7b850189709","9007199254740992":"03eb7250d2a45a2c5ef870b153601243018b4c36623d8d77c4675d9ea33c015c2b","18014398509481984":"026fcc3e15e8a04d1452e4ab72db1e9a2d18f86a121855d8eb2777a0017fad204d","36028797018963968":"0336c02fa99693fa6644acd64b98f00c236a10b823c2148567a57378ffd901d8a9","72057594037927936":"02128a4e39a65633090d3a7bcba41030547924c9f8acd914c0f724f90b92eb9148","144115188075855872":"0349ebb770be19979a917177fe1b5c2045339bb8ba5d42b065a177b0911fbddf13","288230376151711744":"0315043cf1dfe1daa8bfa35dc8e187c0b87f7e48daa54e33397fff0f47c06fee64","576460752303423488":"02b28af7be56daf70375c6973ce533acb0db02445a6469e5fb2907ba104262bb9a","1152921504606846976":"0343ca2d5e12f327f9f272c951f6f82fe04c268d6f4bba6a92d5ec449b9838282b","2305843009213693952":"036b80be7d906d23bc48b3edfc098cbf0bd5d10eb847337bef811c42737dae2e6f","4611686018427387904":"0217b26025c2dff9fbcdfff7a00ac5ccdab5983d7ce399d458488823832ee6067d","9223372036854775808":"0339e84649c14805a1376b9392ff09e3178bf5bdcd15f96c8b9e874d7d18f68a10"},"final_expiry":null}]}
    '''
  ;:  weld
    (expect-eq !>(%.y) !>(?=(^ k)))
    (expect-eq !>(64) !>(?~(k 0 ~(wyt by u.k))))
  ==
::
::  a mint's answers come back by fiber, not by request, so each call
::  takes only an answer that names what it asked: its keyset, its quote,
::  one signature per output (and not a restore's), only our outputs,
::  exactly our Ys
::
++  test-answer-checks
  =/  keys  (j '{"keysets":[{"id":"00ab","unit":"sat","keys":{"1":"02aa"}}]}')
  =/  outs  (new-outs:ca ~[1 2] '00ab' 9)
  =/  b  |=(o=out:ca (pairs:enjs:format ~[['B_' s+b.o] ['amount' (numb:enjs:format amount.o)] ['id' s+'00ab']]))
  =/  sigs  |=(n=@ud [%a (reap n (j '{"amount":1,"id":"00ab","C_":"02aa"}'))])
  ;:  weld
    (expect-eq !>(%.y) !>((is-keysets:ca (j '{"keysets":[{"id":"00ab","unit":"sat"}]}'))))
    (expect-eq !>(%.n) !>((is-keysets:ca keys)))
    (expect-eq !>(%.y) !>((is-keys:ca keys '00ab')))
    (expect-eq !>(%.n) !>((is-keys:ca keys '00cd')))
    (expect-eq !>(%.n) !>((is-keys:ca (j '{"keysets":[{"id":"00ab","unit":"sat"}]}') '00ab')))
    (expect-eq !>(%.y) !>((is-quote:ca (j '{"quote":"q1","state":"PAID"}') 'q1')))
    (expect-eq !>(%.n) !>((is-quote:ca (j '{"quote":"q0","state":"PAID"}') 'q1')))
    ::  a new mint quote has its invoice; a melt quote's, when the mint
    ::  echoes it, is ours
    (expect-eq !>(%.y) !>((is-new-quote:ca (j '{"quote":"q","request":"lnbc1"}') ~)))
    (expect-eq !>(%.n) !>((is-new-quote:ca (j '{"quote":"q"}') ~)))
    (expect-eq !>(%.n) !>((is-new-quote:ca (j '{"request":"lnbc1"}') ~)))
    (expect-eq !>(%.y) !>((is-new-quote:ca (j '{"quote":"q","request":"lnbc1"}') `'lnbc1')))
    (expect-eq !>(%.n) !>((is-new-quote:ca (j '{"quote":"q","request":"lnbc2"}') `'lnbc1')))
    (expect-eq !>(%.y) !>((is-new-quote:ca (j '{"quote":"q","amount":1}') `'lnbc1')))
    (expect-eq !>(%.y) !>((is-sigs:ca (pairs:enjs:format ~[['signatures' (sigs 2)]]) 2)))
    (expect-eq !>(%.n) !>((is-sigs:ca (pairs:enjs:format ~[['signatures' (sigs 1)]]) 2)))
    (expect-eq !>(%.n) !>((is-sigs:ca (pairs:enjs:format ~[['outputs' [%a (turn outs b)]] ['signatures' (sigs 2)]]) 2)))
    %+  expect-eq  !>(%.y)
      !>((is-restore:ca (pairs:enjs:format ~[['outputs' [%a ~[(b (snag 0 outs))]]] ['signatures' (sigs 1)]]) outs))
    %+  expect-eq  !>(%.n)
      !>((is-restore:ca (pairs:enjs:format ~[['outputs' [%a ~[(b (snag 0 (new-outs:ca ~[1] '00ab' 7)))]]] ['signatures' (sigs 1)]]) outs))
    (expect-eq !>(%.n) !>((is-restore:ca (pairs:enjs:format ~[['signatures' (sigs 1)]]) outs)))
    (expect-eq !>(%.y) !>((is-states:ca (j '{"states":[{"Y":"02aa","state":"SPENT"}]}') (sy ~['02aa']))))
    (expect-eq !>(%.n) !>((is-states:ca (j '{"states":[{"Y":"02aa","state":"SPENT"}]}') (sy ~['02aa' '02bb']))))
  ==
--
