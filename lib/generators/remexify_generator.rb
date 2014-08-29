require "rails/generators/named_base"

module Remexify
  module Generators
    class RmexifyGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      namespace "remexify"
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a model and database migration for remexify to log error/informations"
    end
  end
end