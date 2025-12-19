# frozen_string_literal: true

require "spec_helper"
require "active_record"
require "sqlite_crypto/type/ulid"

RSpec.describe SqliteCrypto::Type::ULID do
  let(:type) { described_class.new }
  let(:valid_ulid) { "01ARZ3NDEKTSV4RRFFQ69G5FAV" }

  it "returns :ulid as type identifier" do
    expect(type.type).to eq(:ulid)
  end

  describe "#cast" do
    it "accepts valid ULID (any case)" do
      expect(type.cast(valid_ulid)).to eq(valid_ulid)
      expect(type.cast(valid_ulid.downcase)).to eq(valid_ulid.downcase)
    end

    it "accepts ULID starting with 0-7" do
      expect(type.cast("01ARZNSNHFK22F6MTGZEN3WR02")).to eq("01ARZNSNHFK22F6MTGZEN3WR02")
      expect(type.cast("7ZZZZZZZZZZZZZZZZZZZZZZZZZ")).to eq("7ZZZZZZZZZZZZZZZZZZZZZZZZZ")
    end

    it "returns nil for nil input" do
      expect(type.cast(nil)).to be_nil
    end

    it "converts object to string if it responds to to_s" do
      obj = double(to_s: valid_ulid)
      expect(type.cast(obj)).to eq(valid_ulid)
    end

    it "raises ArgumentError for invalid formats" do
      invalid_cases = [
        "not-a-ulid",                          # malformed
        "01ARZ3NDEKTSV4RRFF",                  # too short
        "01ARZ3NDEKTSV4RRFFQ69G5FAVEXTRA",     # too long
        "01ARZ3-NDEKTSV4RRFFQ69G5FAV",         # contains hyphens
        "8ZZZZZZZZZZZZZZZZZZZZZZZZZ",          # starts with 8 (invalid)
        "01ARZ3NDEKTSV4RRFFQ69G5F@V"           # invalid character
      ]

      invalid_cases.each do |invalid|
        expect { type.cast(invalid) }.to raise_error(ArgumentError, /Invalid ULID/)
      end
    end
  end

  describe "#serialize and #deserialize" do
    it "roundtrips valid ULID through database" do
      expect(type.serialize(valid_ulid)).to eq(valid_ulid)
      expect(type.deserialize(valid_ulid)).to eq(valid_ulid)
    end

    it "handles nil" do
      expect(type.serialize(nil)).to be_nil
      expect(type.deserialize(nil)).to be_nil
    end
  end

  describe "#changed_in_place?" do
    it "detects when values differ" do
      ulid1 = "01ARZ3NDEKTSV4RRFFQ69G5FAV"
      ulid2 = "01BRZ3NDEKTSV4RRFFQ69G5FAV"

      expect(type.changed_in_place?(ulid1, ulid1)).to be false
      expect(type.changed_in_place?(ulid1, ulid2)).to be true
      expect(type.changed_in_place?(nil, ulid1)).to be true
    end
  end
end
