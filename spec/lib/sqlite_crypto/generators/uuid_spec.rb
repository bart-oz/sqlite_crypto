# frozen_string_literal: true

require "spec_helper"

RSpec.describe SqliteCrypto::Generators::Uuid do
  before { SqliteCrypto.reset_configuration! }
  after { SqliteCrypto.reset_configuration! }

  describe ".generate" do
    context "with v4" do
      before { SqliteCrypto.config.uuid_version = :v4 }

      it "generates valid UUIDv4" do
        uuid = described_class.generate
        expect(uuid).to match(/\A\h{8}-\h{4}-4\h{3}-[89ab]\h{3}-\h{12}\z/i)
      end

      it "generates unique values" do
        uuids = Array.new(100) { described_class.generate }
        expect(uuids.uniq.size).to eq(100)
      end
    end

    context "with v7", if: described_class.v7_available? do
      before { SqliteCrypto.config.uuid_version = :v7 }

      it "generates valid UUIDv7" do
        uuid = described_class.generate
        expect(uuid).to match(/\A\h{8}-\h{4}-7\h{3}-[89ab]\h{3}-\h{12}\z/i)
      end

      it "generates chronologically sortable values" do
        uuid1 = described_class.generate
        sleep(0.002)
        uuid2 = described_class.generate
        expect(uuid2 > uuid1).to be true
      end

      it "generates unique values" do
        uuids = Array.new(100) { described_class.generate }
        expect(uuids.uniq.size).to eq(100)
      end
    end

    context "with v7 on Ruby < 3.3", unless: described_class.v7_available? do
      it "raises ArgumentError with helpful message" do
        expect { described_class.generate(version: :v7) }
          .to raise_error(ArgumentError, /UUIDv7 requires Ruby 3\.3\+/)
      end
    end

    it "allows version override parameter" do
      uuid = described_class.generate(version: :v4)
      expect(uuid[14]).to eq("4")
    end

    it "raises ArgumentError for invalid version" do
      expect { described_class.generate(version: :v8) }
        .to raise_error(ArgumentError, /Unsupported UUID version/)
    end
  end

  describe ".v7_available?" do
    it "returns boolean" do
      expect(described_class.v7_available?).to eq(true).or eq(false)
    end

    it "returns true for Ruby 3.3+" do
      stub_const("SqliteCrypto::Generators::Uuid::CURRENT_RUBY", Gem::Version.new("3.3.0"))
      expect(described_class.v7_available?).to be true
    end

    it "returns false for Ruby < 3.3" do
      stub_const("SqliteCrypto::Generators::Uuid::CURRENT_RUBY", Gem::Version.new("3.2.0"))
      expect(described_class.v7_available?).to be false
    end
  end
end
