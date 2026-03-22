# frozen_string_literal: true

require "ulid"

module SqliteCrypto
  module ModelExtensions
    extend ActiveSupport::Concern

    included do
      before_create :_sqlite_crypto_auto_generate_id
    end

    private

    def _sqlite_crypto_auto_generate_id
      pk = self.class.primary_key
      return unless pk
      return if self[pk].present?

      case self.class._sqlite_crypto_pk_type
      when :uuid
        self[pk] = SqliteCrypto::Generators::Uuid.generate
      when :ulid
        self[pk] = ULID.generate.to_s
      end
    end

    module ClassMethods
      def generates_uuid(attribute, unique: false)
        before_create do
          self[attribute] ||= SqliteCrypto::Generators::Uuid.generate
        end

        validates attribute, uniqueness: true if unique
      end

      def generates_ulid(attribute, unique: false)
        before_create do
          self[attribute] ||= ULID.generate.to_s
        end

        validates attribute, uniqueness: true if unique
      end

      # Detect if primary key is UUID or ULID based on column schema.
      # Cached per class. Returns :uuid, :ulid, or nil.
      def _sqlite_crypto_pk_type
        return @_sqlite_crypto_pk_type if defined?(@_sqlite_crypto_pk_type)
        @_sqlite_crypto_pk_type = _detect_sqlite_crypto_pk_type
      end

      private

      def _detect_sqlite_crypto_pk_type
        return nil if abstract_class?
        return nil unless table_exists?

        pk = primary_key
        return nil unless pk

        column = columns_hash[pk]
        return nil unless column
        return nil unless column.type == :string

        case column.limit
        when 36 then :uuid
        when 26 then :ulid
        end
      rescue ActiveRecord::StatementInvalid
        nil
      end
    end
  end
end

ActiveRecord::Base.include(SqliteCrypto::ModelExtensions) if defined?(ActiveRecord::Base)
