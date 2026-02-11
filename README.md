# SQLite Crypto

[![Version](https://img.shields.io/badge/version-2.0.2-blue.svg)](https://github.com/bart-oz/sqlite_crypto/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)
[![types supported](https://img.shields.io/badge/types-ULID,_UUIDv7/v4-brightgreen.svg)](https://github.com/bart-oz/sqlite_crypto)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen.svg)](https://github.com/bart-oz/sqlite_crypto/actions)
[![Coverage](https://img.shields.io/badge/coverage-98.06%25-brightgreen.svg)](https://github.com/bart-oz/sqlite_crypto/actions)
[![Status](https://img.shields.io/badge/status-active-success.svg)](https://github.com/bart-oz/sqlite_crypto)

## Overview

Seamless UUID and ULID primary key support for Rails applications using SQLite3. Handles type registration, validation, foreign key detection, and schema generation automatically.

```ruby
create_table :users, id: :uuid do |t|
  t.string :email
  t.timestamps
end
```

**Key capabilities:**
- UUID primary keys (v4 random or v7 time-ordered)
- ULID primary keys (time-sortable, compact)
- Automatic foreign key type detection
- Model-level ID generation
- Clean schema.rb output
- Zero external dependencies

## Compatibility

**Ruby & Rails:**

|       | Rails 7.1 | Rails 7.2 | Rails 8.0 | Rails 8.1 |
|-------|-----------|-----------|-----------|-----------|
| Ruby 3.1 | ✓ | ✓ | - | - |
| Ruby 3.2 | ✓ | ✓ | ✓ | ✓ |
| Ruby 3.3 | ✓ | ✓ | ✓ | ✓ |
| Ruby 3.4 | ✓ | ✓ | ✓ | ✓ |
| Ruby 4.0 | ✓ | ✓ | ✓ | ✓ |

**UUID Versions:**

| Version | Ruby 3.1/3.2 | Ruby 3.3+ |
|---------|--------------|-----------|
| v4 (random) | ✓ | ✓ |
| v7 (time-ordered) | - | ✓ |

**Database:** SQLite3

## Installation

```ruby
# Gemfile
gem "sqlite_crypto"
```

```bash
bundle install
rails generate sqlite_crypto:install
```

The generator creates `config/initializers/sqlite_crypto.rb` for configuration.

## Configuration

**1. Configure UUID Version**

```ruby
# config/initializers/sqlite_crypto.rb
SqliteCrypto.configure do |config|
  config.uuid_version = :v7  # or :v4
end
```

The gem automatically selects a default based on your Ruby version (v7 for Ruby 3.3+, v4 otherwise).

**2. Create Tables with UUID/ULID**

```ruby
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.timestamps
    end
  end
end
```

**3. Use Your Models**

```ruby
user = User.create!(email: "test@example.com")
user.id  # => "018d3f91-8f4a-7000-9e7b-4a5c8d2e1f3a"
```

## Usage

**Primary Keys**

Create tables with UUID or ULID primary keys:

```ruby
# UUID
create_table :users, id: :uuid do |t|
  t.string :email
end

# ULID
create_table :posts, id: :ulid do |t|
  t.string :title
end
```

**Foreign Keys**

Foreign key types are automatically detected from parent tables:

```ruby
create_table :users, id: :uuid do |t|
  t.string :name
end

create_table :posts do |t|
  t.references :user  # Automatically varchar(36)
  t.string :title
end
```

**Model-Level Generation**

Generate UUIDs or ULIDs for any column:

```ruby
class User < ApplicationRecord
  generates_uuid :api_token
  generates_ulid :tracking_id, unique: true
end

user = User.create!
user.api_token    # => "550e8400-e29b-41d4-a716-446655440000"
user.tracking_id  # => "01ARZ3NDEKTSV4RRFFQ69G5FAV"
```

## ID Types

**Characteristics**

| Type | Length | Format | Ordering | Ruby Version |
|------|--------|--------|----------|--------------|
| Integer | 8 bytes | Sequential numbers | Sequential | Any |
| UUIDv4 | 36 chars | `xxxxxxxx-xxxx-4xxx-...` | Random | 3.1+ |
| UUIDv7 | 36 chars | `xxxxxxxx-xxxx-7xxx-...` | Time-based | 3.3+ |
| ULID | 26 chars | `01ARZ3NDEK...` | Time-based | 3.1+ |

**Performance**

Benchmarks with 10,000 records on SQLite3:

| Type | Insert | Query | Index Size |
|------|--------|-------|------------|
| Integer | 1.00x | 1.00x | 100% |
| UUIDv4 | 1.02x | 1.03x | 145% |
| UUIDv7 | 1.01x | 1.03x | 145% |
| ULID | 1.05x | 1.04x | 130% |

Run your own: `bundle exec rspec --tag performance`

## Advanced Usage

**Non-Standard Table Names**

```ruby
create_table :posts do |t|
  t.references :author, to_table: :users
end
```

**Mixed ID Types**

```ruby
create_table :users, id: :uuid do |t|
  t.string :email
end

create_table :sessions, id: :ulid do |t|
  t.references :user
end

create_table :logs do |t|  # Integer ID
  t.text :message
end
```

## Migrating Existing Apps

Add UUID/ULID to new tables while keeping integer IDs on existing tables:

```ruby
# Existing tables unchanged
create_table :invoices, id: :uuid do |t|
  t.references :user  # Detects integer from users table
  t.decimal :amount
end
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec standardrb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bart-oz/sqlite_crypto.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).