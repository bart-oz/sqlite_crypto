# frozen_string_literal: true

require "sqlite_crypto/type/uuid"
require "sqlite_crypto/type/ulid"
require "sqlite_crypto/sqlite3_adapter_extension"

module SqliteCrypto
  class Railtie < ::Rails::Railtie
    # Configuration namespace for users to set options
    config.sqlite_crypto = ActiveSupport::OrderedOptions.new

    initializer "sqlite_crypto.register_types" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Type.register(:uuid, SqliteCrypto::Type::Uuid, adapter: :sqlite3)
        ActiveRecord::Type.register(:ulid, SqliteCrypto::Type::ULID, adapter: :sqlite3)
      end
    end

    initializer "sqlite_crypto.native_types" do
      ActiveSupport.on_load(:active_record) do
        require "active_record/connection_adapters/sqlite3_adapter"
        ActiveRecord::ConnectionAdapters::SQLite3Adapter.prepend(SqliteCrypto::Sqlite3AdapterExtension)
      end
    end

    initializer "sqlite_crypto.schema_dumper", after: "active_record.initialize_database" do
      require "active_record/connection_adapters/sqlite3_adapter"
      require "sqlite_crypto/schema_dumper"
      ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.prepend(SqliteCrypto::SchemaDumper)
    end

    initializer "sqlite_crypto.migration_helpers", after: "active_record.initialize_database" do
      require "sqlite_crypto/migration_helpers"
    end

    initializer "sqlite_crypto.model_extensions", after: "active_record.initialize_database" do
      require "sqlite_crypto/model_extensions"
    end
  end
end
