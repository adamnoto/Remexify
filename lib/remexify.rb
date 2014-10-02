require "remexify/version"
require "active_support/configurable"

module Remexify
  include ActiveSupport::Configurable

  INFO = 100
  WARNING = 200
  ERROR = 300
  FATAL = 600

  class << self
    def setup
      config.model = nil
      config.censor_strings = []
      yield config
    end
  end

end

require "remexify/standard_error"
require "remexify/runtime_error"
require "remexify/displayable_error"
require "remexify/remexify_retriever"
require "remexify/remexify_writer"