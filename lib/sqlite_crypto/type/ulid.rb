# frozen_string_literal: true

require "sqlite_crypto/type/base"

module SqliteCrypto
  module Type
    class ULID < Base
      ULID_PATTERN = /\A[0-7][0-9A-Z]{25}\z/i

      def type
        :ulid
      end

      private

      def valid?(value)
        ULID_PATTERN.match?(value)
      end
    end
  end
end
