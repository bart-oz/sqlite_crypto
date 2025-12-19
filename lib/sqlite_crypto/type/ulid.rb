# frozen_string_literal: true

module SqliteCrypto
  module Type
    class ULID < ActiveRecord::Type::String
      def type
        :ulid
      end

      def deserialize(value)
        return if value.nil?
        cast(value)
      end

      def cast(value)
        return if value.nil?

        return value if value.is_a?(String) && valid_ulid?(value)

        if value.respond_to?(:to_s)
          str = value.to_s
          return str if valid_ulid?(str)
        end

        raise ArgumentError, "Invalid ULID: #{value.inspect}"
      end

      def serialize(value)
        cast(value)
      end

      def changed_in_place?(raw_old_value, new_value)
        cast(raw_old_value) != cast(new_value)
      end

      private

      def valid_ulid?(value)
        value.match?(/^[0-7][0-9A-Z]{25}$/i)
      end
    end
  end
end
