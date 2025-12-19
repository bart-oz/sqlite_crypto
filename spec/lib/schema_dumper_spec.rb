# frozen_string_literal: true

require "rails_helper"
require "active_record/connection_adapters/sqlite3_adapter"
require "sqlite_crypto/schema_dumper"

# Manually prepend for testing (normally done by railtie initializer)
ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.prepend(SqliteCrypto::SchemaDumper)

RSpec.describe SqliteCrypto::SchemaDumper do
  it "dumps UUID primary key as id: :uuid" do
    ActiveRecord::Migration.create_table :users, id: false do |t|
      t.column :id, :string, limit: 36, null: false, primary_key: true
      t.string :name
    end

    stream = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, stream)
    output = stream.string

    expect(output).to include('create_table "users", id: uuid')
    expect(output).not_to include("id: false")
    expect(output).not_to include("limit: 36")
  end
end
