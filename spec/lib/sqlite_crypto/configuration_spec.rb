# frozen_string_literal: true

require "spec_helper"

RSpec.describe SqliteCrypto::Configuration do
  subject(:config) { described_class.new }

  describe "#uuid_version" do
    it "defaults based on Ruby version" do
      expected_default = SqliteCrypto::Generators::Uuid.v7_available? ? :v7 : :v4
      expect(config.uuid_version).to eq(expected_default)
    end

    it "can be set to :v4" do
      config.uuid_version = :v4
      expect(config.uuid_version).to eq(:v4)
    end

    context "when setting :v7" do
      it "accepts :v7 on Ruby 3.3+" do
        skip "Only testable on Ruby 3.3+" unless SqliteCrypto::Generators::Uuid.v7_available?

        config.uuid_version = :v7
        expect(config.uuid_version).to eq(:v7)
      end

      it "raises ArgumentError on Ruby < 3.3" do
        skip "Only testable on Ruby < 3.3" if SqliteCrypto::Generators::Uuid.v7_available?

        expect {
          config.uuid_version = :v7
        }.to raise_error(ArgumentError, /UUIDv7 requires Ruby 3.3/)
      end
    end

    it "raises ArgumentError for invalid versions" do
      expect {
        config.uuid_version = :v5
      }.to raise_error(ArgumentError, /Invalid UUID version: v5/)
    end

    it "raises ArgumentError for non-symbol versions" do
      expect {
        config.uuid_version = "v4"
      }.to raise_error(ArgumentError, /Invalid UUID version: v4/)
    end
  end
end
