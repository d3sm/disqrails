# **H**acker news **o**n **R**ails 💅🏻

## Prerequisites

- Ruby `3.3.4`
- PostgreSQL running locally on `localhost:5432`

## Setup

```bash
bundle install
bin/setup --skip-server
```

Equivalent manual DB setup:

```bash
bin/rails db:create db:migrate db:seed
```

## Run

```bash
bin/dev
```

Open `http://localhost:3000`.

## Import Hacker News data

Top stories are fetched automatically when the homepage loads.
The importer refreshes periodically and pulls from:

`https://hacker-news.firebaseio.com/v0/topstories.json`

The app stores imported story rank, score, author, and comment count metadata and renders posts in HN rank order.
