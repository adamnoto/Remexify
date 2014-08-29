require "remexify/version"
require "gem_config"

module Remexify
  include GemConfig::Base

  with_configuration do
    has :log_table_model, classes: Class
  end
end
