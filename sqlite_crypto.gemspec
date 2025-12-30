# frozen_string_literal: true

require_relative "lib/sqlite_crypto/version"

Gem::Specification.new do |spec|
  spec.name = "sqlite_crypto"
  spec.version = SqliteCrypto::VERSION
  spec.authors = ["BartOz"]
  spec.email = ["bartek.ozdoba@gmail.com"]
  spec.homepage = "https://github.com/bart-oz/sqlite_crypto"
  spec.license = "MIT"
  spec.summary = "Seamless UUID/ULID support for Rails 8 with SQLite"
  spec.description = "A lightweight, modular gem providing transparent UUID/ULID primary key configuration for Rails applications using SQLite."
  spec.files = Dir["lib/**/*", "README.md", "LICENSE.txt", "CHANGELOG.md", "bin/*"]
  spec.require_paths = ["lib"]
  spec.bindir = "bin"

  spec.required_ruby_version = ">= #{SqliteCrypto::RUBY_MINIMUM_VERSION}"

  spec.add_dependency "rails", ">= #{SqliteCrypto::RAILS_MINIMUM_VERSION}"
  spec.add_dependency "sqlite3", ">= 1.6.0"
  spec.add_dependency "ulid", "~> 1.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
