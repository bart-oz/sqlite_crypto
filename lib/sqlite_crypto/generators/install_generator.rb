# frozen_string_literal: true

require "rails/generators"
require "rails/generators/base"

module SqliteCrypto
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates SqliteCrypto initializer for UUID/ULID configuration"

      def create_initializer_file
        template "initializer.rb.tt", "config/initializers/sqlite_crypto.rb"
      end

      def display_post_install_message
        say ""
        say "SqliteCrypto installed!", :green
        say ""
        say "Configuration created at config/initializers/sqlite_crypto.rb"
        say ""
        if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0")
          say "✓ Ruby #{RUBY_VERSION} detected - UUIDv7 is available (default)", :green
        else
          say "⚠ Ruby #{RUBY_VERSION} detected - UUIDv7 requires Ruby 3.3+", :yellow
          say "  Update initializer to use: config.uuid_version = :v4"
        end
        say ""
        say "Next steps:"
        say "  1. Review config/initializers/sqlite_crypto.rb"
        say "  2. Use id: :uuid in migrations for UUID primary keys"
        say ""
      end
    end
  end
end
