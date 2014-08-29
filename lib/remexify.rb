require "remexify/version"
require "active_support/configurable"
require "remexify/standard_error"
require "remexify/runtime_error"

module Remexify
  include ActiveSupport::Configurable

  INFO = 100
  WARNING = 200
  ERROR = 300

  class << self
    def setup
      config.model = nil
      yield config
    end

    # options = class, method, line, file, params/param/parameters, desc/description
    def write(level, obj, options = {})
      if (obj.is_a?(StandardError) || obj.is_a?(RuntimeError)) && obj.already_logged
        return
      end

      message = "message is nil"
      backtrace = "backtrace is nil"

      if obj.class <= Exception
        message = obj.message
        backtrace = obj.backtrace.join("\n")
      elsif obj.class <= String
        message = obj
        backtrace = nil
      end

      # standardize into options[:parameters]
      options[:parameters] = options[:param] if options[:param]
      options[:parameters] = options[:params] if options[:params]
      options[:parameters] = options[:parameter] if options[:parameter]
      options[:parameters] ||= ""

      # standardize into options[:description]
      options[:description] = options[:desc] if options[:desc]
      options[:description] ||= ""

      # class name cannot be blank
      class_name = options[:class]
      class_name = Time.now.strftime("%Y%m%d") if class_name.blank?

      # generate hash
      hashed = "#{message}#{class_name}"
      md5 = Digest::MD5.hexdigest hashed

      # assure md5 is not yet exist, if exist, don't save
      raise ActiveRecord::Rollback if System::Loggers.where(md5: md5).first

      config.model.create({
         md5: md5,
         level: level,
         message: message,
         backtrace: backtrace,
         class_name: class_name,
         method_name: options[:method],
         line: options[:line],
         file_name: options[:file],
         parameters: options[:parameters].inspect,
         description: options[:description]
      })

      # mark already logged if DisplayableError
      if obj.is_a?(StandardError) || obj.is_a?(DisplayableError)
        obj.already_logged = true
      end

      nil # don't return anything for logging!
    end

    def info(obj, options = {})
      write INFO, obj, options
    end

    def warning(obj, options = {})
      write WARNING, obj, options
    end

    def error(obj, options = {})
      write ERROR, obj, options
    end
  end

end
