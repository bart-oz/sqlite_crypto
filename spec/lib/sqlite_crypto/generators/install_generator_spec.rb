# frozen_string_literal: true

require "rails_helper"
require "generator_spec"
require "generators/sqlite_crypto/install/install_generator"

RSpec.describe SqliteCrypto::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../../../../tmp/generator_test", __dir__)

  before(:all) do
    prepare_destination
    run_generator
  end

  after(:all) do
    FileUtils.rm_rf(destination_root)
  end

  describe "initializer creation" do
    let(:initializer_path) { File.join(destination_root, "config/initializers/sqlite_crypto.rb") }

    it "creates initializer file" do
      expect(File).to exist(initializer_path)
    end

    it "initializer contains configuration block" do
      content = File.read(initializer_path)
      expect(content).to include("SqliteCrypto.configure")
    end

    it "initializer sets uuid_version" do
      content = File.read(initializer_path)
      expect(content).to include("config.uuid_version = :v7")
    end

    it "initializer includes helpful comments" do
      content = File.read(initializer_path)
      expect(content).to include("time-sortable")
      expect(content).to include("Ruby 3.3+")
    end
  end
end
