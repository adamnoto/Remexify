require "rails/generators/active_record"

module ActiveRecord
  module Generators
    class RemexifyGenerator < ActiveRecord::Generators::Base
      def copy_migration
        migration_template "remexify_log.rb", "db/migration/remexify_log.rb"
      end

      def generate_model
        invoke "active_record:model", [name], migration: false unless model_exists? && behavior == :invoke
      end
    end
  end
end

