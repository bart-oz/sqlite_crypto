# frozen_string_literal: true

require "spec_helper"

RSpec.describe SqliteCrypto::Configuration do
  subject(:config) { described_class.new }

  describe "#uuid_version" do
    it "defaults to :v7" do
      expect(config.uuid_version).to eq(:v7)
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
