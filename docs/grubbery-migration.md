# Moving furum to grubbery

A plan for rebuilding furum as a grubbery nexus, the way auspex and lattice
were built, and for moving live boards off the `%furum` Gall agent without
losing a post, a vote or a sat. Written 2026-09-28 against the grubbery
kernel ricsul runs (`nisfeb/grubbery` `dist/single-release`, 79c66b9) and
against auspex (release 17), lattice (32), orrery (60) and armillary (12)
as they stand on disk. Nothing here has been built yet.

## Decisions

Made by the owner on 2026-09-28:

1. **A clean break, no bridge.** Grubbery ships talk to each other through
   the kernel (`/sys/ames/ships/<ship>/root/…`), not through Gall
   subscriptions, so a grubbery host and a Gall client can't see each other,
   and nothing will translate between them. (Lattice deleted three bridges in
   one audit: 635c220, "burn the corpses of three migrations".)
   - The last Gall release (0.6) tells its users where furum went.
   - The registry and the known hosts move together, with an announcement.
   - Gall clients left behind stop receiving updates from moved hosts, and
     their banner says why.
2. **The registry runs on `~ricsul-bilwyt`**, the ship whose grubbery
   publishes the desks. The Gall registry and the boards it hosts live on
   `~ricsul-bilwyt-dozzod-nisfeb` today, so they move ships as well as
   frameworks ("Re-hosting", under migration).
3. **Installed only when added**, never as a stock desk.
   - A user adds it by code path: `~ricsul-bilwyt/apps/shell.shell/desks/furum.desk/desk/code`
     on the desk page, or `POST /apps/grubbery/desks/add {name, code}`.
   - It is not in the shell's `+published` list.
   - Opening the desk to `/public` (the `share.usergroups` poke) is the
     owner's step, never Claude's.

Taken as recommended unless the owner says otherwise:

4. **Keep server-rendered Sail.** `lib/furum.hoon` is 2,900 tested lines that
   don't care what calls them, and grubbery compiles Sail like any Hoon.
5. **Keep Cashu at the host**, each payment in its own fiber (below).
   Armillary's BTCPay checkout is the alternative if hosts would rather run a
   merchant server than hold ecash.

## What changes, in one table

