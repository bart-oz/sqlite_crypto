# frozen_string_literal: true

require "sqlite_crypto/version"
require "sqlite_crypto/configuration"
require "sqlite_crypto/railtie" if defined?(Rails)
require "sqlite_crypto/schema_dumper" if defined?(ActiveRecord)
require "sqlite_crypto/schema_definitions"
require "sqlite_crypto/generators/uuid"

module SqliteCrypto
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end
    alias_method :config, :configuration

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end

  def self.load_extensions
    # Placeholder for future extension loading logic
  end
end
