source "https://rubygems.org"

gem "rails", "~> 8.1.2"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "feedjira"
gem "rexml"
gem "omniauth"
gem "omniauth-github"
gem "omniauth-rails_csrf_protection"
gem "tailwindcss-rails", "~> 4.0"
gem "tzinfo-data", platforms: [:windows, :jruby]
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "view_component"
gem "bootsnap", require: false

group :development, :test do
  gem "dotenv-rails"
  gem "brakeman", require: false
  gem "debug", platforms: [:mri, :windows], require: "debug/prelude"
  gem "htmlbeautifier"
  gem "rubocop", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rake", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
