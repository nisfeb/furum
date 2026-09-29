# Hoon testing

furum's libraries are tested with [hoon-test-kit](https://github.com/nisfeb/hoon-test-kit),
vendored at `scripts/hoon-test-kit/` (version in `.kit-version`). Read the kit's
`PLAYBOOK.md` before changing how this works. This file is what the kit found
here, and why each surviving mutant was let stand.

## Running

The suites run on a fake ship's `%furum-test` desk, never on `%furum` and never
on a real ship. Once per ship, in its dojo:

```
|new-desk %furum-test
|mount %furum-test
```

then from the repo root:

```sh
VERE=~/software/vere-v4.6-linux-x86_64 scripts/hoon-test-kit/hoon-test.sh <pier> setup
VERE=... scripts/hoon-test-kit/hoon-test.sh <pier>            # all suites, ~21 s
VERE=... scripts/hoon-test-kit/hoon-test.sh <pier> cashu      # one suite
VERE=... scripts/hoon-test-kit/hoon-mutate.py <pier> --list   # size a mutation run first
```

**Keep the pier path short.** `conn.sock` lives at `<pier>/.urb/conn.sock`,
and a Unix socket path over 107 bytes can't be connected: socat fails without
a word and the kit reports exit 4, "the ship did not answer". Point `<pier>`
at a short symlink (`ln -s <pier> /tmp/fb`) when the pier sits deep.

## What is under test

`hoon-test.conf` puts three libs on the test desk:

| lib | suite | tests | what it owns |
|---|---|---|---|
| `lib/furum-rules.hoon` | `tests/lib/furum-rules.hoon` | 9 | who may do what, rate limits, post caps, auto-prune, prune timers, merging a host's comment into the cache, the cross-site check |
| `lib/furum.hoon` | `tests/lib/furum.hoon` | 12 | which urls may become links (and that every view obeys it), board names, accepted mints, form and query parsing, vote targets, paging, comment threading, post ordering |
| `lib/cashu.hoon` | `tests/lib/cashu.hoon` | 9 | the ecash protocol, against the NUT-00 vectors and the NUT-03/04/05 field names |

The agent itself can't be built by the kit. Its pure decisions were moved
into `lib/furum-rules.hoon` (2026-09-28), with a one-line alias left in the
agent for each moved arm, so no call site changed. The prune selection, the
comment merge and the cross-site check were lifted out of their handlers
the same way. The two copies of the mint-keys parser in the agent became
`parse-keys` in `lib/cashu.hoon`, which replaced `parse-keyset` (no callers).
Three more uncalled arms were deleted from `lib/furum.hoon`:
`render-registry-admin` (its route became a redirect to `/admin` in
4124168), `net-votes` and `rank-list`.

Each test's comment says what it protects. Nothing was added that a
production caller doesn't use.

## The regressions they catch

Each historical bug was put back into the lib on the test desk, and the
suite that owns the rule had to fail. Each did, for the intended reason:

