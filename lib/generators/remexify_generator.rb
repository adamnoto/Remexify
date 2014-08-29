require "rails/generators/named_base"

module Remexify
  module Generators
    class RemexifyGenerator < Rails::Generators::Base

      namespace "remexify"
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a model and database migration for remexify to log error/informations"

      def copy_migration
        migration_template "remexify_log.rb", "db/migration/remexify_log.rb"
      end

      def generate_model
        invoke "active_record:model", ["Remexify::Log"], migration: false unless model_exists? && behavior == :invoke
      end
    end
  end
end