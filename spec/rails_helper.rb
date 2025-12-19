# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  track_files "lib/**/*.rb"
end

ENV["RAILS_ENV"] = "test"

require "rspec"
require "rails"
require "action_controller/railtie"
require "active_record/railtie"
require "sqlite3"

# Minimal Rails application for testing
module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("../", __dir__)
    config.eager_load = false
    config.logger = Logger.new(nil)
    config.active_support.deprecation = :log
    config.active_support.test_order = :random
    config.paths["config/environments"] = []
  end
end

# Load gem before Rails initializes
require_relative "../lib/sqlite_crypto"

# Initialize Rails and establish database connection
Dummy::Application.initialize!
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Helper to create test tables
def create_test_table(table_name = "users", &block)
  ActiveRecord::Base.connection.create_table(table_name, force: true, &block)
end

RSpec.configure do |config|
  config.after(:each) do
    # Clean up test tables after each test
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table, if_exists: true)
    end
  end
end
