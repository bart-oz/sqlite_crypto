# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem "rake", "~> 13.3.1"
  gem "standard", "~> 1.52.0"
  gem "standard-performance", "~> 1.9.0"
  gem "guard-rspec", "~> 4.7.3"
end

group :test do
  gem "bundler-audit", "~> 0.9.3"
  gem "appraisal", "~> 2.5"
  gem "rspec", "~> 3.13.2"
  gem "rspec-rails", "~> 6.0.0"
  gem "simplecov", "~> 0.22.0", require: false
  gem "benchmark", "~> 0.5.0" # Required in Ruby 4.0.0+ (removed from stdlib)
end
