# frozen_string_literal: true

require "sqlite_crypto/type/base"

module SqliteCrypto
  module Type
    class Uuid < Base
      UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

      def type
        :uuid
      end

      private

      def valid?(value)
        UUID_PATTERN.match?(value)
      end
    end
  end
end
