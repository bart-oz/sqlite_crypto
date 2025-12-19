# frozen_string_literal: true

require "spec_helper"
require "rails"
require "sqlite3"
require "active_record"

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
