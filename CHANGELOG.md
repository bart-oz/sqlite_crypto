# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Type System**: Custom UUID and ULID ActiveRecord types for SQLite adapter
  - UUID type with validation (36-character hyphenated format)
  - ULID type with time-sortable validation (26-character format)
  - Shared Type::Base class for DRY implementation
- **Migration Helpers**: DSL methods for migrations
  - `t.uuid()` and `t.ulid()` for column definitions
  - Automatic foreign key type detection for `references`/`belongs_to`
  - Support for `id: :uuid` and `id: :ulid` shorthand syntax in create_table
  - `:to_table` option support for non-standard table names
- **Schema Dumper Integration**: Clean schema.rb output
  - Outputs `id: :uuid` instead of `id: { type: :string, limit: 36 }`
  - Outputs `id: :ulid` instead of `id: { type: :string, limit: 26 }`
  - Preserves standard integer primary keys unchanged
- **Model Extensions**: ActiveRecord class methods for automatic UUID/ULID generation
  - `generates_uuid(attribute, unique: false)` - Auto-generates SecureRandom.uuid on create
  - `generates_ulid(attribute, unique: false)` - Auto-generates time-sortable ULID on create
  - Optional uniqueness validation with `unique: true` parameter
  - Preserves existing values (uses `||=` to avoid overwriting)
  - Available to all ActiveRecord models via concern
- **Rails Integration**: Full Railtie implementation
  - Type registration for SQLite3 adapter
  - Schema dumper prepending with proper load order
  - Migration helpers loading
  - Model extensions loading after database initialization
- **Testing Infrastructure**:
  - Comprehensive test suite with 99.01% code coverage (51 examples)
  - Unit tests for UUID/ULID types with validation
  - Integration tests for real-world migration scenarios
  - Model extension tests covering generation, validation, and edge cases
  - Support for Rails 7.1, 7.2, 8.0, and 8.1
  - Security audit with bundle-audit in CI
- **Documentation**: Branch protection rules and contribution guidelines

### Changed
- Improved pluralization handling using Rails' built-in `pluralize` method
- Refactored type system with shared Type::Base class
- Organized specs: separated integration tests from unit tests

### Fixed
- Rails version compatibility for migrations (supports Rails 7.1 through 8.1)
- Schema dumper prepend timing by loading sqlite3_adapter explicitly
- ULID foreign key detection with proper table name pluralization

## [0.1.0] - TBD

Initial release