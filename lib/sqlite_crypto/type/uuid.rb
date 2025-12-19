# frozen_string_literal: true

module SqliteCrypto
  module Type
    class Uuid < ActiveRecord::Type::String
      def type
        :uuid
      end

      def deserialize(value)
        return if value.nil?

        cast(value)
      end

      def cast(value)
        return if value.nil?
        return value if value.is_a?(String) && valid_uuid?(value)

        if value.respond_to?(:to_s)
          str = value.to_s

          return str if valid_uuid?(str)
        end

        raise ArgumentError, "Invalid UUID: #{value.inspect}"
      end

      def serialize(value)
        cast(value)
      end

      def changed_in_place?(raw_old_value, new_value)
        cast(raw_old_value) != cast(new_value)
      end

      private

      def valid_uuid?(value)
        value.match?(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)
      end
    end
  end
end
