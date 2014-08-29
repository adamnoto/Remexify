require "rails/generators"
require "rails/generators/migration"

module Remexify
  module Generators
    class RemexifyGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a model and database migration for remexify to log error/informations"

      namespace "remexify"

      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def copy_migration
        migration_template "create_remexify_lognotes.rb", "db/migrate/create_remexify_lognotes.rb"
      end

      def generate_model
        invoke "active_record:model", ["Remexify::Lognotes"], migration: false
        # invoke "active_record:model", ["Remexify::Logs", "md5:string"], {migration: true, timestamps: true}
      end
    end
  end
end