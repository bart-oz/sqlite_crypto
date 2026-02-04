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

# Extend ActiveRecord::Schema context for schema.rb loading (not global Object)
if defined?(ActiveRecord::Schema)
  ActiveRecord::Schema.include(SqliteCrypto::SchemaDefinitions)
end

# For Rails 8+, also include in Schema::Definition where the block is evaluated
if defined?(ActiveRecord::Schema::Definition)
  ActiveRecord::Schema::Definition.include(SqliteCrypto::SchemaDefinitions)
end
