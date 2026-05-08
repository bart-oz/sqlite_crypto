# frozen_string_literal: true

module SqliteCrypto
  module IdTypes
    UUID_LENGTH = 36
    ULID_LENGTH = 26

    TYPE_TO_LIMIT = {
      uuid: UUID_LENGTH,
      ulid: ULID_LENGTH
    }.freeze
    LIMIT_TO_TYPE = TYPE_TO_LIMIT.invert.freeze

    module_function

    def string_limit_for(type)
      TYPE_TO_LIMIT[type]
    end

    def type_from_string_limit(limit)
      LIMIT_TO_TYPE[limit]
    end

    def type_from_sql_type(sql_type)
      case sql_type.to_s.downcase
      when "varchar(#{UUID_LENGTH})", "uuid" then :uuid
      when "varchar(#{ULID_LENGTH})", "ulid" then :ulid
      end
    end
  end
end
