# %furum Implementation Plan

A decentralized forum application for Urbit, inspired by Reddit/Hacker News.

## Naming

- **Desk**: `%furum` (Latin for "forum")
- **Subreddits** → **Boards** (simple, clear, no Reddit baggage)
- **Agent**: `%furum`

## Architecture Overview

### Ships play three possible roles (one agent, multiple modes):

1. **Registry ship** (hardcoded, e.g. `~zod` for dev) — maintains a directory of all boards and their host ships. Any ship can query it.
2. **Host ship** — any ship that creates a board. Stores that board's posts, comments, votes, and permissions. Serves data to subscribers.
3. **Client ship** — every ship with %furum installed. Fetches the board directory from registry, subscribes to host ships for board data, and serves the local web UI to the user.

Every ship runs the same `%furum` agent. The registry ship is just a host ship with a special additional responsibility.

### Communication flow:

```
Client Ship                  Registry Ship              Host Ship
     |                            |                         |
     |---subscribe /directory---->|                         |
     |<---initial board list------|                         |
     |<---updates (new boards)----|                         |
     |                            |                         |
     |---subscribe /board/[name]--------------------------->|
     |<---initial posts + metadata--------------------------|
     |<---updates (new posts, votes, etc)-------------------|
     |                            |                         |
     |---poke %furum-action (post/comment/vote)------------>|
     |<---poke-ack (success/fail)---------------------------|
     |                            |                         |
Host Ship (when creating board):  |                         |
     |---poke %furum-registry-action (register)-->|         |
     |<---poke-ack (success/fail)----------------|         |
```

### Data lives on the host ship

- Posts, comments, votes, and role assignments all live on the board's host ship
- Mods can delete any content; authors can delete their own
- Client ships cache data received via subscriptions for rendering
- The host is the source of truth; clients re-sync on reconnect

## Data Model (sur/furum.hoon)

```
:: Board identity
+$  board-name   @tas                          :: URL-safe board name
+$  post-id      @ud                           :: monotonic counter per board
+$  comment-id   @ud                           :: monotonic counter per post

:: Roles
+$  role         ?(%mod %poster %reader)

:: A board's metadata
+$  board-info
  $:  name=board-name
      title=@t                                 :: display name
      description=@t
      host=@p
      created=@da
      default-role=role                        :: what any authed urbit gets
  ==

:: A post
+$  post
  $:  id=post-id
      author=@p
      title=@t
      url=(unit @t)                            :: link post (optional)
      body=(unit @t)                           :: text post (optional)
      created=@da
      up-votes=(set @p)
      down-votes=(set @p)
      comment-count=@ud                        :: denormalized for list view
  ==

:: A comment
+$  comment
  $:  id=comment-id
      parent=(unit comment-id)                 :: ~ for top-level
      author=@p
      body=@t
      created=@da
      up-votes=(set @p)
      down-votes=(set @p)
  ==

:: Vote target discriminator
+$  vote-target
  $%  [%post id=post-id]
      [%comment post=post-id id=comment-id]
  ==

:: Full board state (on host ship)
+$  board
  $:  info=board-info
      roles=(map @p role)
      next-post-id=post-id
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
      next-comment-ids=(map post-id comment-id)
  ==

:: --- Registry types ---
+$  directory-entry
  $:  name=board-name
      title=@t
      description=@t
      host=@p
  ==

:: --- Client cache types ---
+$  cached-board
  $:  info=board-info
      posts=(map post-id post)
      comments=(map post-id (map comment-id comment))
  ==
```

## Actions (Pokes)

### Board host actions (mark: %furum-action)

```
+$  action
  $%
    :: Board management (local ship only)
    [%create-board name=board-name title=@t description=@t default-role=role]
    [%delete-board name=board-name]
    :: Moderation (from mods, validated by host)
    [%set-role name=board-name who=@p =role]
    [%remove-role name=board-name who=@p]
    :: Content (from posters, validated by host)
    [%new-post name=board-name title=@t url=(unit @t) body=(unit @t)]
    [%delete-post name=board-name id=post-id]
    :: Comments (from posters, validated by host)
    [%new-comment name=board-name post=post-id parent=(unit comment-id) body=@t]
    [%delete-comment name=board-name post=post-id id=comment-id]
    :: Votes (from readers, validated by host)
    [%upvote name=board-name target=vote-target]
    [%downvote name=board-name target=vote-target]
    [%remove-vote name=board-name target=vote-target]
  ==
```

### Registry actions (mark: %furum-registry-action)

```
+$  registry-action
  $%
    [%register name=board-name title=@t description=@t]
    [%unregister name=board-name]
  ==
```

## Updates (Subscription facts)

### Board updates (mark: %furum-update)

```
+$  update
  $%
    :: Full state for new subscribers
    [%initial info=board-info posts=(list post)]
    :: Incremental updates
    [%new-post =post]
    [%delete-post id=post-id]
    [%new-comment post=post-id =comment]
    [%delete-comment post=post-id id=comment-id]
    [%vote-update target=vote-target up-votes=(set @p) down-votes=(set @p)]
    [%role-update who=@p role=(unit role)]
    [%board-info-update info=board-info]
  ==
```

### Registry updates (mark: %furum-registry-update)

```
+$  registry-update
  $%
    [%initial entries=(list directory-entry)]
    [%add =directory-entry]
    [%remove name=board-name]
  ==
```

## Subscription Paths

### Registry ship watches:
- `/directory` — list of all boards, receive adds/removes

### Host ship watches:
- `/board/[board-name]` — posts list + metadata, incremental updates
- `/board/[board-name]/post/[post-id]` — single post with comments (for detail view)

## Scry Paths (on-peek)

