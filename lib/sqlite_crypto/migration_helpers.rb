# frozen_string_literal: true

require "active_record/connection_adapters/sqlite3_adapter"
require "sqlite_crypto/id_types"

module SqliteCrypto
  module MigrationHelpers
    module TableDefinition
      def uuid(name, **options)
        column(name, :uuid, **options)
      end

      def ulid(name, **options)
        column(name, :ulid, **options)
      end
    end

    module References
      def references(*args, **options)
        ref_name = args.first
        explicit_to_table = options.delete(:to_table)
        ref_table = explicit_to_table || ref_name.to_s.pluralize

        if (primary_key_type = detect_primary_key_type(ref_table))
          options[:type] ||= :string
          options[:limit] ||= IdTypes.string_limit_for(primary_key_type)
        end

        if explicit_to_table && options[:foreign_key]
          fk_options = options[:foreign_key].is_a?(Hash) ? options[:foreign_key] : {}
          options[:foreign_key] = fk_options.reverse_merge(to_table: explicit_to_table)
        end

        super
      end

      alias_method :belongs_to, :references

      private

      def detect_primary_key_type(table_name)
        @pk_type_cache ||= {}
        @pk_type_cache[table_name] ||= fetch_primary_key_type(table_name)
      end

      def fetch_primary_key_type(table_name)
        conn = @conn || @base || (respond_to?(:connection) ? connection : nil)
        return nil unless conn&.table_exists?(table_name)

        pk_column = find_primary_key_column(table_name, conn)
        return nil unless pk_column

        IdTypes.type_from_sql_type(pk_column.sql_type)
      end

      def find_primary_key_column(table_name, conn)
        pk_name = conn.primary_key(table_name)
        return nil unless pk_name

        conn.columns(table_name).find { |c| c.name == pk_name }
      end
    end
  end
end

# Extend ActiveRecord classes
ActiveRecord::ConnectionAdapters::SQLite3::TableDefinition.include(SqliteCrypto::MigrationHelpers::TableDefinition)
ActiveRecord::ConnectionAdapters::SQLite3::TableDefinition.prepend(SqliteCrypto::MigrationHelpers::References)
ActiveRecord::ConnectionAdapters::Table.include(SqliteCrypto::MigrationHelpers::TableDefinition)
ActiveRecord::ConnectionAdapters::Table.prepend(SqliteCrypto::MigrationHelpers::References)
