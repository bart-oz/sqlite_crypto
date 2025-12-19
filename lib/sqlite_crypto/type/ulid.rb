# frozen_string_literal: true

require "sqlite_crypto/type/base"

module SqliteCrypto
  module Type
    class ULID < Base
      def type
        :ulid
      end

      private

      def valid?(value)
        value.match?(/^[0-7][0-9A-Z]{25}$/i)
      end
    end
  end
end
