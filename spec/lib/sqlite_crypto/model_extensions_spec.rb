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
end
