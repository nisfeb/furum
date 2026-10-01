# Releasing furum: what makes the publisher update, and what makes its subscribers update

Furum is a **desk app, installed only when added** (not a stock desk): the source of truth is this git repo, one ship publishes it, and every other ship gets it from that publisher. Two separate mechanisms move a change along that path, and they fail in different ways. This file is the same in nisfeb/orrery, nisfeb/lattice, nisfeb/auspex and nisfeb/calendar, because the mechanism is identical for all five and the thing that costs hours is not knowing which half you are looking at.

Written 2026-09-15 from the grubbery kernel source (`gub/nex/desk.hoon`) and from failures measured that day on a publisher, a subscriber and a dev ship. Line references are to grubbery's `desk/gub/nex/desk.hoon`.

## The short version

```
you: git push  (ref master)
  |
  |  the publisher's forge polls the remote every 15 min  (config.json "poll": 15)
  v
the publisher's forge repo    /apps/forge.git_forge/repos/furum.git_repo/data/tree/code
  |
  |  the publisher's furum.desk watches that tree's code/version.json
  |  and pulls when it DIFFERS from its own root version.json
  v
the publisher's desk          /apps/shell.shell/desks/furum.desk/desk/code
  |
  |  the publisher REPUBLISHES the version file; subscribers watch that
  v
every subscriber's desk       source.json -> <publisher>/apps/shell.shell/desks/furum.desk/desk/code
```

**The single thing that makes anything update is `code/version.json` changing.** Not a new commit, not changed code: the version number. Everything below is detail on that one fact.

## 1. What makes the publisher update

The publisher's forge repo tracks this repo. Its config:

```json
{"token":"","ref":"master","repo":"nisfeb/furum","poll":15}
```

So a `git push` to `master` reaches the publisher **on its own within about 15 minutes**. There is no staging state for a desk app: pushing is deploying, on a timer.

To make it immediate instead of waiting for the poll, with the publisher's owner cookie:

```sh
POST $SHIP/grubbery/forge/api/run
     {"repo":"furum.git_repo","command":"pull"}
```

It answers `ok`, which means the forge accepted the command, **not** that the desk has rebuilt. The pull checks the repo out into the forge tree; the desk then has to notice.

The publisher's furum desk points at that tree:

```json
{"code":"/apps/forge.git_forge/repos/furum.git_repo/data/tree/code"}
```

A local path, not a ship. The publisher reads its own forge. (Subscribers point at the publisher over ames instead; see section 2.)

## 2. What makes the subscribers update

Every subscriber's furum desk has a `source.json` naming the publisher:

```json
{"code":"<publisher>/apps/shell.shell/desks/furum.desk/desk/code"}
```

The desk nexus keeps a subscription on the source's `code/version.json` (desk.hoon:163-186). On a `%news` for that file it runs `do-snapshot` then `sync-release`. **No user action is required**: nobody has to press Fetch Latest, and no consent prompt appears unless the release adds a road to `ask.json`.

The gate is exactly this (`+source-behind`):

```hoon
(pure:m !=(src-ver own))
```

An inequality between the source's `code/version.json` and the desk's own root `version.json`. Nothing else is compared: not file hashes, not commit ids, not timestamps.

`sync-release` then mirrors the code tree and **republishes the version file locally**, with the kernel's own comment explaining why:

> mirror the source's version file locally, under its own name, so followers of THIS desk watch our republished version

That is the relay hop. It is why a subscriber can itself be a publisher.

## 3. Therefore: bump `code/version.json` on every release

| what you did | what happens |
|---|---|
| changed code, bumped version | the publisher syncs, subscribers sync. Correct. |
| changed code, **forgot** the bump | **nothing propagates.** The publisher's forge has your commit; no desk ever pulls it. Everything looks fine and nothing shipped. |
| bumped version, no code change | the version file syncs and nothing else does. `sync-dir` is content-addressed: only real changes write, so no nexus rebuilds. |

The second row is the common mistake and it is silent. The third row matters when you are trying to force a rebuild: a version-only bump will not do it.

## 4. Verifying a release actually landed

Check all four, in this order, on the ship in question (`$SHIP`, with its owner cookie). Each separates a different failure.

```sh
# 1. did the forge fetch? (the publisher only)
GET $SHIP/grubbery/ball/apps/forge.git_forge/repos/furum.git_repo/data/tree/code/version.json?raw=1

# 2. did the desk mirror it?
GET $SHIP/grubbery/ball/apps/shell.shell/desks/furum.desk/desk/code/version.json?raw=1
GET $SHIP/grubbery/ball/apps/shell.shell/desks/furum.desk/version.json?raw=1

# 3. did the instance rebuild, or is it BANGed?
GET $SHIP/grubbery/ball/apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app?info=1
#    bang: null  = healthy.  bang: "no built nexus %furum--app ..." = dead.

# 4. does the route answer?
GET $SHIP/apps/furum        # fast 200/403 = alive.  hang = dead instance holding the route.
```

