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

    it "can be set to :v7 explicitly" do
      config.uuid_version = :v7
      expect(config.uuid_version).to eq(:v7)
    end
  end
end
