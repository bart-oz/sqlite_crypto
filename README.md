# sqlite_crypto

Seamless UUID/ULID support for Rails 8 with SQLite.

**Status**: Early Development (v0.1.0)

## Goals

- **Minimal**: No database adapter wrapping, pure Rails conventions
- **Modular**: Use only what you need (UUID or ULID, not both required)
- **Clear**: Explicit over implicit, following Rails 8 patterns
- **Documented**: Clear migration path for existing and new projects

## Planned Features

- UUID primary key configuration with `t.uuid :id`
- ULID primary key configuration with `t.ulid :id`
- Migration helpers and generators
- Transparent foreign key handling
- Migration utilities for converting existing integer primary keys

## Installation

```ruby
gem "sqlite_crypto"