| bug | caught by |
|---|---|
| the feed linked a post's raw url (missed by 51c931b) | `furum/test-rendered-links` (only the feed entry flips) |
| furum-relative links refused, which dropped every notification's link (51c931b) | `furum/test-safe-url` |
| an image url passed with `http://` anywhere in it (before 51c931b) | `furum/test-is-image-url` |
| any mint accepted for ecash | `furum/test-mint-accepted` |
| our optimistic comment kept beside the host's copy | `furum-rules/test-merge-comment` |
| prune timer at now + 6h, one more chain per reload | `furum-rules/test-prune-timer` |
| a mint's keys for 1024 sats and up dropped, losing those proofs (`dem:ag`, introduced by the `parse-keys` lift, found 2026-09-28 by a phase-0 spike) | `cashu/test-parse-keys` |
| votes on post or comment ids past 999 refused, and replies to them turned top-level (`dem:ag`, since the vote form's start) | `furum/test-parse-vote-target` |

## Mutation runs (2026-09-28, kit 13bc43f, fake ~bus on zuse 408)

The default ops (`boundary,conjunct`). Every survivor was re-traced before
anything was written for it.

### furum-rules: 22 mutants, 20 killed, 1 no-build, 1 survivor

- **no-build**, `+cross-site` `?&( drop ?=(^ site)`: the other clause
  reads `u.site`, which needs the narrowing. Expected.
- **equivalent**, `+prunable` `gte->gth` in the net-score floor: when
  up = dn both branches give 0.

### cashu: 28 mutants

The first pass left 19 survivors and three real gaps: `+finalize-proofs`
had no test, nothing parsed an `03` point (half of all mint keys), and
nothing parsed uppercase hex. `test-finalize-proofs` and `test-point-hex`
closed them, and a recheck of those arms killed what they reached. What
survives:

- **equivalent**, `+hash-to-curve` `lth->lte` on the 65,536-try cap: a cost
  bound, never reached.
- **equivalent**, `+split-amount` `gte->gth` on the loop bound: the extra
  pass adds nothing.
- **equivalent**, `+ec-add` `&( drop` of either coordinate test: every
  doubling passes the same point twice, and no addition in `+ec-mul` meets
  a point with the same x.
- **equivalent**, `+finalize-proofs` `gte->gth` and `|( drop` on the
  secrets and blinding-factors bounds: the agent builds both lists together,
  so each bound covers for the other. The case they guard together, a mint
  sending more signatures than outputs, is tested.
- **defensive**, `+hex-to-bytes` `&( drop (gte c '0')`, `(lte c 'f')`,
  `(gte c 'A')`, `(lte c 'F')`: each only changes how malformed hex fails.
  Valid hex, either case, is tested.
- **no-build**, `+parse-keys` `&( drop` of either test: the other reads
  the narrowed value. Expected.

**Leave `+ec-decompress` out of `--only` runs.** Its `|( drop =(2 prefix)`
mutant makes every hash-to-curve try all 65,536 counters. That held ~bus
past the runner's timeout twice: once reported as a timeout, once as a ship
that stopped answering. Both times the ship came back idle, and the run was
void from there. That arm's other mutant (`drop =(3 prefix)`) and the
matching one in `+hex-to-point` were checked by hand instead. Both were killed.

### furum: 55 mutants on the logic arms

`--only valid-board-name,hex-char,render-feed,commafy,sort-posts-by-top,safe-url,is-image-url,render-notifications,score-post,parse-page,sort-posts-by-new,walk-children`.
The render arms' other sites were left out (see "Not covered").

The first pass killed 25. Its real gaps: no form escape held `0`, `a`, `f`
or `F`, so those range edges were never tested. `%0D%0A` is how a
post body's line breaks arrive, so this matters. Two `+hex-char` guards
that keep a bad escape (`%-5`, `%@1`) from underflow-crashing the form
parser were never reached either. And no board name held `z`, `0` or `9`.
`test-parse-form` and `test-valid-board-name` now cover them. A recheck of
both arms killed all 26 mutants that build. What survives:

- **equivalent**, `+commafy` `lte->lth` on the three-digit fast path: the
  loop gives the same answer.
- **equivalent**, `gte->gth` on every net-score floor (`+sort-posts-by-top`
  twice, `+score-post`, `+render-feed`): at up = dn both branches give 0.
- **equivalent**, `+sort-posts-by-top` `gth->gte` on the score comparison:
  it sits behind an `=(va vb)` guard.
- **equivalent**, `+score-post` `gth->gte` on the age: at now = created
  the age is 0 either way.
- **equivalent**, `+parse-page` `lth->lte`: page 1 clamps to 1 either way.
- **accepted**, tie order in `+sort-posts-by-new`, `+sort-posts-by-top`'s
  time tie-break, `+walk-children` and `+render-feed`'s sort: posts and
  comments made at the same instant have no promised order.
- **accepted**, `+render-feed` `gth->gte` on the "new" tag: a post made at
  the exact instant of the last visit.
- **accepted**, `+render-notifications`' two unread-count checks: at zero
  unread they only change the "all caught up" text and whether a
  mark-read button shows.
- **accepted**, `+render-feed` `?&( drop (is-image-url …))`: a non-image
  link would get a preview inside a closed `<details>`.
  `+is-image-url` itself is tested.
- **no-build** (5): four halves of `+valid-board-name`'s multi-line `?&`
  (the kit's finder splits it), and `+render-feed` without the `?=` that
  narrows the url.

## The nexus (`code/`)

The grubbery nexus has its own conf, `hoon-test-nexus.conf`
(`DIALECT=grubbery`), and its own test desk, `%furum-nexus-test`. It needs
a fake ship with `%grubbery` installed, since `SHIP_FILES` copies the kernel
libs the nexus builds against (tarball, nexus, loader, server, fiberio and
their imports) from that desk at the version the ship runs. Once per ship,
in its dojo, `|new-desk %furum-nexus-test` and `|mount %furum-nexus-test`,
then:

```sh
HOON_TEST_CONF=hoon-test-nexus.conf VERE=... scripts/hoon-test-kit/hoon-test.sh <pier> setup
HOON_TEST_CONF=hoon-test-nexus.conf VERE=... scripts/hoon-test-kit/hoon-test.sh <pier>
```

`tests/nexus/` holds seven suites, 95 tests:

| suite | tests | what it owns |
|---|---|---|
| `furum-rules` | 10 | the Gall suite, ported: who may do what, paid access, rate limits, the prune slot, auto-prune, post caps, the cross-site check; and who reads a paid board |
| `furum` | 12 | the Gall suite, unchanged: links, forms, vote targets, paging, threads, orderings |
| `cashu` | 17 | the Gall suite, and the wallet and recovery arms payments use (below) |
| `furum-board` | 9 | a board in the ball, and who hears of an action (below) |
| `furum-registry` | 2 | the directory's rules: first registrant, curation, admins |
| `furum-theme` | 6 | the theme: colours derived as talon derives them, an accent, what a page draws with, talon's settings read as talon writes them |
| `nexus` | 39 | the fibers, driven through `+on-file` with the kit's `fiber-test` (below) |

The Gall desk's libs were copied to `code/lib` with grubbery imports
(`/<`), and `sur/furum.hoon` became `lib/furum-types.hoon`. `desk/` is
frozen except for the 0.6 release: fixes to the rules land in `code/lib`.
Two Gall-only arms didn't come across: `+prune-timer` (Gall cards) became
the pure `+prune-at`, and `+merge-comment` (the Gall client cache) went.

`furum-board` guards the storage:

| test | protects |
|---|---|
| `test-round-trip` | a board with a reply, votes of each kind, pins, a sidebar, roles and auto-prune comes back from its grubs exactly; a deleted comment's id stays spent |
| `test-buckets` | posts, threads and votes go in buckets of 100 by post id, a post with no comment has no thread, and nothing unvoted is kept |
| `test-load-refuses` | a grub no shape fits stops the load by name, rather than reading as empty for the writer to write back |
| `test-who-may` | the host alone makes and deletes boards; mods pin and set roles; a reader can't post; only an author edits |
| `test-limits-and-targets` | the post and comment cooldowns bind everyone but mods, and a mod's post records none; a comment needs its post, and a reply its parent |
| `test-host-settings` | only the host edits or opens a board, a board keeps a title, a paid board stays closed, the sidebar's 10,000-byte cap, unpinning |
| `test-notes` | the host hears of another's post; a post's author of a comment; a comment's author of a reply; never the actor, nobody twice |
| `test-payment` | only the host sets a price, gives access or takes it; a price closes a public board |
| `test-votes` | a vote replaces the voter's last one on a target, and remove clears it |

`nexus`:

| test | protects |
|---|---|
| `test-writer-grants-the-inbox` | the writer registers itself and grants `/public` poke on `inbox.sig` only: a grant naming `main.sig` would let any ship write the boards |
| `test-refusing-weir-parks` | rule 8: with the clock refused, a crashed writer parks after one dart. A poke is refused with the note, and the restart it brings parks again without writing `rise.json`. Jailed, a clean start asks the registry nothing |
| `test-crash-waits-then-rises` | a crash waits a minute, recorded in `rise.json` with a timer set. The `/rise` wake brings the writer back; another timer's wake doesn't |
| `test-restart-under-writes` | rule 9: an op queued before the start's kick is held, then applied |
| `test-writer-refuses` | a ship's poke, a malformed op and a wrong mark go to `/tr/last`, never a crash; a good op lands on `/tr/inbox` |
| `test-ask-answered` | an ask is answered to the fiber that asked, refused or applied; a new board is made whole |
| `test-prune` | the tick pokes the writer at its slot, and the writer deletes only the posts past age and under score, rewriting only their bucket |
| `test-refusal-told-back` | a change another ship asks for and our writer refuses is told back to it, through the outbox |
| `test-notes-from-followed` | a note is kept only from a ship whose boards we read; a link no page may follow is dropped; it pushes only when its kind is one the owner picked |
| `test-follow` | following another ship's board puts it in the feed and starts its mirror; our own board only the feed; unfollowing only the feed |
| `test-registry-writer` | a ship that doesn't keep the registry refuses registry actions; one that does keeps the entry and the host's install path |
| `test-public-grant-set` | at a rise every ship may read each board's `pub/` and a free board's `content/`, never a paid one's; only the paid board gets a group |
| `test-public-grant-resent` | a board made, or given a price, resends the public grant; giving access doesn't |
| `test-sweeper` | the sweeper sleeps until the next member runs out, then asks the writer to sweep, never before; another timer's wake is not its time |
| `test-grant-writes-group` | a member given access goes into the board's group, and the registry is asked to open the board's content to it: its content, nothing more |
| `test-inbox-forwards` | the inbox forwards another ship's poke with the sender the transport names, and ignores a local one |
| `test-owner-gate` | owner pages are the owner's; the about page is anyone's; a board a guest can't see answers like a missing one; a cross-site form and a wrong method are refused |
| `test-rise-plan` | the backoff: 1, 2, 4 minutes to an hour, reset after two quiet hours |
| `test-pay-swap` | ecash in hand: keysets, keys, outputs for the token less the mint's input fee kept before anything is sent, a restore, then the swap; its signatures become proofs, and the writer is asked to settle |
| `test-pay-stale-answer` | a mint's answer to an earlier request (the keysets again) is let go while the keys are awaited; a failure is taken as it comes, and the step waits 15 s and tries again |
| `test-pay-resumes-by-restore` | a swap resumed after a restart asks the mint what it signed before it swaps: signed, those are the proofs and no second swap goes |
| `test-pay-refused` | a refused swap fails with the mint's reason only after a second restore finds nothing |
| `test-pay-invoice` | an invoice: the mint's quote, the invoice to the payer under its nonce, the quote asked after every 5 s (another quote's answer let go); paid, outputs for the price kept before the mint signs |
| `test-pay-melt` | a withdrawal's proofs leave the wallet first; checkstate says unspent, so the melt goes with blank outputs; paid, the change is ours; refused and still unspent, the proofs come back; pending, it waits |
| `test-start-pay` | a payment only for a paid board, from a trusted mint, worth the price, three at a time per ship; a refusal goes back as the payer's answer under its nonce; a withdrawal is the host's |
| `test-settle` | a finished payment's proofs go into the wallet with gain on; its grub is culled; the payer's access runs from when its last runs out; it hears so. A wallet that won't read is never written over |
| `test-take-pay` | a host's word on our payment is kept under its nonce, only from the host we paid and about the board we paid for |
| `test-start-melt` | the host withdraws only from a mint the board's wallet holds proofs from, one withdrawal per board at a time (another board's, a payer's or a finished one doesn't count) |
| `test-spend` | a withdrawal's proofs leave the wallet before it is sent; a wallet that won't read is never written over |
| `test-paying` | a payment we make is kept under its nonce; those a week old go |
| `test-pay-edges` | a token worth only the mint's fee fails; a refusal carrying signatures, or an answer with a signature no key covers, is checked with the mint again |
| `test-pay-expiry` | an invoice is waited on until its expiry, not past it; a 300 is taken as it comes, not checked |
| `test-melt-wait` | a pending melt is asked after until paid (change restored) or unpaid (unspent proofs back); a melt the mint doesn't answer about is never given up on |
| `test-pay-settle` | a finished payment is handed to the writer again in a minute when refused, in ten when kept |
| `test-look-follows-talon` | by default a page draws with the theme talon picked, read from `%settings` after asking whether it runs and the entry exists |
| `test-look-talon-off` | turned off, a page asks `%settings` nothing and draws with furum's own; with no `%settings`, the same |
| `test-set-looks` | the writer keeps theme settings only when every theme has an id, a name and five colours, at most fifty, and the accent is a colour |
| `test-look-talon-accent` | talon's accent alone still rules: a custom colour repaints the page, and `%contacts` is not asked |
| `test-look-profile-accent` | a profile-colour accent reads `%contacts`' `/v1/self` after asking whether `%contacts` runs; not running, none |

