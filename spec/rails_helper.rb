# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  track_files "lib/**/*.rb"
end

require "rspec"
require "rails"
require "action_controller/railtie"
require "active_record/railtie"
require "sqlite3"
require "active_record"

# Create a minimal Rails application for testing
module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.logger = Logger.new(nil)
    config.active_support.deprecation = :log
    config.active_support.test_order = :random
  end
end

# Now load our gem (which includes the Railtie)
# This must happen before Rails.application.initialize!
require_relative "../lib/sqlite_crypto"

# Initialize the Rails app (runs all initializers)
Dummy::Application.initialize!

# Configure Active Record for testing
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

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
