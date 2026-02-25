# DisqRails

A personal feed reader and link aggregator. Thanks to [Lobsters](https://lobste.rs), [Hacker News](https://news.ycombinator.com), [engineeringblogs.xyz](https://engineeringblogs.xyz), [Bear Blog](https://bearblog.dev/discover/), [Techmeme](https://www.techmeme.com), [LWN](https://lwn.net), and [Lemmy](https://lemmy.ml) for inspiration.

## Setup

Ruby 3.3+, PostgreSQL.

```bash
bundle install
bin/rails db:create db:schema:load db:seed
bin/dev
```

## Auth

GitHub OAuth. Create an app, set callback to `http://localhost:3000/auth/github/callback`, then:

```bash
export GITHUB_CLIENT_ID=...
export GITHUB_CLIENT_SECRET=...
```

## TODO

- Comment tree cleanup (simplify recursive rendering, extract into component)
- Theme editor overhaul (replace dev-only color picker with user-facing theme switcher)
- Post show view simplification (reduce partial nesting)
- Pagination with Turbo Streams (replace frame-based load-more with stream append)
- Frontpage & topbar cleanup