| furum on Gall | furum on grubbery |
|---|---|
| hand-rolled `/board/<name>` subscription: `%initial` dump, then 13 fact kinds | followers `keep` the host's board directory; waves name what changed; they peek only those grubs (content-addressed) |
| `has-paid-access` checks, kicking unpaid subscribers | a per-board **usergroup** of members whose weir grants peek on that board's content; a ship outside it can't read the content at all |
| `?> (can-post …)` in every poke handler | the same rules (`lib/furum-rules`), behind an **inbox** fiber that holds the only public poke road |
| payment state in three maps, wiped on reload (fixed last round, still fragile) | one grub per payment, its fiber resuming from its own state after any restart |
| wallet as a list per mint, one noun | proof grubs kept with `gain`, so every spend and receipt stays in version history |
| backups to clay by hand (`%backup-to-clay`) | the ball's own version history, plus `GET /grubbery/api/tar` exports |
| a vendored web-pusher and its own service worker | the kernel's `/sys/push` (VAPID, subscriptions, pruning) |
| `/x/api/*` scry for MCP | tools in `code/lib/tools` (needs the kernel's MCP discovery to walk desks, as orrery patched) |
| one `%furum` agent, the whole app trusted | a sandboxed instance: every system road asked for, explained, and approved on `/apps/grubbery/permits` |

## Target architecture

### The desk (repo layout)

```
code/
  bill.json         {"furum.furum_app": "/furum/app"}
  version.json      {"version": 1}          the only release trigger
  tile.json  icon.svg
  nex/furum/app.hoon                        the nexus
  nex/furum/assets/…                        css, sw, favicon (named with extensions clay knows)
  lib/furum-rules.hoon  lib/furum.hoon  lib/cashu.hoon  lib/furum-web.hoon (request decoders)
  mar/furum/…                               every marc the blots use, noun passthroughs
  mar/{json,mime,sig,ships,time,timer-wake,bowl-req,http-request,…}   vendored ("guests distribute every marc they use")
tests/lib/…   hoon-test.conf (DIALECT=grubbery)   scripts/{code-closure.py,weir-check.py,api-matrix,xship}
```

- The libs lose their `/-` and `/+` runes. Ball code imports with `/<`, and
  the compile subject already has `tarball`, `nexus`, `io`, `html-utils`
  and zuse.
- Keep them import-free where possible, so the kit builds them on a clay
  test desk as well (auspex's and armillary's rule).
- Copy `code-closure.py` and `weir-check.py` from auspex or lattice. The
  first checks that every import and marc resolves inside `code/`. The
  second maps every io arm to the roads it really reaches and diffs that
  against `weir.json`.

### The ball on a host

```
<instance>/                  /apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app
  weir.json link.json tile.json manifest.json     %over, from arms (weir.json is the consent ask)
  main.sig                   THE WRITER: every mutation, in order
  inbox.sig                  public poke road: remote posts, comments, votes, mod actions, joins
  notify.sig                 public poke road: notifications from hosts about our posts
  ui/main.sig  ui/requests/<eyre-id>              bind /apps/furum, one fiber per request
  boards/<name>/
    card                     title, description, host, price, mint, public?  (readable by anyone)
    roles                    ship -> role
    content/                 the member-only part (for paid boards; see "Access")
      posts/b<k>             posts k*100 .. k*100+99: title, url, body, author, created
      threads/b<k>           the comments on those posts (capped per post)
      votes/b<k>             votes on those posts and their comments
      pins  sidebar
  members/<name>             ship -> paid-until (drives the board's usergroup)
  pay/<nonce>                one payment, its fiber resuming from this state
  wallet/<mint>/proofs       gained: history is the ledger
  follows/<host>/<name>      one follower fiber per followed board
  cache/<host>/<name>/…      the mirror a follower keeps (content only; re-syncable)
  seen/  notes/  prefs       unread marks, notifications, dark mode
  registry/                  only on the registry ship: directory, admins, inbox
  rise.json  tr/last  tr/inbox                    crash record and refusal traces
```

**Why buckets of 100 posts.** Spike A measured the alternatives (Phase 0
results).
- A grub per post made a 2,500-post board reload in 68 s, blocking the
  ship on every deploy. It also sent every follower the full
  7,500-version map on every vote.
- Buckets keep a board at a few dozen grubs. The reload cost vanishes,
  waves stay small, and a bucket rewrite takes 0.3 s.
- Posts, threads and votes are parallel buckets. A vote rewrites only a
  votes bucket, and a comment only a threads bucket.

Every persistent directory gets a `[%fall %| … empty-dir:loader]` row. The
loader's `spin` drops anything no row covers, on every load.

### Fibers

- **The writer (`main.sig`)** owns every mutation, in auspex's shape.
  - It takes a poke, applies it, answers whether the tree changed, and loops.
  - It never crashes: a refusal is written to `/tr/last` and returned as `%.n`.
  - It rises with orrery's or lattice's `+rise-later` and `+take-kick`,
    `+soft-behn` and `+soft-now`. Copy those exactly. Never use `rise-wait`,
    which drops the poke that wakes it.
- **The inbox (`inbox.sig`)** is the only surface strangers can poke.
  - It reads the sender from the transport (`get-poke-src:io from`), never
    from the payload.
  - It clams the payload under `mule` against noun-passthrough marcs.
  - It runs the rules in `lib/furum-rules`: roles, paid access, caps, rate
    limits, and a ban list, because weirs can't deny.
  - It forwards accepted operations to the writer and refuses the rest
    silently into `/tr/inbox`. That is a separate ring, so strangers can't
    flush the owner's log.
  - Lattice's `/comments.sig` and armillary's `/inbox.sig` are this shape.
- **Request fibers** (`http-dispatch:io`) answer from what they peek.
  - Writes go through the writer with a local poke.
  - They answer 503 while the writer recovers (lattice `+crash-503`).
- **Workers** keep network round trips off the writer: a follower per
  followed board, a fiber per payment, the membership sweeper, the prune
  tick. They report back with local pokes, and only the writer writes the
  board.

### Access: weirs and usergroups

This is where grubbery pays for itself. Weirs gate what a ship can reach at
all; the rules in `lib/furum-rules` still decide what a reached action may
do.

- **The consent ask (`weir.json`).** Each road carries a `why` that says what
  refusing costs. Optional roads degrade a feature instead of failing: probe
  first, as auspex's `/caps` does, and use the `-soft` io arms.

  | road | kind | why |
  |---|---|---|
  | `/sys/bowl.sig` | poke | time and entropy; every io arm needs it |
  | `/sys/eyre/` | poke | the web interface |
  | `/sys/behn/` | poke | timers: prune, membership expiry, payment polling, follower retries |
  | `/sys/ames/ships/` | poke, peek | talk to other furum ships: follow boards, post, comment, vote |
  | `/sys/ames/registry` | poke | open your boards and inbox to other ships (needed to host) |
  | `/sys/ames/usergroups/` | make, peek | member and moderator groups for paid boards (optional) |
  | `/sys/iris/` | poke | Cashu mints, for paid boards (optional) |
  | `/sys/push/` | poke | browser notifications (optional) |
  | `/sys/scry/` | poke | S3 upload settings from `%storage`, and the one-time import from the old agent (optional) |

- **Public grants** go through the registry, as auspex's `+grant-public`
  does. The writer calls `reg-register-at-soft:io` on its own rail, then
  `reg-how-soft:io /public [make poke peek]`, carrying the *complete* public
  set every time.
  - **The writer itself sends both.** The registry drops a `%how` from any
    other fiber silently (spike B), and it strips the grants when the
    registrant dies.
  - The set is:
  - **poke** on `inbox.sig` and `notify.sig`;
  - **peek** on each board's `card` and `roles`;
  - **peek** on `content/` for free boards only.
- **Paid boards** get a group per board, `furum/<name>.grp`.
  - Its `who.ships` is the board's moderators plus its paid members, and its
    `how.weir` grants peek on that board's `content/`, with absolute roads
    under our prefix (orrery's `+ug-set`).
  - The membership sweeper rewrites `who.ships` from `members/<name>` when a
    payment lands, and on a timer set for the next expiry.
  - Then it sends the group's `%how` again through the registry, which
    recomputes every peer's weir at once. A direct file write would wait
    for the peer's next contact (spike B).
  - A reader outside the group gets a veto on content: the kernel does what
    `has-paid-access` and the kick did.
- **Never publish board content in the remote-scry farm.** Keen isn't
  weir-gated, so anyone can read the farm. Only the public directory may go
  there, and even that can stay behind a `/public` peek grant.

### Following boards (the client side)

- A follower fiber per board runs `keep-soft` on
  `/sys/ames/ships/<host>/root/<host's install>/boards/<name>/`.
  - Each wave's `cass` per lane says which grubs changed.
  - It peeks those shallowly (a deep peek pulls a whole subtree), reads each
    one with `sang-noun` and `;;` under `mule`, and mirrors it into
    `cache/<host>/<name>`.
- **No kick, no resubscribe, no notice of revocation** (spike B: a revoked
  follower waits forever, and re-adding it doesn't restore news).
  - Followers retry `keep-soft` with backoff (the desk nexus's
    `+await-source` does this).
  - On a timer they re-subscribe and re-peek the card, reading `%veto` as
    access lost ("renew to keep reading").
  - Waves are whole version maps, so diff each against the last to find
    the buckets that changed.
- **Where is furum on the peer?**
  - Registry entries carry each host's install path, which the host reads
    from its own `grant.json` `here` (spike D).
  - For a direct link, try the standard desk path, then ask the registry.
  - Auspex's hardcoded `+remote-install` is the known wrong answer.
- **Remote pokes don't report their ack to a nexus fiber.** A timeout means
  "unknown", never failure. The optimistic post and comment already in furum
  fit this. Confirm them when the wave brings them back, which is what
  `merge-comment` already does.

### Notifications

- The host's writer pokes the author's `notify.sig` about comments and
  replies, as the Gall host does today.
- The author's ship stores the note and calls `send-push:io` for its own
  browsers. The kernel's push ignores `tags`, so furum filters by its own
  preferences before sending.
- Subscribing a browser uses the kernel routes under `/grubbery/push/`.
  Nothing in the sibling apps subscribes a browser yet, so furum's
  "notifications: on" button is new work against those routes.

### Payments

- **One grub per payment** (`pay/<nonce>`). Its state is the step it is on:
  keys, swap, quote, check, mint, melt. Its fiber resumes from that state
  after any restart. That ends the class of bug fixed last round (in-flight
  payments wiped by reloads, polls killed by a dropped connection) by
  construction.
- **Check before redoing.** After a restart mid-swap or mid-melt, ask the
  mint which proofs are spent (NUT-07 `checkstate`) and recover signatures
  (NUT-09 `restore`) instead of redoing or forgetting. The Gall version
  can't.
- **The wallet** is proof grubs with `gain` on. Every receipt and spend is a
  version, which is the audit trail and the backup.
- **Lightning invoices go to the payer's inbox**, not to a subscription path.
  The payer's ship pokes the host's inbox to ask, and the host pokes the
  invoice back. Armillary's `docs/channel.md` has the nonce and timeout
  rules for this.
- **Unchanged from last round:** the host's configured mint only (else the
  known public mints), and the per-ship cap on live invoices.

### The registry

- A `registry/` subtree, laid only when `our` is `~ricsul-bilwyt` (the
  constant changes from the Gall agent's `~ricsul-bilwyt-dozzod-nisfeb`).
  - `directory`: public peek, or a farm spur since it is public.
  - `admins`
  - `registry/inbox.sig`: public poke, holding the first-registrant rule and
    `valid-board-name` from last round.
- Readers keep the directory as they keep a board.

### Web UI

- **Keep the routes and the pages.** Request fibers render with
  `lib/furum.hoon` and answer mime. Owner routes need
  `&(authenticated.req =(src our))`, which is orrery's `+identify`.
- **Public boards stay readable without login.** Grubbery forwards
  unauthenticated requests too, and the fiber decides.
- **The cross-site check moves as it is** (orrery's `+request-refusal` does
  the same).
- **Bind dot-free paths** (`/apps/furum`). A dotted segment reads as a file
  extension.
- **Optional:** live refresh through a beacon grub and the kernel's keep-SSE,
  as auspex and orrery do. It is owner-only, so public pages would poll.

## Migrating the live data

The lattice cutover (2026-07, `lattice` git history, `docs/cutover-runbook.md`
before 635c220) is the precedent. It was a hard cutover with brief
downtime, an export over scry, an import through a nexus action, and the
old agent kept for rollback.

1. **A last Gall release (0.6).** It adds `/x/export/noun`: a versioned noun
   of the whole state (boards with wallets and `paid`, registry, admins,
   followed, notifications, seen marks, prefs). Caches are left out; they
   re-sync.
   - It stops taking new payments and invoices, and says why.
   - It shows a banner saying furum is moving.
   - It waits for pending swaps, melts and mints to drain before the export
     is taken.
2. **Import, owner-initiated** (`POST /api/import`, lattice's
   `+handle-legacy-migrate`):
   - First `%gu` (an absent agent's `%gx` crashes the event).
   - Then `typed-scry` the export, and clam it with a frozen copy of
     state-16's types under `mule`.
   - Write in capped batches through the writer.
   - Write a `legacy/state` marker only when nothing was left behind.
3. **Verify before switching**, with numbers from both sides:
   - boards, posts, comments and votes per board;
   - roles;
   - paid-until per member, which becomes group membership;
   - **proof count and sats per mint**, which must match exactly.
4. **Cut over.**
   - Grubbery's `/apps/furum` binding shadows the agent's, which is why the
     export goes over scry.
   - `|suspend %furum`; never `|nuke`, since the suspended agent is the
     rollback.
   - Rehearse on a fake ship holding a copy of production's export before
     touching production. Production steps are the owner's to run.

### Re-hosting (moon to `~ricsul-bilwyt`)

The Gall registry and its boards are on `~ricsul-bilwyt-dozzod-nisfeb`, and
the grubbery registry will be on `~ricsul-bilwyt`. A board's identity is
`host/name`, so boards that move also move URLs: `/b/~ricsul-bilwyt-dozzod-nisfeb/<name>`
becomes `/b/~ricsul-bilwyt/<name>`.

- **The export has to travel between ships, so the import takes a file as
  well as a scry.** The 0.6 Gall release writes its export noun to clay, as
  `%backup-to-clay` already does. The owner copies the jammed file out of
  the moon's pier. `POST /api/import` on `~ricsul-bilwyt` accepts it as the
  request body (owner-only, size-capped, clammed under `mule` like the
  scry path).
- **The import rewrites the host.**
  - Every board's `host` and the registry entries become `~ricsul-bilwyt`.
  - Posts, comments, votes and roles carry over.
  - A role held by the moon itself becomes a mod role for the new host.
  - `paid` carries over into the new member groups.
  - Wallet proofs are bearer tokens, so they move unchanged. Verify the sats
    per mint on both sides.
  - The moon keeps its copy for rollback. A mint refuses a proof spent
    twice, so once `~ricsul-bilwyt` spends any, the moon's copies of those
    are worthless. A rollback re-checks its proofs with the mint (NUT-07)
    before showing a balance.
- **Old links redirect.** The moon's last Gall release answers its old board
  and post URLs with a 301 to `~ricsul-bilwyt`'s, until it is retired.
- **Registry entries for boards hosted elsewhere** carry over as they are.
  Their hosts re-register when they move.

## Phases

Sizes are relative (S under a week, M one to two weeks, L more), since the
spikes can move them.

| # | phase | size | done when |
|---|---|---|---|
| 0 | **spikes** (below) | S each | **done 2026-09-28**: see Phase 0 results |
| 1 | skeleton: desk layout, on-load rows, `weir.json`, writer, inbox, request dispatch, crash handling, kit with `DIALECT=grubbery`, closure and weir checks | M | an empty instance installs, asks, rises, answers, and passes crash rules 8 and 9 |
| 2 | host: boards, posts, comments, votes, roles, pins, sidebar, prune, caps, rate limits, the Sail pages, CSRF, public view | L | every current page and host action works on one ship; the ported suites and fiber tests pass |
| 3 | network: follow by keep, remote writes by inbox, notifications, the registry | L | an xship script (two ships) follows, posts, comments, votes and gets notified, both ways |
| 4 | access: public grants, member groups, moderator groups, revocation | M | a non-member is refused content by the weir; a lapsed member loses it within the sweep interval |
| 5 | payments: payment grubs, wallet, Lightning and ecash, NUT-07/09 recovery, membership sweeper | L | pay, lapse and renew end to end against a test mint (nutshell `FakeWallet`), surviving a reload at every step |
| 6 | migration: the 0.6 Gall release (export, payment freeze, banner, redirects), import by scry and by file, re-hosting, verification | M | a copy of the moon's export imports on a fake `~ricsul-bilwyt` stand-in, re-hosted, with every count and every sat matching |
| 7 | cutover and release: ricsul's forge and `furum.desk` (not stock), then the registry and the moon's boards on `~ricsul-bilwyt`, then the other hosts, then the announcement | S | `~ricsul-bilwyt` runs the nexus; the moon's agent sits suspended; crash rules 7, 8 and 9, api-matrix and xship all pass on the release; the owner has opened the desk to `/public` |
| 8 | later: MCP tools, live refresh, keen for immutable post revisions, eauth guests | — | as wanted |

### Phase 0 results (2026-09-28)

Measured on two fresh fake ships (~bus hosting, ~wes reading, zuse 408)
running ricsul's kernel (`dist/single-release` 79c66b9), with a throwaway
probe nexus (`~/software/furum-spikes/spike/app.hoon`). Timings are from a
busy dev machine: read them as ratios.

**A. Grain: bucket the posts. One grub per post does not scale.**

| 2,500 posts as | grubs | seed | nexus reload | follower wave | deep remote read |
|---|---|---|---|---|---|
| a directory per post (post, thread, votes) | 7,500 + 2,500 dirs | over 5 min, slower per batch as the board grew | **67.8 s** (13.8 s at 1,000 posts) | 7,500 entries, **every edit** | 12.1 s |
| one grub per post, one directory | 2,500 | 4.4 min (each write slower as the directory grew: 60 ms, then 148 ms) | 28.6 s | 2,500 entries | — |
| **buckets of 100 posts** | **25** | **2.0 s** | **8.0 s, the empty baseline** | **25 entries** | **1.0 s** |

- A reload runs on every deploy and every kernel commit, and the ship
  answers nothing meanwhile. Its cost grew faster than the grub count.
- A write into a directory costs more as the directory fills.
- A wave carries the version of every grub in the kept directory, not a
  diff, so fine grain sends thousands of entries to every follower on
  every vote.
- Rewriting a bucket took 0.3 s. An identical rewrite makes no new version
  and wakes no follower.
- Deleting a 2,500-post tree took 1.7 s.
- **Decision:** posts, threads and votes live in parallel buckets of 100
  posts by id (below), and caps bound a bucket's size.

**B. Reading, subscribing and granting across ships: it works, with four
rules.**

- With no grant, a remote peek comes back `%veto` in about 1 s, and a poke
  is nacked at once with `%peer-vetoed`. So `poke-soft` sees refusals.
  (August's notes recorded 40 s hangs and unobservable acks; this kernel is
  better.) A `keep` without a grant just times out, so use `keep-soft`.
- **Grants must be sent by the registered fiber itself.** The registry
  finds a `%how` by the sender's exact rail. A `%how` from a request fiber
  is dropped, while the poke still acks, and nothing says so. The writer
  registers and sends every grant, and it must stay alive: the registry
  strips a registrant's grants when it dies.
- **Route member changes through the registry.** A `%how` recomputes every
  peer's weir at once, both grant and revoke. A group file written directly
  (orrery's `+ug-set`) only takes effect on the peer's next contact. The
  sweeper writes `who.ships`, then sends the group's `%how` again.
- **Revocation cuts the subscription but never tells the subscriber.** The
  host's `+audit-weir` drops the keep: no news leaked after the revoke. But
  the follower gets no `%fell` and waits forever, and news does not resume
  when the ship is re-added. Followers re-subscribe on a timer, and read a
  peek's `%veto` as "access lost".
- Waves are whole version maps: diff them against the last one to find
  what changed. News arrived 1.0 to 1.9 s after the edit.

**C. Eauth.** Read in 408's eyre, `authenticated` is still the owner only
(`?=(%ours -.identity)`).
- An eauth session's `src` is the real ship.
- A guest's `src` is a random 128-bit @p, so always clan `%pawn`.
- So a host can accept a non-comet `src` as a proven identity for posting
  from its website, and treat every comet as a guest.
- Eyre's cookie still has no `SameSite`, so the cross-site check stays.
- The live check comes with phase 8, when the feature is built.

**D. Finding a peer's install.**
- On approval the shell writes `<root>/grant.json` with `here`, the app's
  absolute path (`shell.hoon` `+do-approve-weir`). So the host knows where
  it lives without `/sys/link` or `get-here-abs`.
- **Registry entries carry that path.**
- A reader following a direct link probes the standard path
  (`/apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app`) first,
  then asks the registry. A wrong path and an ungranted one both come back
  as a quick `%veto`, which is why the registry must carry the path.

**E. Push.**
- The kernel serves its service worker at `/grubbery/push/sw` with
  `Service-Worker-Allowed: /`, so furum's pages can register it at scope
  `/apps/furum/`.
- `/grubbery/push/{vapid-key,subscribe,unsubscribe}` take the
  `{endpoint,p256dh,auth}` body furum's button already sends: changing
  its base URL is the whole port.
- Subscriptions are per ship and shared by every app. A browser check comes
  with phase 3.

**Found on the way:**
- **`dem:ag` refuses plain numbers from 1000 up** (it wants `1.000`).
- It lost the spike's seeding, and furum used it in three places:
  - votes on ids past 999 were refused;
  - replies to such comments became top-level;
  - `parse-keys`, lifted the same day, dropped every denomination from
    1024 sats up, which would lose those proofs.
- All fixed with `dum:ag` behind a tested `parse-id`. See
  `docs/hoon-testing.md`.

### Spikes (phase 0), as planned

- **A. Scale.** 5,000 posts at three grubs each, plus comments: cold-start
  time, memory, and the cost of a `validate-marks` walk. Decides the grub
  grain.
- **B. Keep across ships under grants.**
  - Does a `/public` peek grant let a stranger keep a board directory on
    this kernel?
  - Does adding and removing a ship in `who.ships` take effect without its
    next inbound contact? (The kernel map found no recompute on a
    `who.ships` edit.)
  - Does a revocation reach the subscriber at all?
- **C. Guests through eauth.** What do `src` and `authenticated.req` carry
  for a foreign ship's eauth session, and for a guest's, on 408? On 409's
  eyre, `authenticated` is the owner only. Decides whether a ship without
  furum can post from the host's website.
- **D. Finding a peer's install.** The standard path versus `/sys/link`
  across ships, including the `+validate-weir-roads` question the kernel map
  raised about `/sys/link` roads in a `/public` grant.
- **E. Push.** The kernel's service worker and scope against furum's pages
  and PWA manifest.

## Rules that carry over (read before writing fiber code)

- The crash-loop rules: kit `PLAYBOOK.md` "Never ship a crash loop", and
  lattice memory `reference/grubbery-crash-loops`.
  - The first step takes the kick.
  - Back off between retries.
  - Refuse pokes while parked.
  - Every read of stored state is total (`mole`, a fallback).
  - Caps on every data-driven loop.
  - Validate at the door.
  - Test the upgrade (7), a refusing weir (8), and restarts under writes (9)
    before every release.
- Every road a fiber reaches must be in `weir.json`, including roads hidden
  inside io arms. `nonce`, and so almost everything, needs `/sys/bowl.sig`.
  `weir-check.py` enforces it.
- Persisted marcs are noun passthroughs, and readers upgrade by version
  (`;;` the new shape, then the old one, then a default). A typed marc on
  stored data is a migration bomb (lattice deploy trap 13).
- Public poke handlers never crash. One malformed noun that crashes a fiber
  makes it eat the next good poke.
- A keen-published spur grows its case on every grow. Grow only when the
  content changed.
- `keep`, `drop` and `take-news` never see a `%veto`, and a fiber waiting on
  them hangs. Use `keep-soft` with a deadline.
- `take-client-response` isn't wire-scoped. Iris answers after a timeout can
  cross; orrery's `+answer-fits` guards it.
- The mount commits wholesale. Deploy through the desk (write-text or a
  version bump), never a one-file mount commit.

## Tests

- **The kit with `DIALECT=grubbery`.**
  - `LIBS` holds the libs and the nexus itself.
  - `PRELUDE` holds the faces the nexus uses (`tarball nexus io …`), and
    `SHIP_FILES` their kernel libs.
  - The fiber tests (`hoon/fiber-test.hoon`) enter through `+on-file` and
    assert the pokes and responses each fiber sent: writer, inbox and
    request routes.
  - The crash-handling cases use `refuse` and `nack`.
- **The 30 lib tests** come across as they are. `furum-rules` grows the
  inbox's decisions.
- **Mutation-test** every lifted decision, and run `--since` after each
  change (`docs/hoon-testing.md`).
- **Live:** an api-matrix over every route, including every refusal the API
  promises, and an xship script between two fake ships. Payments get a
  local nutshell mint with `FakeWallet`, so no real sats move in tests.

## Sources

- **Kernel:** `~/software/personal/grubbery`, branch `dist/single-release`.
  - `desk/app/grubbery.hoon`: `+process-dart`, `+allowed-loud`,
    `+compute-peer-weir`, `+handle-ames-registry`, `+forward-http`,
    `+handle-push-action`.
  - `desk/lib/fiberio.hoon`
  - `desk/gub/nex/{desk,shell}.hoon`: the permits flow, `bill.json`,
    `share.usergroups`.
- **auspex:** the writer, `+grant-public`, `+weir-json`, noun-passthrough
  marcs, `docs/releasing.md` and `docs/distribution-runbook.md`.
- **lattice:**
  - `+rise-later` and `+crash-503`
  - `+peer-base`, `+remote-road` and `keep` followers
  - `/comments.sig`, the legacy import, `+carry-old-data`
  - `docs/{platform,grubbery-ops,releasing}.md`
- **orrery:**
  - `+identify`, `+request-refusal` and `+route-of`
  - `+scry-soft`, `+gall-poke-wait`, `+ug-set`
  - `docs/{sharing,releasing}.md`
- **armillary:** `docs/{channel,payments}.md`.
- **Memory (lattice on ricsul):** `reference/grubbery-crash-loops`,
  `project/lattice/grubbery-fiber-deploy-traps`,
  `project/orrery/release-procedure`, `dev/lattice-grubbery-migration`,
  `project/lattice-mesa-keen-tune-vs-sage`.
