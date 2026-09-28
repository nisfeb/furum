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

## Not covered

- **The agent**: on-load migrations, HTTP routing, the iris payment state
  machines, subscriptions. The kit can't build an agent. Those were
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

`scripts/hoon-test-kit/` is kit `13bc43f` plus one local patch:
`hoon-mutate.py` decodes the suites' output with `errors="replace"`. A
`+hex-char` mutant turned `%C3%A9` into a lone `0xC3`, the failure report
printed it, and the runner died on a `UnicodeDecodeError`, voiding the
run. The patch belongs upstream. Re-vendoring from a kit that has it drops
the local copy.

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