A version number is not proof. **The instance's `bang` is the proof**, and the route is the proof a user cares about.

## 5. The failure modes, all measured

### 5a. Version matches, code tree empty: wedged for ever

Measured on a subscriber, 2026-09-15. Its calendar desk read `{"version": 15}` at the root, the publisher published 15, and `code/` was **empty**: zero children. `source-behind` compared 15 to 15, answered "not behind", and never synced again. The desk page reported itself up to date. orrery's route hung for 30 seconds on every request.

The version gate is the trap: it suppresses the only thing that would refill the tree. The escape is the unconditional pull, which has no version gate:

```sh
POST $SHIP/grubbery/desk/furum/fetch-latest
```

(`+do-fetch`, desk.hoon: *"pull the source's current code now, unconditionally (no version gate)"*. The same thing runs from a `{"action":"fetch"}` poke at the desk's `main.sig`.)

### 5b. A BANGed instance is not healed by a successful sync

Same ship, same incident. After `fetch-latest` refilled the tree, orrery's app nexus compiled cleanly in 11.8s, and the instance stayed BANGed. `reload-changed-nexuses` ran for 28ms and never visited it, because a nexus that never built has no recorded refs for a changed-refs walk to follow.

It came back only when the instance was reloaded explicitly. Over HTTP, that is a form-encoded POST to the instance's own explorer URL:

```sh
POST $SHIP/grubbery/ball/apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app
     action=reload-nexus
```

So: **a clean compile does not imply a live app.** Check the bang.

### 5c. A neck-less `/desk/code` never compiles anything

A `/desk/code` that was created as a plain directory, by an older kernel, or by hand, has no `[/ %code]` neck, and a dir without that neck is not a code namespace, so grubbery never runs `build-code` over it. Files land with the right marks and nothing compiles them. The desk page says "nothing to pull" while the app is dead.

`+ensure-code-nexus` repairs it. It used to run only when the desk nexus rose, which a subscriber does not do by itself; since 2026-09-15 it also runs from `sync-release`, so an arriving release repairs it. Check the neck with:

```sh
GET $SHIP/grubbery/ball/apps/shell.shell/desks/furum.desk/desk?info=1
#    "code" child should have  neck: "/code"
```

### 5d. Symptom shapes

| symptom | usual cause |
|---|---|
| route **hangs** (no response, times out) | dead instance still holding the eyre binding |
| route **404s** | no instance bound at all |
| route **403s fast** | healthy; that is just unauthenticated |
| desk says up to date, app dead | 5a (empty tree) or 5c (neck-less dir) |

## 6. Desk apps and the kernel are delivered differently

Do not mix these up. Calendar, lattice, auspex, furum and furum are **desk apps**. Grubbery itself is the **kernel**.

| | desk app (calendar / lattice / auspex / furum / furum) | kernel (grubbery) |
|---|---|---|
| source of truth | this git repo | nisfeb/grubbery branch |
| how it reaches the publisher | `git push`, then forge poll or forge pull | copy into the publisher's clay mount, then `\|commit %grubbery` in the dojo |
| how it reaches subscribers | version bump, automatically | kiln desk sync, automatically |
| release unit | `code/version.json` | a clay commit |

Two notes on the kernel side, both learned the hard way:

- Touching `lib/*.hoon` or `app/grubbery.hoon` bumps the **gall agent**: the ship stops answering HTTP for minutes. Touching `gub/nex/*.hoon` only rebuilds a nexus, which is seconds.
- A `\|commit` that prints only `>=` with no rebuild means clay saw no change. That usually means it was already committed, not that the commit failed.

## 7. Testing before you ship

Test on a dev ship, a fake one if you have it, never on the publisher. Writing into a desk's code tree there compiles **immediately**, with no commit, which is the fast loop:

```sh
POST $SHIP/grubbery/ball/apps/shell.shell/desks/furum.desk/desk/code/nex/furum/app.hoon
     action=write-text  content=<the file>
```

Then read the instance's `?info=1`: `bang: null` means it compiled, and a non-null bang **carries the compile error with line and column**. That is about a minute per iteration. A file that does not exist yet needs `action=create-file&filename=<name>` first. `write-text` 404s on a missing file.

A `write-text` edit is not put back by a forge pull, because the version gate sees the same number on both sides and syncs nothing; the restore is another `write-text` of the committed file, or `fetch-latest`.

Fake ships derive every keypair from the `@p`, so anything key-dependent behaves differently there than on a real ship. Verify crypto paths on a real ship, not only on a fake one.

Furum's dev ships don't use `write-text`: `scripts/dev-deploy.py` mirrors `code/` into a ball directory the dev desk follows, and stamps its version (see `docs/hoon-testing.md`).

## 8. Furum's release checklist

`$A`/`$JA`/`~a` and `$B`/`$JB`/`~b` are two fake dev ships (web address, owner cookie jar, name) running the release through `scripts/dev-deploy.py`, `~a` the host and the registry for both. The setup for each step is in `docs/hoon-testing.md`.

1. `code/version.json` one higher than the last release, and `++  version` in `code/lib/furum.hoon` the same number: it is what the page footer shows, and `api-matrix.py` fails until the two agree.
2. `python3 scripts/code-closure.py code` says closed.
3. `python3 scripts/weir-check.py code/nex/furum/app.hoon --io <grubbery checkout>/desk/lib/fiberio.hoon` prints `0 reached-but-undeclared`. The `/sys/ames/ships/` lines read unused: those roads are built by `+remote`, which the check can't follow.
4. The unit suites are green: `HOON_TEST_CONF=hoon-test-nexus.conf scripts/hoon-test-kit/hoon-test.sh <pier>`. They include the crash rules: a refusing weir (`test-refusing-weir-parks`) and restarts under writes (`test-restart-under-writes`).
5. The upgrade (crash rule 7): deploy the release over the last one on a dev ship that has boards, posts and a paid board, and check the instance's `bang` is `null` before running the rest.
6. The quiet gate (`docs/logging.md`): the upgrade of step 5 prints nothing from furum, then `python3 scripts/quiet-gate.py $B $JB <tmux pane of ~b>` prints `passed`: a reload says nothing, a refused road one line (furum's, kept at `/tr/fault`, or for `/sys/behn/` the kernel's parked line, kept as the bang), and the whole grant again nothing, the fault cleared. Run it with `/sys/ames/registry` and with `/sys/behn/`.
7. On the dev ships, each prints `0 failed`:
   - `python3 scripts/api-matrix.py $A $JA ~a`
   - `python3 scripts/xship.py $A $JA ~a $B $JB ~b`
   - `python3 scripts/access.py $A $JA ~a $B $JB ~b`
   - `python3 scripts/pay.py $A $JA ~a $B $JB ~b <mint> <venv>`, against a local FakeWallet mint, never a real one.
8. Open `/apps/furum` on a dev ship in a browser: a board, a post, the theme page (System, Light and Dark, a saved theme, an accent), and the pages on a phone-width window.
9. Read `+weir-json` in `code/nex/furum/app.hoon` against the last release, and name any new line in the release note: a new road raises the consent prompt on every ship.
10. `git push origin master`, then the publisher's steps: the forge pull (or the poll), the four reads of section 4, and, when the release added a road, the consent on `/apps/grubbery/permits` followed by a reload of the instance.

### Version 1's owner steps (the first release)

Once, on the publisher, with its owner cookie. Every step here is the owner's.

1. The repo on the forge, tracking `master`:
   ```sh
   POST $SHIP/grubbery/forge/api/add  {"name":"furum","repo":"nisfeb/furum","ref":"master"}
   ```
   It answers `created` and starts the first pull. If the repo's `config.json` has no `"poll":15`, add it with `POST /grubbery/forge/api/config`.
2. The desk, following the forge tree:
   ```sh
   POST $SHIP/apps/grubbery/desks/add  {"name":"furum","code":"/apps/forge.git_forge/repos/furum.git_repo/data/tree/code"}
   ```
3. On `/apps/grubbery/permits`, approve every line furum asks for (the list is `+weir-json` in `code/nex/furum/app.hoon`). `approve-weir` replaces the whole grant, so leave none out. Then reload the instance.
4. The four reads of section 4. `bang: null` and a fast answer from `/apps/furum` are the proof.
5. The registry: the publisher's furum is the registry by default (its registry setting names itself). Make a board, then check the directory lists it.
6. Suspend the Gall agent on the ship that ran it: `|suspend %furum`. Never `|nuke`: the suspended agent keeps its state.
7. Open the desk: `POST $SHIP/grubbery/desk/furum/share {"add":"/public"}`, then `POST $SHIP/apps/grubbery/permits/refresh` so the public desk list rebuilds.
8. The announcement: where furum went, and how to add it (the desk page's code path, `<publisher>/apps/shell.shell/desks/furum.desk/desk/code`). Gall hosts start fresh on the nexus: nothing moves from the Gall agent, and a Gall client can't see a nexus host.
