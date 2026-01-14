# frozen_string_literal: true

require "active_record/connection_adapters/sqlite3_adapter"

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
        ref_table = options.delete(:to_table) || ref_name.to_s.pluralize

        if (primary_key_type = detect_primary_key_type(ref_table))
          options[:type] ||= :string
          options[:limit] ||= (primary_key_type == :uuid) ? 36 : 26
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

        case pk_column.sql_type.downcase
        when "varchar(36)", "uuid" then :uuid
        when "varchar(26)", "ulid" then :ulid
        end
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
