# frozen_string_literal: true

require_relative "lib/sqlite_crypto/version"

Gem::Specification.new do |spec|
  spec.name = "sqlite_crypto"
  spec.version = SqliteCrypto::VERSION
  spec.authors = ["BartOz"]
  spec.email = ["bartek.ozdoba@gmail.com"]
  spec.homepage = "https://github.com/bart-oz/sqlite_crypto"
  spec.license = "MIT"
  spec.summary = "UUID (v4/v7) and ULID primary keys for Rails + SQLite3"
  spec.description = "UUID and ULID primary key support for Rails with SQLite3. Provides automatic type registration, validation, foreign key detection, and clean schema generation. Supports UUIDv4 (random), UUIDv7 (time-ordered), and ULID (compact, time-sortable) with zero external dependencies."

  spec.files = Dir["lib/**/*", "README.md", "LICENSE.txt", "CHANGELOG.md", "bin/*"]
  spec.require_paths = ["lib"]
  spec.bindir = "bin"

  spec.required_ruby_version = ">= #{SqliteCrypto::RUBY_MINIMUM_VERSION}"

  spec.add_dependency "rails", ">= #{SqliteCrypto::RAILS_MINIMUM_VERSION}"
  spec.add_dependency "sqlite3", ">= 1.6.0"
  spec.add_dependency "ulid", "~> 1.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