`furum-rules` gained `test-group` (a paid board's group is its moderators
and the members whose time hasn't run out; the next expiry is the soonest
still to come) and `test-open-paths` (every ship reads each board's
`pub/` and a free board's `content/`, never a paid board's content).

`cashu` gained the arms payments use: `test-keysets-and-fees` (the active
sat keyset; input fees summed per thousand and rounded up, by full or short
keyset id), `test-restore` (a restore answer pairs outputs with signatures
by B_; one without its outputs is no restore answer), `test-outputs-to-proofs`
(our outputs unblind to proofs a mint would take; a melt's change and its
blank-output count), `test-checkstate` (Y is NUT-00's hash_to_curve; the
verdict on a melt's proofs is the furthest any got), `test-token-inputs`
(whole proofs only, 1 to 100), `test-select-proofs` (largest first, until
they pay the need and their own fee) and `test-nutshell-keys` (a nutshell
0.21 mint's own keys answer parses whole), and `test-answer-checks`
(each mint call takes only an answer naming what it asked).

`furum-registry` holds `test-register` (a name is its first registrant's;
retitling keeps tags and curation; only the host unregisters; install
paths are kept and capped) and `test-curation` (the registry and its
admins curate; only the registry names admins).

The request routes and the network are checked live, not by unit tests:
`scripts/api-matrix.py <url> <jar> <~ship>` works a fresh board through
every host action and page, as owner and guest, with each refusal the
routes promise, and the theme settings (111 checks), and deletes it
again.
`scripts/xship.py <url-a> <jar-a> <~a> <url-b> <jar-b> <~b>` runs two
ships at each other, both ways (58 checks): the directory, following,
posts, comments, replies, votes, moderation, notes, and a refusal told
back. `scripts/access.py` (same arguments, host first) checks who may
read a paid board (29 checks): the weir's grants, a stranger's paywall,
access given and taken, a moderator, and a one-minute trial the sweeper
ends. `scripts/pay.py` (the same, then the mint's URL and the virtualenv
nutshell is installed in) pays for a board against a local test mint,
nutshell with its FakeWallet (25 checks): Lightning, a lapse, an ecash
renewal, a token spent twice, a withdrawal the mint refuses and one it
pays, the host's furum reloading under each payment.

The test mint runs from a scratch directory, never a real mint:

```sh
uv venv -p 3.12 .venv
uv pip install -p .venv cashu 'marshmallow<4' 'limits<4'   # 0.21 won't start without the pins
cat > .env <<EOF
MINT_BACKEND_BOLT11_SAT=FakeWallet
MINT_PRIVATE_KEY=any-test-string
MINT_LISTEN_HOST=127.0.0.1
MINT_LISTEN_PORT=3338
MINT_DATABASE=data/mint
EOF
setsid nohup .venv/bin/mint > mint.log 2>&1 &
scripts/pay.py <url-host> <jar-host> <~host> <url-payer> <jar-payer> <~payer> http://127.0.0.1:3338 <dir>/.venv
```

The fake wallet pays every invoice the mint issues, a few seconds on.
The payer's ecash comes from nutshell's own wallet CLI, in a directory of
its own under /tmp.

### Mutation run, phase 1 (2026-09-28, all ops)

On the nexus and `code/lib/furum-rules.hoon`, in slices with `--only`,
since a full run stopped ~wes after about 25 rebuilds. `test-crash-waits`
first left `+rise-park`'s wire check alive: nothing showed the park ending
on its own wake, and a fiber that never did would stay down for good. It
became `test-crash-waits-then-rises`, and every `+rise-park` mutant now
dies. What survives:

- **log text only**: six `+rise-later` mutants on which trace prints
  (the first two crashes in full, "no clock", "no timer"). A test can't see
  a slog.
- **equivalent**, `+rise-later` `gth->gte` on the wait: at until = now to
  the millisecond, the timer fires at once either way.
- **equivalent**, `+ms-of` `lth->lte`: at the epoch itself both give 0.
- **unreachable**, `+soft-now`'s ack-first branch (two mutants): grubbery
  sends a bowl read's answer before its ack.
- **unreachable**, `+soft-behn`'s wire check: the fiber has one dart in
  flight when it waits, so no other pack arrives.

### Mutation run, phase 2 (2026-09-28, all ops)

On `code/lib/furum-board.hoon`, the writer's arms (`+apply`, `+do-act`,
`+board-of`, `+store`, `+board-bole`, `+prune-all`, `+ask`, `+take-done`)
and the new hot sort, in slices of about 20 with `--only`. Each
furum-board mutant rebuilds the nexus that imports it, about 20 s apiece.

The real gaps it found, each now tested:
- a post with only downvotes: `+grubs` could drop its tally unseen
  (`test-round-trip` now downvotes a post);
- the host-only and size refusals of `+act`: editing a board, opening it,
  a paid board made public, the sidebar's cap, removing a role, an empty
  title on edit, and unpinning (`test-host-settings`);
- the writer refusing another ship's preference action, and a bad board
  name as a name (`test-ask-answered`).

What survives:
- **equivalent**, `+sort-posts-by-hot` `gth->gte` on the age and
  `gte->gth` on the net score: zero either way at the boundary; and
  `gth->gte` on the score comparison, which now sits behind an unequal
  guard (the newer-first tie-break was added after the run, with its
  own test).
- **unreachable**, `+store`'s guard for deleting a board that has no
  grubs: `+act` refuses that with 404 first.
- **unreachable**, `+take-done`'s mark check: nothing but the writer pokes
  a request fiber.

The request routes (`+handle-request`, `+serve-*`) are not
mutation-tested: `api-matrix.py` checks them live, at about a minute a
mutant through `hoon-mutate.py --live`.

### Mutation run, phase 3 (2026-09-28, all ops)

On `+notes-for`, `lib/furum-registry`, and the writer's inbox arms
(`+from-ship`, `+take-note`, `+keep-note`, `+note-to`, `+watch`,
`+feed-put`, `+do-reg`).

The first pass left 19 survivors. The real gaps:
- nobody hearing twice, when a reply answers the post author's own
  comment;
- a note's link being sanitized, and push following the owner's picks;
- the feed writes of following and unfollowing;
- the writer refusing registry actions when it keeps no registry;
- the install-path cap at exactly 16 segments.

Each now has a test, and `+take-note` lost a clause no path reaches
(our own notes never come through the inbox). The second pass killed all
45 mutants that build; 4 don't build.

### Mutation run, phase 4 (2026-09-28, all ops)

`--since HEAD` lists 278 mutants in the arms phase 4 touched; most are
page and follower code that `access.py` and `xship.py` check live. The
run took the logic unit tests reach: the group and grant rules, the
writer's access arms, the sweeper, and `+act` (56).

The real gaps it found:
- whether a free board's content is granted and a paid one's isn't;
- whether a board made, or given a price, resends the public grant;
- whether the sweep writes groups for paid boards only;
- whether the sweeper waits for the expiry, where the mutant asked at
  once and would have busy-looped;
- whether a poster's comment starts a cooldown.

Each now has a test (`test-public-grant-set`, `test-public-grant-resent`,
`test-sweeper`, `test-limits-and-targets`), and a second pass killed them
all. What survives:
- **unreachable**, `+take-sweep`'s news-wire check: the sweeper keeps one
  grub, so no other wire's news reaches it.
- **equivalent**, `+write-soft`'s gain flag: history kept on a group's
  files changes nothing it does.
- **equivalent**, `+sweeper` `lte->lth` at an expiry of exactly now: the
  next look sweeps.

### Mutation run, phase 5 (2026-09-29, all ops)

`--since HEAD` lists 375 mutants. The run took the payment logic, in
three slices with `--only`: lib/cashu's new arms (90), the writer's
payment arms (57), and the pay fiber with its mint calls (60). The
payment pages (`+serve-payment`, `+pay-then`, the mod page's wallet) are
checked live by `pay.py` and `api-matrix.py`. The cashu slice timed out
at its 51st mutant, twice, voiding the rest. It wasn't a spin: that
mutant (`+inputs-sum` refusing every token of 100 proofs or fewer) fails
four nexus tests whose reports print whole payment states, and together
they made a report too big for the kit to decode (exit 2, which the
runner calls a timeout). Its arm was mutated against the cashu suite
alone (all 13 killed), and so was the rest of the slice.

The real gaps it found:
- the answer checks (`+is-keys`, `+is-new-quote`) had no tests of their
  own: `test-answer-checks` now holds each to what a good answer names;
- a token at exactly the 64 KiB cap, an amount that isn't whole, a proof
  that names no keyset (`test-token-inputs`, `test-keysets-and-fees`);
- a token worth exactly the price, and the payment's id being the
  payer's and its nonce's (so an ask sent twice is one payment);
- which grubs count as a withdrawal under way (another board's, a
  payer's, a finished one don't) (`test-start-melt`);
- a word from our host about another board (`test-take-pay`);
- `+spend` and `+paying` had no tests (`test-spend`, `test-paying`, the
  latter with the week's edge);
- a token worth exactly the mint's fee, a refusal that carries
  signatures, a short answer (`test-pay-edges`);
- an invoice at exactly its expiry, and a 300 (`test-pay-expiry`);
- the whole of `+melt-wait` past its first sleep, and a melt the mint
  doesn't answer about never being given up on (`test-melt-wait`);
- `+pay-settle`'s two waits (`test-pay-settle`).

What survives:
- **equivalent**, `+select-proofs`'s sort `gth->gte`: only the order of
  equal amounts changes.
- **equivalent**, `+start-pay`'s nonce read with its branches swapped:
  both read the nonce.
- **equivalent**, `+take-response` dropping `(gte code 200)`: a mint
  sends no 1xx answer.
- **accepted**, `+pay-retry` `gte->gth` (giving up at the 100th try or
  the 101st) and `+melt-wait` `lth->lte` (ten-second polls for 30 tries or
  31): cadence, a day or a minute either way.

One survivor was redundant code, and went: `+start-pay` (and the mod
page) checked that a withdrawal under way was the host's, but only a
withdrawal is ever at `%melt` or `%melting`. The second pass killed every
other mutant in the writer and fiber slices.

### Mutation run, theming (2026-09-29, all ops)

On `lib/furum-theme.hoon` and the app's theme arms (`+set-looks`,
`+read-look`, `+talon-settings`, `+talon-entry`, `+profile-color`,
`+scry`, `+running`), 68 mutants. The page routes (`+serve-theme`,
`+theme-post`) were checked live on ~bus.

The real gaps it found: the derived hover, input and on-note colours; the
accent's hover; a theme with no id; exactly fifty themes; talon's accent
without saved themes, a custom accent not asking `%contacts`, and a
profile accent reading it. Each now has a test, and a second pass killed
them.

What survives:
- **boundary**, `+custom` and `+tint` `gth->gte` on the luminance
  thresholds (0.4 for text on a colour, 0.5 for an accent's text): only a
  colour of exactly that luminance tells them apart, and talon uses the
  same strict `>`.

## Not covered

- **The agent**: on-load migrations, HTTP routing, the iris payment state
  machines, subscriptions. The kit can't build a Gall agent. Those were
  exercised by hand across two fake ships on 2026-09-28.
- **The cap on live Lightning invoices** (3 per ship) is still inline in the
  agent, because its type lives there.
- **The render arms' `?&`/`?|` sites**, which decide which buttons show.
  The agent checks every action again, so a wrong button is cosmetic.
- **`+time-ago`, `+render-pagination`, `+urle`**: display, and the
  QR-code image url.
- **`+extract-url`'s link terminators** other than a space: the kit makes
  no mutants for a `?|` that opens mid-line.
- **The `(sub c '0')` number parsers** in `lib/cashu.hoon`'s response
  parsers still crash on a JSON number like `1.5` (a mint sends integers).

## The vendored kit

`scripts/hoon-test-kit/` is kit `13bc43f` plus two local patches. The
first: `hoon-mutate.py`'s `touched_arms` unpacked `LIBS` entries as pairs,
though they are triples, so `--since` always crashed; it now unpacks
three. The second:
`hoon-mutate.py` decodes the suites' output with `errors="replace"`. A
`+hex-char` mutant turned `%C3%A9` into a lone `0xC3`, the failure report
printed it, and the runner died on a `UnicodeDecodeError`, voiding the
run. Both patches belong upstream. Re-vendoring from a kit that has them
drops the local copies.

## For the kit's PLAYBOOK

Lessons from this rollout, about the method rather than furum. They
belong in the kit's `PLAYBOOK.md`. They are here because another session
was working in the kit repo at the time.

- **A deep pier can't be reached.** A Unix socket path over 107 bytes
  can't be connected, so a pier under a long scratch directory makes socat
  fail silently, and the runner reports exit 4 ("did not answer") for a
  healthy ship. Point the kit at a short symlink to the pier.
- **A bounded search run to its cap reads as a dead ship.** A mutant that
  makes a loop try all its iterations (hash-to-curve's 65,536 counters)
  can hold the ship past the socket timeout. The runner calls it a timeout,
  or says the ship stopped answering, and voids the run. That is right, but
  the ship may be alive: measure the worker's CPU from `/proc/<pid>/stat`
  and ask it something before calling it dead. Then leave that arm out of
  `--only` runs, and check its other mutants by hand: write each into the
  mount, run `NOSYNC=1 hoon-test.sh`, and restore.
- **`brd(field x)` on an arm changes the core, not the arm's product.** In
  a test core, a fixture arm modified in place (`brd(payment x)`) fails
  `-tack.payment`. Bind it first: `=/  b  brd` then `b(payment x)`.
- **A tall `?|` or `?&` that opens mid-line after another rune** (`?:  ?|`)
  is not found by `conjunct`. `+extract-url`'s five-clause `?|` got no
  mutants.
- **Test numbers past 999.** `dem:ag` parses Urbit's dotted `@ud`
  syntax, so `(rush '1000' dem:ag)` is `~` while `'1.000'` works. Plain
  digits from forms and JSON need `dum:ag`. No mutation operator can see a
  wrong parser choice, and cases built from small numbers pass either way:
  furum's suites had 30 green tests while every id and denomination from
  1000 up was refused.
- **Replay the historical bugs, not only mutants.** Writing each fixed bug
  back into the lib on the test desk (`NOSYNC=1`) proves the regression
  test fails for its reason, as the test-audit rule asks. Here all six were
  caught, and the feed case failed on exactly the feed entry.
- **A long grubbery-dialect run can stop the ship.** Each mutant rebuilds
  the nexus against fiberio, and ~wes stopped after about 25 of them. The
  runner said so and voided the rest. The kit had restored the clean file
  to the mount but not committed it, so the next plain run still tested
  the mutant: `NOSYNC=1 hoon-test.sh` commits the mount as it stands. Run
  such suites in slices with `--only`.
- **A "timeout" can be a report too big to read.** `hoon-mutate.py`
  calls any exit but 0, 1, 3 and 4 a timeout. A mutant whose failing
  tests print whole fiber states made a report `hoon-test.sh` couldn't
  decode (it came back as raw bytes, exit 2), so the runner said the ship
  might be spinning and voided the rest of the slice, every time. Run
  such a mutant by hand with `NOSYNC=1`, one suite at a time, before
  calling the ship stuck; mutate its arm against a conf whose `TESTS`
  holds only the small suite that covers it.
- **A helper named `test-…` is a test.** The runner runs every arm whose
  name starts with `test-`, so a fixture called `test-keys` ran, returned
  a map, and crashed the report. Name fixtures otherwise.
