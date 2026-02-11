# frozen_string_literal: true

SqliteCrypto.configure do |config|
  # UUID generation version: :v4 (random) or :v7 (time-sortable)
  #
  # :v7 - Time-sortable UUIDs with better database index performance
  #       Recommended for new projects. Requires Ruby 3.3+
  #
  # :v4 - Random UUIDs, works on all Ruby versions (3.1+)
  #       Use if you need Ruby 3.1/3.2 compatibility
  #
  config.uuid_version = :v7 # UUIDv7 is set as default
end
