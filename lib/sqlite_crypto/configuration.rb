# frozen_string_literal: true

module SqliteCrypto
  class Configuration
    attr_accessor :uuid_version

    def initialize
      @uuid_version = :v7 # Default UUID version
    end
  end
end
