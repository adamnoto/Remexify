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
      # initialisation
      config.model = nil
      config.model_owner = nil

      config.censor_strings = []

      # do not log exception of which class is listed.
      config.discarded_exceptions = []

      # log only exceptions of which class is listed inside.
      config.accepted_exceptions = []

      yield config

      # warning if accepted_exceptions is defined but String is not included
      if config.accepted_exceptions.any? && !config.accepted_exceptions.include?(String)
        puts "REMEXIFY: You won't be able to log a String, because it is left out while you defined the `accepted_exceptions'"
      end

    end
  end

end

require "remexify/standard_error"
require "remexify/runtime_error"
require "remexify/displayable_error"
require "remexify/remexify_retriever"
require "remexify/remexify_writer"