# frozen_string_literal: true

require "rails_helper"
require "active_record/connection_adapters/sqlite3_adapter"
require "sqlite_crypto/schema_dumper"

# Manually prepend for testing (normally done by railtie initializer)
ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.prepend(SqliteCrypto::SchemaDumper)

RSpec.describe SqliteCrypto::SchemaDumper do
  let(:connection) { ActiveRecord::Base.connection }

  after do
    connection.drop_table :users, if_exists: true
    connection.drop_table :tags, if_exists: true
    connection.drop_table :posts, if_exists: true
  end

  def dump_schema
    stream = StringIO.new
    # Rails 7.2+ uses connection_pool, Rails 7.1 uses connection
    if ActiveRecord.version >= Gem::Version.new("7.2")
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, stream)
    else
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    end
    stream.string
  end

  it "dumps UUID primary key as id: :uuid" do
    ActiveRecord::Migration.create_table :users, id: false do |t|
      t.column :id, :string, limit: 36, null: false, primary_key: true
      t.string :name
    end

    output = dump_schema

    expect(output).to include('create_table "users", id: uuid')
    expect(output).not_to include("id: false")
    expect(output).not_to include("limit: 36")
  end

  it "dumps ULID primary key as id: :ulid" do
    ActiveRecord::Migration.create_table :tags, id: false do |t|
      t.column :id, :string, limit: 26, null: false, primary_key: true
      t.string :name
    end

    output = dump_schema

    expect(output).to include('create_table "tags", id: ulid')
    expect(output).not_to include("id: false")
    expect(output).not_to include("limit: 26")
  end

  it "dumps standard integer primary key normally" do
    ActiveRecord::Migration.create_table :posts do |t|
      t.string :title
    end

    output = dump_schema

    expect(output).to include('create_table "posts"')
    expect(output).not_to include("id: :uuid")
    expect(output).not_to include("id: :ulid")
  end

  it "dumps string primary key with non-UUID/ULID limit normally" do
    ActiveRecord::Migration.create_table :users, id: false do |t|
      t.column :id, :string, limit: 50, null: false, primary_key: true
      t.string :name
    end

    output = dump_schema

    expect(output).to include('create_table "users", id: { type: :string, limit: 50 }')
  end
end
