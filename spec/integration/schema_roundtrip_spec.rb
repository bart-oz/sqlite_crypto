# frozen_string_literal: true

require "rails_helper"
require "active_record/connection_adapters/sqlite3_adapter"
require "sqlite_crypto/schema_dumper"
require "tempfile"

unless ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.ancestors.include?(SqliteCrypto::SchemaDumper)
  ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.prepend(SqliteCrypto::SchemaDumper)
end

RSpec.describe "Schema Round-Trip" do
  let(:connection) { ActiveRecord::Base.connection }

  after do
    [:tags, :users].each do |table|
      connection.drop_table table, if_exists: true
    end
  end

  def dump_schema
    stream = StringIO.new
    if ActiveRecord.version >= Gem::Version.new("7.2")
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, stream)
    else
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    end
    stream.string
  end

  def load_schema(schema_rb)
    Tempfile.create(["schema", ".rb"]) do |f|
      f.write(schema_rb)
      f.flush
      load(f.path)
    end
  end

  it "dumps and reloads schema with UUID primary key" do
    ActiveRecord::Migration.create_table :users, id: false do |t|
      t.column :id, :string, limit: 36, null: false, primary_key: true
      t.string :name
    end

    schema_rb = dump_schema
    connection.drop_table :users

    expect { load_schema(schema_rb) }.not_to raise_error

    expect(connection.table_exists?(:users)).to be true
    id_col = connection.columns(:users).find { |c| c.name == "id" }
    expect(id_col.sql_type).to eq("varchar(36)")
  end

  it "dumps and reloads schema with ULID primary key" do
    ActiveRecord::Migration.create_table :tags, id: false do |t|
      t.column :id, :string, limit: 26, null: false, primary_key: true
      t.string :name
    end

    schema_rb = dump_schema
    connection.drop_table :tags

    expect { load_schema(schema_rb) }.not_to raise_error

    expect(connection.table_exists?(:tags)).to be true
    id_col = connection.columns(:tags).find { |c| c.name == "id" }
    expect(id_col.sql_type).to eq("varchar(26)")
  end
end
