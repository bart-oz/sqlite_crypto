# frozen_string_literal: true

# Module to add uuid/ulid helper methods to schema loading context
module SqliteCrypto
  module SchemaDefinitions
    def uuid
      :uuid
    end

    def ulid
      :ulid
    end
  end
end

# Extend the main object context for schema.rb loading
Object.include(SqliteCrypto::SchemaDefinitions)
