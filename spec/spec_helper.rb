# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/sqlite_crypto/version.rb"
  add_filter "/lib/sqlite_crypto/railtie.rb"
  add_filter "/lib/sqlite_crypto/schema_definitions.rb"
  track_files "lib/**/*.rb"
  minimum_coverage 80
  minimum_coverage_by_file 70
end

require "bundler/setup"
require "rspec"

# Load sqlite_crypto
require_relative "../lib/sqlite_crypto"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/.rspec_status"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed
end
