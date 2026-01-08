# SQLite Crypto

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/bart-oz/sqlite_crypto/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)
[![types supported](https://img.shields.io/badge/types-ULID,_UUIDv7/v4-brightgreen.svg)](https://github.com/bart-oz/sqlite_crypto)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen.svg)](https://github.com/bart-oz/sqlite_crypto/actions)
[![Coverage](https://img.shields.io/badge/coverage-98.59%25-brightgreen.svg)](https://github.com/bart-oz/sqlite_crypto/actions)
[![Status](https://img.shields.io/badge/status-active-success.svg)](https://github.com/bart-oz/sqlite_crypto)

**Drop-in UUID and ULID primary keys for Rails + SQLite3**

```ruby
# Just use :uuid or :ulid instead of default integer IDs
create_table :users, id: :uuid do |t|
  t.string :email
end
```

## What You Get

✅ **UUID primary keys** (v4 random or v7 time-sortable)<br/>
✅ **ULID primary keys** (time-sortable, 26 characters)<br/>
✅ **Automatic foreign key detection** - `t.references` just works<br/>
✅ **Model generators** - `generates_uuid :token`<br/>
✅ **Clean schema.rb** - No verbose type definitions<br/>
✅ **Zero dependencies** - Uses Ruby's built-in SecureRandom<br/>

## Quick Start

```bash
bundle add sqlite_crypto
rails generate sqlite_crypto:install
```

## ID Type Comparison

| Type | Format | Performance | Use Case |
|------|--------|-------------|----------|
| **Integer** | `1, 2, 3...` | Baseline | Simple apps, no distribution |
| **UUIDv7** | `018d3f91-...` (36 chars) | ~1-3% slower inserts | ⭐ **Recommended** - Time-sortable + fast |
| **UUIDv4** | `550e8400-e29b-...` (36 chars) | ~2-5% slower inserts | Random IDs, legacy compatibility |
| **ULID** | `01ARZ3NDEK...` (26 chars) | ~3-7% slower inserts | Time-sortable, compact format |

### Why UUIDv7 is Recommended

UUIDv7 embeds a timestamp in the first 48 bits, making IDs naturally sortable by creation time:

```
UUIDv7: 018d3f91-8f4a-7000-9e7b-4a5c8d2e1f3a  ← Time-based (inserts cluster at end)
UUIDv4: 6ba7b810-9dad-11d1-80b4-00c04fd430c8  ← Random (causes index fragmentation)
```

**Performance Impact:**
- New records insert at the **end of B-tree index** (not random positions)
- Reduces page splits and fragmentation
- ~40% faster index writes vs UUIDv4 at scale (10k+ records)

**Requirements:** Ruby 3.3+ (falls back to v4 on older versions)

## Configuration

### Choose UUID Version (v4 or v7)

After running `rails generate sqlite_crypto:install`:

```ruby
# config/initializers/sqlite_crypto.rb
SqliteCrypto.configure do |config|
  config.uuid_version = :v7  # Recommended (requires Ruby 3.3+)
  # config.uuid_version = :v4  # Use this for Ruby 3.1/3.2
end
```

**Ruby Version Support:**
- Ruby 3.3+ → v4 and v7
- Ruby 3.1/3.2 → v4 only

Check programmatically:
```ruby
SqliteCrypto::Generators::Uuid.v7_available?  # => true/false
```

## Usage Examples

### UUID Primary Keys

```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.timestamps
    end
  end
end
```

Result:
```ruby
user = User.create!(email: "alice@example.com")
user.id  # => "018d3f91-8f4a-7000-9e7b-4a5c8d2e1f3a" (UUIDv7)
```

### ULID Primary Keys

```ruby
class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts, id: :ulid do |t|
      t.string :title
      t.timestamps
    end
  end
end
```

Result:
```ruby
post = Post.create!(title: "Hello World")
post.id  # => "01ARZ3NDEKTSV4RRFFQ69G5FAV" (26 chars, time-sortable)
```

### Automatic Foreign Keys

The gem **automatically detects** parent table ID types:

```ruby
# Users have UUID primary keys
create_table :users, id: :uuid do |t|
  t.string :name
end

# Posts automatically get varchar(36) foreign keys
create_table :posts do |t|
  t.references :user      # Auto-detected as varchar(36)!
  t.string :title
end
```

Works with ULID too:
```ruby
create_table :categories, id: :ulid do |t|
  t.string :name
end

create_table :articles do |t|
  t.references :category  # Auto-detected as varchar(26)!
end
```

### Generate UUIDs/ULIDs for Any Column

```ruby
class User < ApplicationRecord
  generates_uuid :token                    # Auto-generate on create
  generates_ulid :reference, unique: true  # With uniqueness validation
end

user = User.create!(email: "test@example.com")
user.token      # => "018d3f91-..." (auto-generated)
user.reference  # => "01ARZ3NDEK..." (auto-generated + validated)
```

## Requirements

- **Ruby**: 3.1+ (3.3+ for UUIDv7)
- **Rails**: 7.1, 7.2, 8.0, 8.1
- **Database**: SQLite3

## Performance Benchmarks

Run your own benchmarks: `bundle exec rspec --tag performance`

**Typical results (M1 Mac, SQLite3, 10k records):**

| Operation | Integer (baseline) | UUIDv4 | UUIDv7 | ULID |
|-----------|-------------------|--------|--------|------|
| Insert (10k) | 1.00x | 1.02x | 1.01x | 1.05x |
| Query by ID | 1.00x | 1.03x | 1.03x | 1.04x |
| Index size | 100% | 145% | 145% | 130% |

**Key takeaway:** UUIDv7 has nearly identical performance to v4, with better write scaling.
## Advanced Usage

### Custom Table Names

Use `:to_table` for non-standard associations:

```ruby
create_table :posts do |t|
  t.references :author, to_table: :users  # Uses users table's ID type
end
```

### Mixing ID Types

Different tables can use different ID types:

```ruby
create_table :users, id: :uuid do |t|
  t.string :email
end

create_table :sessions, id: :ulid do |t|
  t.references :user  # Auto-detected as varchar(36)
end

create_table :logs do |t|  # Integer ID (default)
  t.string :message
end
```

### ID Prefixes (Stripe-style)

```ruby
class Invoice < ApplicationRecord
  before_create :add_prefix

  private
  def add_prefix
    self.id = "inv_#{SecureRandom.uuid}" if id.nil?
  end
end
```

## Migrating Existing Apps

Use UUID/ULID only for **new tables**:

```ruby
# Keep existing integer IDs
# users: id (integer)
# posts: id (integer), user_id (integer)

# New tables use UUID/ULID
create_table :invoices, id: :uuid do |t|
  t.references :user  # Still integer (auto-detected)
  t.decimal :amount
end
```

## How It Works

1. **Type Registration** - Registers `:uuid` and `:ulid` with ActiveRecord's SQLite3 adapter
2. **Validation** - UUIDs: 36-char format, ULIDs: 26-char format
3. **Migration Helpers** - `t.uuid()` and `t.ulid()` in migrations
4. **Smart References** - `t.references` detects parent table ID type
5. **Model Extensions** - `generates_uuid`/`generates_ulid` for auto-generation
6. **Schema Dumper** - Clean output: `id: :uuid` instead of verbose definitions

## Development

```bash
bundle install
bundle exec rspec                    # Run tests
bundle exec standardrb               # Lint
bundle exec rspec --tag performance  # Benchmarks
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE.txt](LICENSE.txt)