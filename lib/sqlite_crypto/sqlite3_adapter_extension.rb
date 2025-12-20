# frozen_string_literal: true

module SqliteCrypto
  module Sqlite3AdapterExtension
    extend ActiveSupport::Concern

    included do
      alias_method :original_create_table, :create_table
    end

    def create_table(table_name, **options, &block)
      id_type = options[:id]

      if id_type.to_s == "uuid" || id_type.to_s == "ulid"
        options = options.except(:id)

        original_create_table(table_name, options.merge(id: false), &block)

        add_column(table_name, :id, id_type, primary_key: true)
      else
        original_create_table(table_name, **options, &block)
      end
    end
  end
end
