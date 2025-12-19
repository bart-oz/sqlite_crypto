# frozen_string_literal: true

module SqliteCrypto
  class Railtie < ::Rails::Railtie
    # Configuration namespace for users to set options
    config.sqlite_crypto = ActiveSupport::OrderedOptions.new

    initializer "sqlite_crypto.register_types" do
      # Will register custom types with ActiveRecord
    end

    initializer "sqlite_crypto.migration_helpers" do |app|
      # Will make migration helpers available
    end

    generators do
      # Will load generators
    end
  end
end
