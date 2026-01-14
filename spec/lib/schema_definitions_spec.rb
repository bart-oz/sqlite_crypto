# frozen_string_literal: true

require "spec_helper"

RSpec.describe SqliteCrypto::SchemaDefinitions do
  describe "namespace scoping" do
    it "does not pollute Object namespace" do
      obj = Object.new
      expect(obj).not_to respond_to(:uuid)
      expect(obj).not_to respond_to(:ulid)
    end

    it "module defines uuid method" do
      expect(described_class.instance_methods).to include(:uuid)
    end

    it "module defines ulid method" do
      expect(described_class.instance_methods).to include(:ulid)
    end

    it "uuid method returns :uuid symbol" do
      test_class = Class.new do
        include SqliteCrypto::SchemaDefinitions
      end

      expect(test_class.new.uuid).to eq(:uuid)
    end

    it "ulid method returns :ulid symbol" do
      test_class = Class.new do
        include SqliteCrypto::SchemaDefinitions
      end

      expect(test_class.new.ulid).to eq(:ulid)
    end
  end
end
