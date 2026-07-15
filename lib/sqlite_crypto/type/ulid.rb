# frozen_string_literal: true

require "sqlite_crypto/type/base"

module SqliteCrypto
  module Type
    class ULID < Base
      # Crockford base32 excludes I, L, O, U to avoid confusion with 1, 0.
      ULID_PATTERN = /\A[0-7][0-9A-HJKMNP-TV-Z]{25}\z/i

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
