# frozen_string_literal: true

require "spec_helper"

RSpec.describe SqliteCrypto::IdTypes do
  describe ".string_limit_for" do
    it "returns the UUID length for :uuid" do
      expect(described_class.string_limit_for(:uuid)).to eq(36)
    end

    it "returns the ULID length for :ulid" do
      expect(described_class.string_limit_for(:ulid)).to eq(26)
    end
  end

  describe ".type_from_string_limit" do
    it "detects UUID from its string length" do
      expect(described_class.type_from_string_limit(36)).to eq(:uuid)
    end

    it "detects ULID from its string length" do
      expect(described_class.type_from_string_limit(26)).to eq(:ulid)
    end

    it "returns nil for unknown lengths" do
      expect(described_class.type_from_string_limit(64)).to be_nil
    end
  end

  describe ".type_from_sql_type" do
    it "detects UUID-compatible sql types" do
      expect(described_class.type_from_sql_type("varchar(36)")).to eq(:uuid)
      expect(described_class.type_from_sql_type("UUID")).to eq(:uuid)
    end

    it "detects ULID-compatible sql types" do
      expect(described_class.type_from_sql_type("varchar(26)")).to eq(:ulid)
      expect(described_class.type_from_sql_type("ULID")).to eq(:ulid)
    end

    it "returns nil for other sql types" do
      expect(described_class.type_from_sql_type("integer")).to be_nil
    end
  end
end
