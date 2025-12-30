# SQLite crypto

[![Version](https://img.shields.io/badge/version-1.0.3-blue.svg)](https://github.com/bart-oz/sqlite_crypto/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen.svg)](https://github.com/bart-oz/sqlite_crypto/actions)
[![Coverage](https://img.shields.io/badge/coverage-99.06%25-brightgreen.svg)](https://github.com/bart-oz/sqlite_crypto/actions)
[![Status](https://img.shields.io/badge/status-active-success.svg)](https://github.com/bart-oz/sqlite_crypto)

Seamless UUID and ULID primary key support for Rails with SQLite3.

### ID Format Comparison

```
INTEGER:  1, 2, 3, ... (sequential, guessable)
UUID:     550e8400-e29b-41d4-a716-446655440000 (random, 36 chars)
ULID:     01ARZ3NDEKTSV4RRFFQ69G5FAV (time-sortable, 26 chars)
```

## Why Use UUID/ULID Instead of Integer IDs?

|  | **Integer** | **UUID** | **ULID** |
|---|-------------|----------|----------|
| **Performance** | Baseline | +2-5% slower | +5-10% slower |
| **Storage** | 8 bytes | 36 bytes (4.5x) | 26 bytes (3.2x) |
| **Security** | Guessable | Random | Random |
| **Collisions** | ⚠️ High in distributed systems | Virtually impossible | Virtually impossible |
| **Sortable** | Sequential | Random | Time-based |
| **Distributed** | Needs coordination | Generate anywhere | Generate anywhere |

**Performance testing**: Run `bundle exec rspec --tag performance` to benchmark on your hardware. Specs test scaling from 100 → 10,000 records across inserts, queries, updates, and deletes.

## Gem Compatibility

| Ruby Version | Rails 7.1 | Rails 7.2 | Rails 8.0 | Rails 8.1 |
|--------------|-----------|-----------|-----------|-----------|
| 3.1          | ✅        | ✅        | ❌        | ❌        |
| 3.2          | ✅        | ✅        | ✅        | ✅        |
| 3.3          | ✅        | ✅        | ✅        | ✅        |
| 3.4          | ✅        | ✅        | ✅        | ✅        |
| 4.0          | ✅        | ✅        | ✅        | ✅        |

**Recommended**: Ruby 3.3+ with Rails 8.0+

**Support Policy**: Actively maintained with updates for new Ruby and Rails versions.

## Features

* UUID primary keys with automatic validation
* ULID primary keys with time-sortable validation
* Migration DSL helpers (`t.uuid`, `t.ulid`)
* Automatic foreign key type detection
* Model extensions for UUID/ULID generation
* Clean schema.rb output
* Zero configuration required

## Installation

Add to your Gemfile:

```ruby
gem "sqlite_crypto"
```

Then run:

```bash
bundle install
```

That's it! No generators or configuration needed.

## Usage

### UUID Primary Keys

```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :name
      t.timestamps
    end
  end
end
```

### ULID Primary Keys

```ruby
class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts, id: :ulid do |t|
      t.string :title
      t.text :content
      t.timestamps
    end
  end
end
```

### UUID/ULID Columns

```ruby
class AddTrackingIds < ActiveRecord::Migration[8.1]
  def change
    change_table :orders do |t|
      t.uuid :external_id
      t.ulid :tracking_number
    end
  end
end
```

### Foreign Keys (Automatic Detection)

The gem automatically detects UUID/ULID primary keys and creates matching foreign keys:

```ruby
# Users table has UUID primary key
create_table :users, id: :uuid do |t|
  t.string :name
end

# Posts automatically get varchar(36) user_id foreign key
create_table :posts do |t|
  t.references :user  # Automatically creates varchar(36) foreign key!
  t.string :title
end
```

Works with ULID too:

```ruby
# Categories table has ULID primary key
create_table :categories, id: :ulid do |t|
  t.string :name
end

# Articles automatically get varchar(26) category_id foreign key
create_table :articles do |t|
  t.references :category  # Automatically creates varchar(26) foreign key!
  t.string :title
end
```

### Custom Table Names

Use `:to_table` option for non-standard table names:

```ruby
create_table :posts do |t|
  t.references :author, to_table: :users  # Uses users table's UUID type
  t.string :title
end
```

### Model Extensions (Auto-Generate UUIDs/ULIDs)

Automatically generate UUID or ULID values for any column:

```ruby
class User < ApplicationRecord
  # Generate UUID for 'token' column on create
  generates_uuid :token
end

class Order < ApplicationRecord
  # Generate ULID for 'reference' column with uniqueness validation
  generates_ulid :reference, unique: true
end
```

**Features:**
- `generates_uuid(attribute, unique: false)` - Generates SecureRandom.uuid
- `generates_ulid(attribute, unique: false)` - Generates time-sortable ULID
- `unique: true` - Adds uniqueness validation
- Preserves existing values (won't overwrite if already set)
- Works with any string column, not just primary keys

**Example migration:**

```ruby
class AddTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :token, :string, limit: 36
    add_index :users, :token, unique: true
  end
end
```

### Schema Output

Your `db/schema.rb` will be clean and readable:

```ruby
create_table "users", id: :uuid, force: :cascade do |t|
  t.string "email"
  t.timestamps
end

create_table "posts", force: :cascade do |t|
  t.string "user_id", limit: 36  # Clean foreign key
  t.string "title"
end
```

## How It Works

1. **Type Registration**: Registers `:uuid` and `:ulid` types with ActiveRecord for SQLite3
2. **Validation**: UUIDs validate 36-char format, ULIDs validate 26-char format
3. **Migration Helpers**: `t.uuid()` and `t.ulid()` methods in migrations
4. **Smart References**: `t.references` detects parent table's primary key type
5. **Model Extensions**: `generates_uuid` and `generates_ulid` for automatic generation
6. **Schema Dumper**: Outputs clean `id: :uuid` instead of verbose type definitions

## Requirements

- Rails 7.1+ (tested on 7.1, 7.2, 8.0, 8.1)
- Ruby 3.1+
- SQLite3

## Migrating Existing Apps

### New Tables Only (Recommended)

The safest approach is to use UUID/ULID only for new tables:

```ruby
# Existing tables keep integer IDs
# users: id (integer)
# posts: id (integer), user_id (integer)

# New tables use UUID/ULID
create_table :invoices, id: :uuid do |t|
  t.references :user  # Still integer (auto-detected from users table)
  t.decimal :amount
end

create_table :sessions, id: :ulid do |t|
  t.references :user  # Still integer
  t.string :token
end
```

## Advanced Patterns

### ID Prefixes (Optional)

For Stripe-style prefixed IDs (`inv_`, `usr_`, etc.), add to your models:

```ruby
class Invoice < ApplicationRecord
  before_create :generate_prefixed_id

  private

  def generate_prefixed_id
    self.id = "inv_#{SecureRandom.uuid}" if id.nil?
  end
end
```

### Mixing Types

You can use different primary key types in the same app:

```ruby
create_table :users, id: :uuid do |t|
  t.string :email
end

create_table :sessions, id: :ulid do |t|
  t.string :token
end

create_table :logs do |t|  # Standard integer ID
  t.string :message
end
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec standardrb
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE.txt](LICENSE.txt)