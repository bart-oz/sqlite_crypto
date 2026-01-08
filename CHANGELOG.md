# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-08

### Added
- **UUIDv7 Support**: Time-sortable UUIDs with better database index performance
  - New configuration option: `config.uuid_version = :v7` (default) or `:v4`
  - Run `rails generate sqlite_crypto:install` to create initializer
  - UUIDv7 requires Ruby 3.3+ (graceful error on older versions)
  - `generates_uuid` now respects the configured version
- **Configuration System**: `SqliteCrypto.configure` block for gem settings
- **Install Generator**: `rails generate sqlite_crypto:install` creates initializer
- **Version Detection**: `SqliteCrypto::Generators::Uuid.v7_available?` helper

### Changed
- **Default UUID version changed to v7** for new projects (better performance)
- `generates_uuid` now uses centralized generator instead of direct `SecureRandom.uuid`

### Notes
- **Ruby 3.1/3.2 users**: Set `config.uuid_version = :v4` in initializer
- No schema changes required - UUIDv4 and v7 are storage-compatible
- Existing v4 UUIDs work alongside new v7 UUIDs in same table

## [1.0.3] - 2025-12-30

### Added
- **Ruby 4.0.0 Support**: Added compatibility with Ruby 4.0.0 released on December 25, 2025
  - Added `benchmark` gem as test dependency (removed from Ruby 4.0.0 stdlib)
  - Reorganized gemspec to include only runtime dependencies
  - Moved development and test dependencies to Gemfile

## [1.0.2] - 2025-12-21

### Fixed
- **Schema Definitions**: Added global `uuid` and `ulid` helper methods for schema.rb
  - Fixes `NameError: undefined local variable or method 'uuid'` when loading schema.rb
  - Schema dumper now outputs `id: uuid` which correctly resolves to `:uuid` symbol
  - Allows schema.rb to be loaded without errors

## [1.0.1] - 2025-12-21

### Fixed
- **Native Database Types**: Added `native_database_types` registration for `:uuid` and `:ulid`
  - UUID columns now correctly create `varchar(36)` in migrations instead of literal `uuid` type
  - ULID columns now correctly create `varchar(26)` in migrations instead of literal `ulid` type
  - Schema dumper now works properly without "Unknown type" errors
  - Fixes compatibility issue discovered during real-world usage

## [1.0.0] - 2025-12-20

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
  - Comprehensive test suite with 99.01% code coverage (58 examples)
  - Unit tests for UUID/ULID types with validation
  - Integration tests for real-world migration scenarios
  - Model extension tests covering generation, validation, and edge cases
  - Performance benchmarks comparing Integer vs UUID vs ULID
  - Support for Rails 7.1, 7.2, 8.0, and 8.1
  - Security audit with bundle-audit in CI
- **Performance Benchmarks**: Comprehensive benchmarking suite
  - Insert performance comparison
  - Query performance benchmarks (find, where)
  - Storage requirement analysis
  - ID format demonstrations
  - Use case recommendations with real-world examples
  - Security implications documentation
- **Documentation**: Professional README with badges, examples, and benchmarks
  - 99.01% test coverage badge
  - Ruby/Rails compatibility matrix
  - Complete usage examples for all features
  - Migration guide for existing applications
  - Benchmark results and recommendations
  - Security considerations
  - Branch protection rules and contribution guidelines

### Changed
- Improved pluralization handling using Rails' built-in `pluralize` method
- Refactored type system with shared Type::Base class
- Organized specs: separated integration tests from unit tests

### Fixed
- Rails version compatibility for migrations (supports Rails 7.1 through 8.1)
- Schema dumper prepend timing by loading sqlite3_adapter explicitly
- ULID foreign key detection with proper table name pluralization