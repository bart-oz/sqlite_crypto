# frozen_string_literal: true

require "spec_helper"
require "active_record"
require "sqlite_crypto/type/uuid"

RSpec.describe SqliteCrypto::Type::Uuid do
  let(:type) { described_class.new }
  let(:valid_uuid) { "550e8400-e29b-41d4-a716-446655440000" }

  it "returns :uuid as type identifier" do
    expect(type.type).to eq(:uuid)
  end

  describe "#cast" do
    it "accepts valid UUID (any case)" do
      expect(type.cast(valid_uuid)).to eq(valid_uuid)
      expect(type.cast(valid_uuid.upcase)).to eq(valid_uuid.upcase)
    end

    it "returns nil for nil input" do
      expect(type.cast(nil)).to be_nil
    end

    it "converts object to string if it responds to to_s" do
      obj = double(to_s: valid_uuid)
      expect(type.cast(obj)).to eq(valid_uuid)
    end

    it "raises ArgumentError for invalid formats" do
      invalid_cases = [
        "not-a-uuid",                                   # malformed
        "550e8400e29b41d4a716446655440000",             # missing hyphens
        "550e8400-e29b-41d4-a716",                      # too short
        "550e8400-e29b-41d4-a716-446655440000-extra"    # too long
      ]

      invalid_cases.each do |invalid|
        expect { type.cast(invalid) }.to raise_error(ArgumentError, /Invalid UUID/)
      end
    end
  end

  describe "#serialize and #deserialize" do
    it "roundtrips valid UUID through database" do
      expect(type.serialize(valid_uuid)).to eq(valid_uuid)
      expect(type.deserialize(valid_uuid)).to eq(valid_uuid)
    end

    it "handles nil" do
      expect(type.serialize(nil)).to be_nil
      expect(type.deserialize(nil)).to be_nil
    end
  end

  describe "#changed_in_place?" do
    it "detects when values differ" do
      uuid1 = "550e8400-e29b-41d4-a716-446655440000"
      uuid2 = "660e8400-e29b-41d4-a716-446655440000"

      expect(type.changed_in_place?(uuid1, uuid1)).to be false
      expect(type.changed_in_place?(uuid1, uuid2)).to be true
      expect(type.changed_in_place?(nil, uuid1)).to be true
    end
  end
end
