# frozen_string_literal: true

module SqliteCrypto
  module SchemaDumper
    private

    def column_spec_for_primary_key(column)
      return super unless column.name == "id" && column.type == :string

      case column.limit
      when 36 then {id: :uuid}
      when 26 then {id: :ulid}
      else super
      end
    end
  end
end
