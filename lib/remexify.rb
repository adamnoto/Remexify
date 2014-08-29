require "remexify/version"

module Remexify
  include GemConfig::Base

  with_configuration do
    has :log_table_model, classes: String
  end
end
