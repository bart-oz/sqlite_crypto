# frozen_string_literal: true

require "rails_helper"

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

    it "is included in ActiveRecord::Schema" do
      schema = ActiveRecord::Schema.new
      expect(schema.respond_to?(:uuid)).to be true
      expect(schema.respond_to?(:ulid)).to be true
    end

    if defined?(ActiveRecord::Schema::Definition)
      it "is included in ActiveRecord::Schema::Definition (Rails 8+)" do
        expect(ActiveRecord::Schema::Definition.instance_methods).to include(:uuid)
        expect(ActiveRecord::Schema::Definition.instance_methods).to include(:ulid)
      end
    end
  end
end
