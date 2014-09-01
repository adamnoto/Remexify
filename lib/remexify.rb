require "remexify/version"
require "active_support/configurable"

module Remexify
  include ActiveSupport::Configurable

  INFO = 100
  WARNING = 200
  ERROR = 300
  FATAL = 600

  # todo: add variants functionality, which will strip error msg that contain class information
  # such as undefined local variable or method `user' for #<#<Class:0x007f9492c00430>:0x007f948d13a7a8>
  # undefined local variable or method `user' for #<#<Class:0x007f9492c00430>:0x007f9434ccab> and add
  # the later to the variant.

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