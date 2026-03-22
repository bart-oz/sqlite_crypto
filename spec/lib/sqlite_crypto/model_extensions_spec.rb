# frozen_string_literal: true

require "rails_helper"

RSpec.describe SqliteCrypto::ModelExtensions do
  let(:connection) { ActiveRecord::Base.connection }

  before do
    connection.create_table :test_users, force: true do |t|
      t.string :name
      t.string :token, limit: 36
      t.string :reference, limit: 26
    end

    stub_const("TestUser", Class.new(ActiveRecord::Base) do
      self.table_name = "test_users"
    end)
  end

  after do
    connection.drop_table :test_users, if_exists: true
  end

  describe ".generates_uuid" do
    before { TestUser.generates_uuid :token }

    it "auto-generates valid UUID on create" do
      user = TestUser.create!(name: "Alice")

      expect(user.token).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
    end

    it "preserves existing values" do
      existing_uuid = "550e8400-e29b-41d4-a716-446655440000"
      user = TestUser.create!(name: "Bob", token: existing_uuid)

      expect(user.token).to eq(existing_uuid)
    end

    context "with unique: true" do
      before { TestUser.generates_uuid :token, unique: true }

      it "enforces uniqueness validation" do
        user1 = TestUser.create!(name: "Alice")
        user2 = TestUser.new(name: "Bob", token: user1.token)

        expect(user2).not_to be_valid
        expect(user2.errors[:token]).to include("has already been taken")
      end
    end
  end

  describe ".generates_uuid with configuration" do
    after { SqliteCrypto.reset_configuration! }

    context "when configured for v4" do
      before do
        SqliteCrypto.config.uuid_version = :v4
        TestUser.generates_uuid :token
      end

      it "generates UUIDv4" do
        user = TestUser.create!(name: "Alice")
        expect(user.token[14]).to eq("4")
      end
    end

    context "when configured for v7", if: SqliteCrypto::Generators::Uuid.v7_available? do
      before do
        SqliteCrypto.config.uuid_version = :v7
        TestUser.generates_uuid :token
      end

      it "generates UUIDv7" do
        user = TestUser.create!(name: "Alice")
        expect(user.token[14]).to eq("7")
      end
    end
  end

  describe ".generates_ulid" do
    before { TestUser.generates_ulid :reference }

    it "auto-generates valid ULID on create" do
      user = TestUser.create!(name: "Alice")

      expect(user.reference).to match(/\A[0-9A-Z]{26}\z/)
    end

    it "preserves existing values" do
      existing_ulid = "01ARZ3NDEKTSV4RRFFQ69G5FAV"
      user = TestUser.create!(name: "Bob", reference: existing_ulid)

      expect(user.reference).to eq(existing_ulid)
    end

    it "generates time-sortable identifiers" do
      user1 = TestUser.create!(name: "First")
      sleep 0.001
      user2 = TestUser.create!(name: "Second")

      expect(user1.reference).to be < user2.reference
    end

    context "with unique: true" do
      before { TestUser.generates_ulid :reference, unique: true }

      it "enforces uniqueness validation" do
        user1 = TestUser.create!(name: "Alice")
        user2 = TestUser.new(name: "Bob", reference: user1.reference)

        expect(user2).not_to be_valid
        expect(user2.errors[:reference]).to include("has already been taken")
      end
    end
  end

  it "extends ActiveRecord::Base with class methods" do
    expect(ActiveRecord::Base).to respond_to(:generates_uuid)
    expect(ActiveRecord::Base).to respond_to(:generates_ulid)
  end

  describe "auto UUID generation for primary keys" do
    before do
      connection.create_table :uuid_users, id: :uuid, force: true do |t|
        t.string :name
      end

      stub_const("UuidUser", Class.new(ActiveRecord::Base) do
        self.table_name = "uuid_users"
      end)
    end

    after do
      connection.drop_table :uuid_users, if_exists: true
    end

    it "auto-generates UUID for primary key without generates_uuid" do
      user = UuidUser.create!(name: "Alice")

      expect(user.id).to be_present
      expect(user.id).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
    end

    it "preserves manually set primary key" do
      manual_id = "550e8400-e29b-41d4-a716-446655440000"
      user = UuidUser.create!(id: manual_id, name: "Bob")

      expect(user.id).to eq(manual_id)
    end

    it "generates unique UUIDs for each record" do
      user1 = UuidUser.create!(name: "Alice")
      user2 = UuidUser.create!(name: "Bob")

      expect(user1.id).not_to eq(user2.id)
    end
  end

  describe "auto ULID generation for primary keys" do
    before do
      connection.create_table :ulid_items, id: :ulid, force: true do |t|
        t.string :name
      end

      stub_const("UlidItem", Class.new(ActiveRecord::Base) do
        self.table_name = "ulid_items"
      end)
    end

    after do
      connection.drop_table :ulid_items, if_exists: true
    end

    it "auto-generates ULID for primary key without generates_ulid" do
      item = UlidItem.create!(name: "Widget")

      expect(item.id).to be_present
      expect(item.id).to match(/\A[0-9A-Z]{26}\z/)
    end

    it "preserves manually set primary key" do
      manual_id = "01ARZ3NDEKTSV4RRFFQ69G5FAV"
      item = UlidItem.create!(id: manual_id, name: "Widget")

      expect(item.id).to eq(manual_id)
    end
  end

  describe "no auto-generation for integer primary keys" do
    before do
      connection.create_table :int_items, force: true do |t|
        t.string :name
      end

      stub_const("IntItem", Class.new(ActiveRecord::Base) do
        self.table_name = "int_items"
      end)
    end

    after do
      connection.drop_table :int_items, if_exists: true
    end

    it "does not interfere with integer primary keys" do
      item = IntItem.create!(name: "Widget")

      expect(item.id).to be_a(Integer)
    end
  end

  describe "._sqlite_crypto_pk_type" do
    it "returns :uuid for UUID primary key tables" do
      connection.create_table :pk_uuid_test, id: :uuid, force: true do |t|
        t.string :name
      end

      klass = Class.new(ActiveRecord::Base) do
        self.table_name = "pk_uuid_test"
      end

      expect(klass._sqlite_crypto_pk_type).to eq(:uuid)

      connection.drop_table :pk_uuid_test, if_exists: true
    end

    it "returns :ulid for ULID primary key tables" do
      connection.create_table :pk_ulid_test, id: :ulid, force: true do |t|
        t.string :name
      end

      klass = Class.new(ActiveRecord::Base) do
        self.table_name = "pk_ulid_test"
      end

      expect(klass._sqlite_crypto_pk_type).to eq(:ulid)

      connection.drop_table :pk_ulid_test, if_exists: true
    end

    it "returns nil for integer primary key tables" do
      connection.create_table :pk_int_test, force: true do |t|
        t.string :name
      end

      klass = Class.new(ActiveRecord::Base) do
        self.table_name = "pk_int_test"
      end

      expect(klass._sqlite_crypto_pk_type).to be_nil

      connection.drop_table :pk_int_test, if_exists: true
    end

    it "returns nil for abstract classes" do
      klass = Class.new(ActiveRecord::Base) do
        self.abstract_class = true
      end

      expect(klass._sqlite_crypto_pk_type).to be_nil
    end

    it "caches the result" do
      connection.create_table :pk_cache_test, id: :uuid, force: true do |t|
        t.string :name
      end

      klass = Class.new(ActiveRecord::Base) do
        self.table_name = "pk_cache_test"
      end

      result1 = klass._sqlite_crypto_pk_type
      result2 = klass._sqlite_crypto_pk_type

      expect(result1).to eq(:uuid)
      expect(result1).to equal(result2)

      connection.drop_table :pk_cache_test, if_exists: true
    end
  end
end
