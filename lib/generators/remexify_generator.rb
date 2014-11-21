require "rails/generators"
require "rails/generators/migration"
require "rails/generators/named_base"

module Remexify
  module Generators
    class RemexifyGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a model with the given NAME for remexify to log error/informations"

      namespace "remexify"

      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def copy_migration
        migration_template "create_remexify_lognotes.rb", "db/migrate/create_remexify_lognotes.rb"
        migration_template "create_remexify_logowners.rb", "db/migrate/create_remexify_logowners.rb"
      end

      def generate_model
        invoke "active_record:model", [name], migration: false
        invoke "active_record:model", ["#{name}Owners"], migration: false
        # invoke "active_record:model", ["Remexify::Logs", "md5:string"], {migration: true, timestamps: true}
      end

      def make_initializer
        template "initialize_remexify.rb", "config/initializers/00_remexify.rb"
      end
    end
  end
end