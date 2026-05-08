# frozen_string_literal: true

require "sqlite_crypto/id_types"

module SqliteCrypto
  module Sqlite3AdapterExtension
    def native_database_types
      super.merge(
        uuid: {name: "varchar", limit: IdTypes::UUID_LENGTH},
        ulid: {name: "varchar", limit: IdTypes::ULID_LENGTH}
      )
    end
  end
end
