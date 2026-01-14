# frozen_string_literal: true

module SqliteCrypto
  class Configuration
    attr_reader :uuid_version

    def initialize
      # Default to v7 on Ruby 3.3+, v4 on older versions
      @uuid_version = Generators::Uuid.v7_available? ? :v7 : :v4
    end

    def uuid_version=(version)
      validate_uuid_version!(version)
      @uuid_version = version
    end

    private

    def validate_uuid_version!(version)
      valid_versions = [:v4, :v7]
      unless valid_versions.include?(version)
        raise ArgumentError, "Invalid UUID version: #{version}. Must be one of #{valid_versions.join(", ")}"
      end

      if version == :v7 && !Generators::Uuid.v7_available?
        raise ArgumentError,
          "UUIDv7 requires Ruby 3.3+. Current: #{RUBY_VERSION}. " \
          "Use config.uuid_version = :v4 or upgrade Ruby."
      end
    end
  end
end