### On any ship:
- `/x/boards` — locally hosted boards (map board-name board-info)

### On registry:
- `/x/directory` — full directory (list directory-entry)

### On host:
- `/x/board/[name]` — board-info
- `/x/board/[name]/posts` — (list post) sorted by score
- `/x/board/[name]/post/[id]` — post with comments
- `/x/board/[name]/roles` — (map @p role)

## Agent State

```
+$  state-0
  $:  %0
      :: Registry state (only used on registry ship)
      registry=(map board-name directory-entry)
      :: Host state (boards this ship hosts)
      boards=(map board-name board)
      :: Client cache (boards we're subscribed to on other ships)
      cache=(map [@p board-name] cached-board)
      :: Which host boards we're subscribed to
      subs=(set [@p board-name])
  ==
```

## Web UI (Sail — no JavaScript glob)

Minimalist, HN-inspired. All server-rendered HTML via Sail. Forms submit via POST. The agent handles HTTP requests directly (bound via Eyre %connect).

### Pages:

| Route | Description |
|-------|-------------|
| `/apps/furum` | Home — board directory from registry |
| `/apps/furum/b/[host]/[name]` | Board view — posts sorted by score |
| `/apps/furum/b/[host]/[name]/[post-id]` | Post detail — comments tree |
| `/apps/furum/b/[host]/[name]/submit` | New post form |
| `/apps/furum/b/[host]/[name]/mod` | Moderation panel (mods only) |
| `/apps/furum/create` | Create new board form |

### Scoring algorithm (HN-style):

```
score = (upvotes - downvotes - 1) / (hours_since_post + 2) ^ 1.8
```

### UI elements:
- Monospace/minimal CSS, no framework
- Navigation bar: `furum | boards | create | [your-ship]`
- Post list: rank, vote arrows, title (link), score, author, time, comment count
- Comment tree: indented, vote arrows, author, time, body
- Forms: plain HTML forms, POST actions

## File Structure

```
furum/
  app/
    furum.hoon                    :: main gall agent
  sur/
    furum.hoon                    :: all type definitions
  lib/
    furum.hoon                    :: helper functions (scoring, rendering, parsing)
  mar/
    furum/
      action.hoon                :: board action mark (json grab/grow)
      update.hoon                :: board update mark
      registry-action.hoon       :: registry action mark
      registry-update.hoon       :: registry update mark
  desk.bill                      :: [%furum ~]
  desk.docket-0                  :: app metadata, site+/furum
  sys.kelvin                     :: [%zuse 414]
```

## Implementation Order

### Phase 1: Skeleton
1. `sys.kelvin`, `desk.bill`, `desk.docket-0`
2. `sur/furum.hoon` — all type definitions
3. `mar/furum/*.hoon` — mark files (noun grab/grow, json can wait)
4. `app/furum.hoon` — agent skeleton with state, on-init (bind Eyre), on-save/on-load

### Phase 2: Host & Registry Logic
5. Board CRUD — create/delete boards in on-poke
6. Registry — register/unregister logic, on-watch for /directory
7. Post/comment/vote — on-poke handlers with permission checks
8. Subscriptions — on-watch for /board paths, %give %fact for updates

### Phase 3: Client Logic
9. on-agent — handle incoming subscription updates, populate cache
10. Subscribe to registry on init, subscribe to boards on user action
11. Scry paths (on-peek)

### Phase 4: Web UI
12. Eyre HTTP handling — parse requests, route to handlers
13. `lib/furum.hoon` — Sail rendering helpers, scoring
14. Board directory page (home)
15. Board view page (post list)
16. Post detail page (comment tree)
17. Post submission form + POST handler
18. Vote handling via POST
19. Moderation panel

### Phase 5: Polish
20. Comment threading (nested display)
21. Error pages and edge cases
22. CSS styling (inline, HN-minimal)
23. State migration testing

## Key Design Decisions

1. **Single agent** — simpler than splitting registry/host/client into separate agents. The state union is small and the modes are mostly orthogonal.

2. **Sail (server-rendered HTML)** — no JavaScript build pipeline, no glob. Simpler distribution, simpler development. Every action is a form POST or link click.

3. **Host-authoritative** — the host ship validates all permissions. A malicious client can send bad pokes, but the host rejects them. `src.bowl` is cryptographically verified by Ames. Mods can delete any post or comment; authors can delete their own.

4. **Voting by set** — storing votes as `(set @p)` per post/comment prevents double-voting at the data level and allows vote count derivation.

5. **Flat comment storage** — comments stored in a flat map with optional parent references. The tree structure is computed at render time. This simplifies CRUD operations.

6. **Cache on client** — client ships cache board data locally. This means the UI renders from local state (fast) and updates arrive via subscriptions (eventually consistent).

7. **Registry is a convention** — the hardcoded registry ship is just a ship running the same agent. Later, this could become configurable or multiple registries could be supported.

## Open Questions for Review

1. **Board naming**: Should board names be globally unique (enforced by registry) or scoped per host (same name on different hosts is fine)?
   - Recommendation: Scoped per host. The registry key is `[host board-name]`. Simpler, more decentralized.

2. **Default role for new boards**: Should new boards default to `%poster` (anyone can post, like Reddit) or `%reader` (must be granted poster, more curated)?
   - Recommendation: `%poster` as default, configurable by the board creator.

3. **Hardcoded registry ship**: What `@p` to use for development?
   - Recommendation: `~zod` for fakeship dev, make it a constant in the agent that's easy to change.

4. **Board discovery beyond registry**: Should ships be able to manually add boards by `[host name]` without the registry?
   - Recommendation: Yes, the subscribe-to-board action should work with any `[host name]` pair regardless of registry listing.
