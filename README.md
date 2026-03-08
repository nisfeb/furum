# %furum

A decentralized forum for Urbit, inspired by Reddit and Hacker News. Server-rendered with Sail — no JavaScript, no glob.

## Features

- **Boards** — any ship can create and host a board; data lives on the host
- **Posts & comments** — link posts, text posts, and threaded comments
- **Voting** — upvote/downvote on posts and comments, HN-style ranking
- **Roles** — mod, poster, reader — per-board, configurable default
- **Registry** — central directory of boards with tagging and curation
- **Dark mode** — toggle per-user, persisted in agent state
- **Decentralized** — every ship runs the same agent; the registry is just a convention

## Architecture

Every ship with `%furum` installed runs one Gall agent that can act in three modes:

1. **Registry** — maintains a directory of all boards (hardcoded to `~zod` for dev)
2. **Host** — stores boards, posts, comments, votes, and permissions; serves data to subscribers
3. **Client** — subscribes to the registry and host ships, caches data locally, serves the web UI

Communication uses standard Urbit primitives: pokes for actions, subscriptions for real-time updates, and scries for reads.

## Web UI

All pages are server-rendered HTML via Sail. No JavaScript build pipeline.

| Route | Page |
|-------|------|
| `/apps/furum` | Home — curated boards |
| `/apps/furum/curated` | Curated boards only |
| `/apps/furum/tag/:tag` | Boards filtered by tag |
| `/apps/furum/registry` | Registry admin panel |
| `/apps/furum/create` | Create a new board |
| `/apps/furum/b/:host/:name` | Board — posts sorted by score |
| `/apps/furum/b/:host/:name/:id` | Post detail — comment tree |
| `/apps/furum/b/:host/:name/submit` | New post form |
| `/apps/furum/b/:host/:name/mod` | Moderation panel |

## Installation

### From another ship

If the host ship has `%furum` published:

```
|install ~host-ship %furum
```

### Development (fakeship)

1. Boot a fakeship:
   ```
   urbit -F zod
   ```

2. Copy the desk into the fakeship's pier:
   ```
   cp -r desk/* /path/to/zod/furum/
   ```

3. In the dojo:
   ```
   |merge %furum our %base
   |mount %furum
   |commit %furum
   |install our %furum
   ```

4. Visit `http://localhost:8080/apps/furum`

### Deploying to a real ship

1. Copy the `desk/` contents into your ship's pier under a `furum/` desk
2. In the dojo:
   ```
   |merge %furum our %base
   |mount %furum
   |commit %furum
   |install our %furum
   ```
3. To make it installable by others:
   ```
   :treaty|publish %furum
   ```

## Project structure

```
furum/
  desk/                         <- distributable desk
    app/furum.hoon              <- main Gall agent
    lib/furum.hoon              <- rendering, scoring, parsing helpers
    sur/furum.hoon              <- type definitions
    mar/furum/                  <- mark files (action, update, registry-*)
    desk.bill                   <- agent manifest
    desk.docket-0               <- app metadata
    sys.kelvin                  <- kelvin version
  PLAN.md                       <- architecture and design notes
  icon.jpg                      <- source icon image
```

## Configuration

The registry ship is set as a constant in `app/furum.hoon`:

```hoon
++  registry-ship  ~zod
```

Change this to your registry ship's `@p` before deploying to a real network.

## License

MIT
