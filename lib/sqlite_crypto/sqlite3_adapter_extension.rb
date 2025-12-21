# frozen_string_literal: true

module SqliteCrypto
  module Sqlite3AdapterExtension
    def native_database_types
      super.merge(
        uuid: { name: "varchar", limit: 36 },
        ulid: { name: "varchar", limit: 26 }
      )
    end
  end
end
