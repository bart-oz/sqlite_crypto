# frozen_string_literal: true

module SqliteCrypto
  class Configuration
    attr_accessor :uuid_version

    def initialize
      # Default to v7 on Ruby 3.3+, v4 on older versions
      @uuid_version = (Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0")) ? :v7 : :v4
    end
  end
end
