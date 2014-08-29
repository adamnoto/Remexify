require "remexify/version"

module Remexify
  mattr_accessor :model

  INFO = 100
  WARNING = 200
  ERROR = 300

  # options = class, method, line, file, params/param/parameters, desc/description
  def self.write(level, obj, options = {})
    if (obj.is_a?(StandardError) || err.is_a?(RuntimeError)) && obj.already_logged
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

    model.create({
       level: level,
       message: message,
       backtrace: backtrace,
       class_name: options[:class],
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

  def self.info(obj, options = {})
    write INFO, obj, options
  end

  def self.warning(obj, options = {})
    write WARNING, obj, options
  end

  def self.error(obj, options = {})
    write ERROR, obj, options
  end
end
