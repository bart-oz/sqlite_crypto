# frozen_string_literal: true

require "sqlite_crypto/type/base"

module SqliteCrypto
  module Type
    class Uuid < Base
      def type
        :uuid
      end

      private

      def valid?(value)
        value.match?(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)
      end
    end
  end
end
