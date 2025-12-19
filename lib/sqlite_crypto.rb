# frozen_string_literal: true

require "sqlite_crypto/version"
require "sqlite_crypto/railtie" if defined?(Rails)
require "sqlite_crypto/schema_dumper" if defined?(ActiveRecord)

module SqliteCrypto
  class Error < StandardError; end

  def self.load_extensions
    # Placeholder for future extension loading logic
  end
end
