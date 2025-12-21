# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SQLite3 Adapter Extension" do
  let(:adapter) { ActiveRecord::Base.connection }

  describe "#native_database_types" do
    it "includes uuid type with varchar(36)" do
      expect(adapter.native_database_types[:uuid]).to eq({ name: "varchar", limit: 36 })
    end

    it "includes ulid type with varchar(26)" do
      expect(adapter.native_database_types[:ulid]).to eq({ name: "varchar", limit: 26 })
    end

    it "preserves default SQLite types" do
      expect(adapter.native_database_types[:string]).to eq({ name: "varchar" })
      expect(adapter.native_database_types[:integer]).to eq({ name: "integer" })
    end
  end

  describe "migration integration" do
    it "creates varchar columns for uuid primary keys" do
      ActiveRecord::Base.connection.create_table :test_uuids, id: :uuid, force: true do |t|
        t.string :name
      end

      column = ActiveRecord::Base.connection.columns(:test_uuids).find { |c| c.name == "id" }
      expect(column.sql_type).to match(/varchar/i)
      expect(column.limit).to eq(36)

      ActiveRecord::Base.connection.drop_table :test_uuids, if_exists: true
    end

    it "creates varchar columns for ulid primary keys" do
      ActiveRecord::Base.connection.create_table :test_ulids, id: :ulid, force: true do |t|
        t.string :name
      end

      column = ActiveRecord::Base.connection.columns(:test_ulids).find { |c| c.name == "id" }
      expect(column.sql_type).to match(/varchar/i)
      expect(column.limit).to eq(26)

      ActiveRecord::Base.connection.drop_table :test_ulids, if_exists: true
    end
  end
end
