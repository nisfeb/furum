# Logging: what furum says, and what it keeps

Furum follows the Foundation's logging policy (draft of 2026-10-01): a ship whose furum is
working prints nothing; a line on the console means something left its normal range and a
person can act on it; everything else is kept as state that can be read back.

## What furum says

Every line names furum first, says what is wrong, then what to do. Each is said once: when
its fault is first kept at `/tr/fault`, or when its line changes. A crash, which repairs
itself, is said again only when it comes back after two quiet hours.

| kind | level | said when | the line ends with |
|---|---|---|---|
| `web` | `>>>` | the grant lacks `/sys/eyre/` | Allow furum /sys/eyre/ (may poke) |
| `inbox` | `>>>` | the grant lacks `/sys/ames/registry` | Allow furum /sys/ames/registry (may poke) |
| `send` | `>>>` | the grant lacks `/sys/ames/ships/` to poke | Allow furum /sys/ames/ships/ (may poke) |
| `read` | `>>>` | the grant lacks `/sys/ames/ships/` to read | Allow furum /sys/ames/ships/ (may read) |
| `groups` | `>>>` | a paid board's group can't be kept, and the grant lacks `/sys/ames/usergroups/` | Allow furum /sys/ames/usergroups/ … |
| `iris` | `>>>` | a mint can't be reached, and the grant lacks `/sys/iris/` | Allow furum /sys/iris/ (may poke) |
| `registry` | `>>>` | the registry setting names a ship that keeps no directory furum can read | Set the registry ship on furum's admin page: ~ship |
| `payment` | `>>>` | a payment's record can't be read | Report it: /pay/id |
| `crash-…` | `>>` | a fiber (writer, inbox, web, prune, sweep, directory, follower, payment, request) crashed; it retries by itself | If it keeps crashing, report it with the kernel's %fiber-crash trace before this line |

Since grubbery 5ae72f0 (`dist/single-release`, 2026-10-01) the kernel says two things itself,
and furum doesn't repeat them:

- A road whose refusal parks a fiber: `>>> grubbery: <app> is parked: it may not <verb> <road>;
  grant it at /apps/grubbery/permits, then reload`, once per app, with the parked grub's bang as
  the record; the reload after an approval revives it. For furum these are `/sys/bowl.sig` and
  `/sys/behn/`, which its fibers use for every clock read and timer. Furum says only refusals it
  handles softly, which the kernel doesn't report.
- A crash: `%fiber-crash <path>` and its trace, each time. Furum's crash line comes after it,
  once per episode, without the trace.

The permission faults are judged from the shell's grant (`grant.json`), read once at the
writer's start (`+check-grant`): a road the grant lacks is said, and a road granted again
clears its fault at the next start, which every approval brings. A refusal seen while working
is said only if the grant lacks the road (`+alarm-ungranted`): a granted road refused is the
weir catching up with an approval, since the shell restarts the app before it applies the new
weir. Before any approval there is no `grant.json`; the shell is asking, and furum says
nothing.

Not said, by design:

- `/sys/bowl.sig` or `/sys/behn/` refused: the kernel's parked line says it (above).
- `/sys/push/` and `/sys/scry/` refused: furum works without them, as their weir lines say.
- Another ship refusing, or not answering: a host that has no such board, a registry that
  refuses, a mint or a peer offline. These are expected, and kept for the pages: the directory
  page says why it is out of date (`/tr/dir`); a missing board's page answers 404 (`/gone`).

Furum has no diagnostic prints, so it has no `++ dbg` flag. Debug output added later goes
behind one, with no marker, and the flag is off on every release.

## What furum keeps

Each record is one grub under the app, read with one GET of
`/grubbery/ball/apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app/<path>?info=1`.

| path | holds | bounded by |
|---|---|---|
| `/tr/fault` | each fault said: its line, when it began and was last seen, how many times | the fixed set of kinds above |
| `/tr/dir` | why the registry's directory last failed to read, from whom, when | one entry |
| `/tr/last` | the writer's last refusal | one entry |
| `/tr/inbox` | the last pokes other ships sent | a ring |
| `rise.json` | per fiber, its crashes in a row and its next try | one row per fiber |
| `/gone/<host>/<name>` | when a host last said it has no such board | the owner's own visits |

## Kept quiet in healthy operation

Some of furum's work makes the kernel print, on its own ship or another's. Furum keeps that
work to what is needed:

- A follower doesn't ask for a board's content it knows is closed to it. It asks again when the
  host says it let us in (a note on `%grant-paid`, which a settled payment also sends), or when
  the owner asks (the paid page, resubscribe).
- A board out of reach for three hours, whose host then refuses its `pub/`, is let go: its
  follower and copy are dropped, and its page answers 404 for a minute, then asks again.

## The quiet gate

Before a release, on two fake ships running it (`docs/releasing.md`), with their consoles
captured (`tmux capture-pane -p -J -S -`) and each step counted from a mark: clear the
scrollback and snapshot what is still on the screen, since `clear-history` leaves the screen,
and the unit suites print their faults' lines there when they run on the same ship:

1. Upgrade from the last release with real data in place. Furum prints nothing.
2. Reload it (`POST /apps/grubbery/permits/reload {"app": …}`). Furum prints nothing.
3. Approve its weir without one road it needs, as the permissions page does: `approve-weir`
   with the rest, then reload. Exactly one `>>>` line is said, with the remedy: furum's, kept
   at `/tr/fault` (say `/sys/ames/registry`), or the kernel's parked line, kept as the bang
   (`/sys/behn/`).
4. Approve the whole weir again. Nothing is said, the fault is cleared, and no grub is banged.

Steps 2 to 4 are `scripts/quiet-gate.py <url> <jar> <tmux pane> [road]`. A line counts when it
contains `%furum` or is the kernel's parked line for furum. Other kernel lines are below.

## Known noise

Lines that furum's work brings about and that furum doesn't print, as of grubbery 5ae72f0,
checked on two fake ships. Report them upstream (grubbery), not as furum bugs.

| line | prints on | brought about by |
|---|---|---|
| `%fiber-crash <path> in=…` and its trace, no marker | the ship whose fiber crashed | every crash, each time; furum's own line says it once |
| `>> [%veto-received-from ~x …]` | the reader of a read another ship refused | a board the host doesn't have (first contact), or content closed to the reader |
| `>> [%miss-received-from ~x]` | the reader of a read whose answer expired | a slow remote read |
| `> [%sand-applied …]` | the ship approving furum's weir | every approval: a notice |
| `eyre: replacing existing binding at /apps/furum` | the ship furum runs on | every reload of furum (eyre, a vane) |
| `>> [%desk-source-unreachable …]` | a ship whose desks follow a source it can't reach | fake ships, which can't reach the publisher; once per desk |

Gone since 5ae72f0, behind the kernel's debug flag: `%weir-veto-at`, `%process-dart-vetoed`,
`%sand-applying`, and the build and reload timings.
