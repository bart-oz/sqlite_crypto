# frozen_string_literal: true

require "spec_helper"
require "active_record"
require "rails"
require "sqlite_crypto/railtie"

RSpec.describe SqliteCrypto::Railtie do
  describe "railtie structure" do
    it "is a Rails::Railtie" do
      expect(described_class.superclass).to eq(Rails::Railtie)
    end

    it "defines configuration namespace" do
      expect(described_class.config).to respond_to(:sqlite_crypto)
    end
  end

  describe "initializers" do
    it "defines register_types initializer" do
      initializer = described_class.initializers.find { |i| i.name == "sqlite_crypto.register_types" }
      expect(initializer).not_to be_nil
    end

    # It will be implemented while migration_helpers initializer
    # it "defines migration_helpers initializer" do
    #   initializer = described_class.initializers.find { |i| i.name == "sqlite_crypto.migration_helpers" }
    #   expect(initializer).not_to be_nil
    # end
  end

  describe "structure" do
    it "is a Railtie subclass" do
      # Railties can't be instantiated directly, just verify class structure
      expect(described_class.ancestors).to include(Rails::Railtie)
    end
  end
end
