# frozen_string_literal: true

require "spec_helper"

RSpec.describe SqliteCrypto do
  describe "version" do
    it "has a version number" do
      expect(SqliteCrypto::VERSION).not_to be_nil
      expect(SqliteCrypto::VERSION).to eq("1.0.3")
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

  describe "initialization" do
    it "loads successfully" do
      expect(defined?(SqliteCrypto)).to eq("constant")
    end
  end

  describe ".load_extensions" do
    it "responds to load_extensions" do
      expect(SqliteCrypto).to respond_to(:load_extensions)
    end
  end
end
