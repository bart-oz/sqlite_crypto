# frozen_string_literal: true

require "sqlite_crypto/type/uuid"
require "sqlite_crypto/type/ulid"

module SqliteCrypto
  class Railtie < ::Rails::Railtie
    # Configuration namespace for users to set options
    config.sqlite_crypto = ActiveSupport::OrderedOptions.new

    initializer "sqlite_crypto.register_types" do
      ActiveRecord::Type.register(:uuid, SqliteCrypto::Type::Uuid, adapter: :sqlite3)
      ActiveRecord::Type.register(:ulid, SqliteCrypto::Type::ULID, adapter: :sqlite3)
    end

    initializer "sqlite_crypto.schema_dumper", after: "active_record.initialize_database" do
      require "active_record/connection_adapters/sqlite3_adapter"
      require "sqlite_crypto/schema_dumper"
      ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.prepend(SqliteCrypto::SchemaDumper)
    end

    initializer "sqlite_crypto.migration_helpers", after: "active_record.initialize_database" do
      require "sqlite_crypto/migration_helpers"
    end

    # Generators (not implemented yet)
    # generators do
    #   require "sqlite_crypto/generators/install_generator"
    # end
  end
end
