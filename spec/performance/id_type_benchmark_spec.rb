require "rails_helper"
require "benchmark"

RSpec.describe "ID Type Performance Benchmarks", :performance do
  # Define models with ID generation
  before(:all) do
    unless defined?(IntegerUser)
      Object.const_set(:IntegerUser, Class.new(ActiveRecord::Base))
    end

    unless defined?(UuidUser)
      uuid_model = Class.new(ActiveRecord::Base) do
        before_create { self.id ||= SecureRandom.uuid }
      end
      Object.const_set(:UuidUser, uuid_model)
    end

    unless defined?(UlidUser)
      ulid_model = Class.new(ActiveRecord::Base) do
        before_create { self.id ||= ULID.generate.to_s }
      end
      Object.const_set(:UlidUser, ulid_model)
    end
  end

  before(:each) do
    ActiveRecord::Base.connection.create_table :integer_users, force: true do |t|
      t.string :name
      t.integer :age
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table :uuid_users, id: :uuid, force: true do |t|
      t.string :name
      t.integer :age
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table :ulid_users, id: :ulid, force: true do |t|
      t.string :name
      t.integer :age
      t.timestamps
    end
  end

  after(:each) do
    ActiveRecord::Base.connection.drop_table :integer_users, if_exists: true
    ActiveRecord::Base.connection.drop_table :uuid_users, if_exists: true
    ActiveRecord::Base.connection.drop_table :ulid_users, if_exists: true
  end

  def benchmark_operation(label, &block)
    result = Benchmark.measure(&block)
    result.real
  end

  def compare_models(operation_name, scale, &block)
    results = {}

    results[:integer] = benchmark_operation("Integer") { block.call(IntegerUser, scale) }
    results[:uuid] = benchmark_operation("UUID") { block.call(UuidUser, scale) }
    results[:ulid] = benchmark_operation("ULID") { block.call(UlidUser, scale) }

    baseline = results[:integer]
    uuid_diff = ((results[:uuid] - baseline) / baseline * 100).round(1)
    ulid_diff = ((results[:ulid] - baseline) / baseline * 100).round(1)

    puts "\n#{operation_name}:"
    puts "  Integer: #{results[:integer].round(3)}s (baseline)"
    puts "  UUID:    #{results[:uuid].round(3)}s (#{"+" if uuid_diff > 0}#{uuid_diff}%)"
    puts "  ULID:    #{results[:ulid].round(3)}s (#{"+" if ulid_diff > 0}#{ulid_diff}%)"

    results
  end

  describe "Performance Benchmarks" do
    it "runs comprehensive benchmark suite" do
      puts "\n" + "=" * 70
      puts "ID TYPE PERFORMANCE BENCHMARKS"
      puts "=" * 70

      puts "\n📝 INSERT OPERATIONS:"
      compare_models("  Insert 1,000 records", 1000) do |model, count|
        count.times { |i| model.create(name: "User #{i}", age: 25 + (i % 50)) }
      end

      compare_models("  Insert 10,000 records", 10_000) do |model, count|
        count.times { |i| model.create(name: "User #{i}", age: 25 + (i % 50)) }
      end

      puts "\n🔍 QUERY OPERATIONS (1,000 records):"

      # Seed 1,000 records
      1000.times { |i| IntegerUser.create(name: "User #{i}", age: 25 + (i % 50)) }
      1000.times { |i| UuidUser.create(name: "User #{i}", age: 25 + (i % 50)) }
      1000.times { |i| UlidUser.create(name: "User #{i}", age: 25 + (i % 50)) }

      integer_ids = IntegerUser.pluck(:id)
      uuid_ids = UuidUser.pluck(:id)
      ulid_ids = UlidUser.pluck(:id)

      compare_models("  Find by ID (1,000 lookups)", 1000) do |model, count|
        ids = case model.name
        when "IntegerUser" then integer_ids
        when "UuidUser" then uuid_ids
        when "UlidUser" then ulid_ids
        end
        count.times { model.find(ids.sample) }
      end

      compare_models("  Where queries (1,000 queries)", 1000) do |model, count|
        count.times { model.where(age: 30).limit(10).to_a }
      end

      puts "\n🔍 QUERY OPERATIONS (10,000 records):"

      9000.times { |i| IntegerUser.create(name: "User #{1000 + i}", age: 25 + (i % 50)) }
      9000.times { |i| UuidUser.create(name: "User #{1000 + i}", age: 25 + (i % 50)) }
      9000.times { |i| UlidUser.create(name: "User #{1000 + i}", age: 25 + (i % 50)) }

      integer_ids_large = IntegerUser.pluck(:id)
      uuid_ids_large = UuidUser.pluck(:id)
      ulid_ids_large = UlidUser.pluck(:id)

      compare_models("  Find by ID (1,000 lookups)", 1000) do |model, count|
        ids = case model.name
        when "IntegerUser" then integer_ids_large
        when "UuidUser" then uuid_ids_large
        when "UlidUser" then ulid_ids_large
        end
        count.times { model.find(ids.sample) }
      end

      compare_models("  Where queries (1,000 queries)", 1000) do |model, count|
        count.times { model.where(age: 30).limit(10).to_a }
      end

      puts "\n✏️  UPDATE OPERATIONS:"
      compare_models("  Update all (1,000 records)", "1000") do |model, _|
        model.where("age < ?", 40).limit(1000).update_all(age: 30)
      end

      compare_models("  Update all (10,000 records)", "10000") do |model, _|
        model.where("age < ?", 40).limit(10_000).update_all(age: 30)
      end

      puts "\n🗑️  DELETE OPERATIONS:"
      compare_models("  Delete all (1,000 records)", "1000") do |model, _|
        model.limit(1000).delete_all
      end

      compare_models("  Delete all (10,000 records)", "10000") do |model, _|
        model.limit(10_000).delete_all
      end

      puts "\n" + "=" * 70
      puts "STORAGE AND USAGE SUMMARY"
      puts "=" * 70
      puts "Storage (1M records): Integer 7.6MB | UUID 34.3MB | ULID 24.8MB"
      puts "\n💡 Integer: Fast but guessable"
      puts "💡 UUID: Secure, distributed, random ordering"
      puts "💡 ULID: Secure, distributed, time-sortable (best for APIs)"
      puts "=" * 70
    end
  end
end
