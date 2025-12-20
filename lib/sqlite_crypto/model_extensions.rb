# frozen_string_literal: true

require "ulid"

module SqliteCrypto
  module ModelExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      def generates_uuid(attribute, unique: false)
        before_create do
          self[attribute] ||= SecureRandom.uuid
        end

        validates attribute, uniqueness: true if unique
      end

      def generates_ulid(attribute, unique: false)
        before_create do
          self[attribute] ||= ULID.generate.to_s
        end

        validates attribute, uniqueness: true if unique
      end
    end
  end
end

ActiveRecord::Base.include(SqliteCrypto::ModelExtensions) if defined?(ActiveRecord::Base)
