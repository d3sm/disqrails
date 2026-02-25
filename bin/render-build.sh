#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails db:prepare

# Optional seeding on deploy. Off by default to keep deploys fast and predictable.
if [ "${RUN_SEEDS:-0}" = "1" ]; then
  bundle exec rails db:seed
fi
