# frozen_string_literal: true

require "spec_helper"

RSpec.describe SqliteCrypto do
  describe "version" do
    it "has a version number" do
      expect(SqliteCrypto::VERSION).not_to be_nil
      expect(SqliteCrypto::VERSION).to eq("2.0.1")
    end
  end

  describe "version constants" do
    it "defines minimum Ruby version" do
      expect(SqliteCrypto::RUBY_MINIMUM_VERSION).to eq("3.1.0")
    end

    it "defines minimum Rails version" do
      expect(SqliteCrypto::RAILS_MINIMUM_VERSION).to eq("7.1.0")
    end
  end

  describe ".configure" do
    after { described_class.reset_configuration! }

    it "yields configuration to block" do
      described_class.configure do |config|
        config.uuid_version = :v4
      end

      expect(described_class.config.uuid_version).to eq(:v4)
    end
  end

  describe ".config" do
    after { described_class.reset_configuration! }

    it "returns configuration instance" do
      expect(described_class.config).to be_a(SqliteCrypto::Configuration)
    end

    it "returns same instance on multiple calls" do
      expect(described_class.config).to be(described_class.config)
    end
  end

  describe ".configuration" do
    it "is aliased to .config" do
      expect(described_class.configuration).to be(described_class.config)
    end
  end

  describe ".reset_configuration!" do
    it "creates new configuration instance" do
      original = described_class.config
      described_class.reset_configuration!
      expect(described_class.config).not_to be(original)
    end

    it "resets uuid_version to default" do
      original_default = SqliteCrypto::Generators::Uuid.v7_available? ? :v7 : :v4
      described_class.config.uuid_version = :v4
      described_class.reset_configuration!
      expect(described_class.config.uuid_version).to eq(original_default)
    end
  end

  describe "initialization" do
    it "loads successfully" do
      expect(defined?(SqliteCrypto)).to eq("constant")
    end
  end
end
