# frozen_string_literal: true

require "sqlite_crypto/id_types"

module SqliteCrypto
  module SchemaDumper
    private

    def column_spec_for_primary_key(column)
      return super unless column.name == "id" && column.type == :string

      primary_key_type = IdTypes.type_from_string_limit(column.limit)
      return super unless primary_key_type

      {id: primary_key_type}
    end
  end
end
