# frozen_string_literal: true

require "securerandom"

module SqliteCrypto
  module Generators
    class Uuid
      MINIMUM_RUBY_FOR_V7 = Gem::Version.new("3.3.0")
      CURRENT_RUBY = Gem::Version.new(RUBY_VERSION)

      class << self
        def generate(version: SqliteCrypto.config.uuid_version)
          case version
          when :v4
            generate_v4
          when :v7
            generate_v7
          else
            raise ArgumentError, "Unsupported UUID version: #{version}"
          end
        end

        def v7_available?
          CURRENT_RUBY >= MINIMUM_RUBY_FOR_V7
        end

        private

        def generate_v4
          SecureRandom.uuid
        end

        def generate_v7
          if v7_available?
            SecureRandom.uuid_v7
          else
            raise "UUID v7 generation requires Ruby #{MINIMUM_RUBY_FOR_V7} or later" \
            "Use config.uuid_version = :v4 or upgrade Ruby."
          end
        end
      end
    end
  end
end
