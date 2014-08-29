require "remexify/version"
require "active_support/configurable"

module Remexify
  include ActiveSupport::Configurable

  class << self
    def setup
      config.model = nil
      yield config
    end
  end

end
