require "rails/generators"
require "rails/generators/named_base"

module Remexify
  module Generators
    class RemexifyGenerator < Rails::Generators::NamedBase
      namespace "remexify"
      desc "Generates a model with the given NAME for remexify to log error/informations"

      hook_for :orm
    end
  end
end