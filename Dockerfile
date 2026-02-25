# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3
FROM ruby:${RUBY_VERSION}-slim AS build

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "development test" && \
    bundle install --jobs 4

COPY . .

ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=placeholder_for_precompile

RUN bundle exec rails assets:precompile

# --- runtime ---
FROM ruby:${RUBY_VERSION}-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libpq5 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home app

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

USER app

ENV RAILS_ENV=production
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
