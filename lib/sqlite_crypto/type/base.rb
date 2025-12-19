# frozen_string_literal: true

module SqliteCrypto
  module Type
    class Base < ActiveRecord::Type::String
      def deserialize(value)
        return if value.nil?
        cast(value)
      end

      def cast(value)
        return if value.nil?
        return value if value.is_a?(String) && valid?(value)

        if value.respond_to?(:to_s)
          str = value.to_s
          return str if valid?(str)
        end

        raise ArgumentError, "Invalid #{type.upcase}: #{value.inspect}"
      end

      def serialize(value)
        cast(value)
      end

      def changed_in_place?(raw_old_value, new_value)
        cast(raw_old_value) != cast(new_value)
      end

      private

      def valid?(value)
        raise NotImplementedError, "Subclasses must implement #valid?"
      end
    end
  end
end
