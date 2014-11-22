$cached_error = []

module Remexify
  class << self
    # options = class, method, line, file, params/param/parameters, desc/description
    # extract_params_from, object, owned_by
    def write(level, message_object, options = {})
      if (message_object.is_a?(StandardError) || message_object.is_a?(RuntimeError)) && message_object.already_logged
        # do not log exception that has been logged
        return
      end

      if Remexify.config.discarded_exceptions.include? message_object.class
        # do not log exception that is explicitly discarded
        return
      end

      if Remexify.config.accepted_exceptions.any? && !Remexify.config.accepted_exceptions.include?(message_object.class)
        # do not log exception when accepted_exceptions has member and that, the class of the message_object
        # is not one of the member of the accepted exceptions
        return
      end

      message = "message is nil"
      backtrace = "backtrace is nil"

      if message_object.class <= Exception
        message = message_object.message
        # censor some text
        backtrace = message_object.backtrace.clone
        if Remexify.config.censor_strings.is_a?(Array)
          Remexify.config.censor_strings.each do |str|
            backtrace.reject! { |b| !((b =~ /#{str}/i).nil?) }
          end
        end
        backtrace = backtrace.join("\n")
      elsif message_object.class <= String
        message = message_object
        backtrace = ""
      end

      # standardize into options[:parameters]
      options[:parameters] = options[:param] if options[:param]
      options[:parameters] = options[:params] if options[:params]
      options[:parameters] = options[:parameter] if options[:parameter]
      options[:parameters] ||= ""

      # will override the options[:parameters] if this block execute successfully
      if options[:extract_params_from]
        ar_message_objectect = options[:extract_params_from]
        if ar_message_objectect.class < ActiveRecord::Base
          if ar_message_objectect.respond_to?(:attribute_names) && ar_message_objectect.respond_to?(:read_attribute)
            ar_attributes = ar_message_objectect.attribute_names
            attributes = {}
            ar_attributes.each do |attr|
              attributes[attr.to_s] = ar_message_objectect.read_attribute attr.to_sym
            end
            options[:parameters] = attributes
          end
        end
      end

      # if object is given
      if options[:object]
        # and is an active record
        if options[:object].class < ActiveRecord::Base
          # append to message
          message << "\n\nActiveRecord error messages:\n" << options[:object].errors.full_messages.join("\n")
        end
      end

      # standardize into options[:description]
      options[:description] = options[:desc] if options[:desc]
      options[:description] ||= ""

      # class name cannot be blank
      class_name = options[:class]
      class_name = Time.now.strftime("%Y%m%d") if class_name.blank?

      # generate hash
      # strip hex from class in order to increase accuracy of logged error, if any;
      # so: #<#<Class:0x007f9492c00430>:0x007f9434ccab> will just be #<#<Class>>
      message = message.gsub(/:0x[0-9a-fA-F]+/i, "")
      hashed = "#{message}#{class_name}"
      md5 = Digest::MD5.hexdigest hashed

      # assure md5 is not yet exist, if exist, don't save
      log = config.model.where(md5: md5).first
      if log
        log.frequency += 1
        log.save
      else
        md5 = config.model.connection.quote md5
        message = config.model.connection.quote message
        backtrace = backtrace.blank? ? "null" : config.model.connection.quote(backtrace)
        class_name = config.model.connection.quote(class_name)

        method = line = file = "null"
        if Kernel.respond_to? :caller_locations
          _caller = Kernel.caller_locations(2, 1)[0]
          method = options[:method].blank? ? _caller.base_label : options.fetch(:method)
          line = options[:line].blank? ? _caller.lineno : options.fetch(:lineno)
          file = options[:file].blank? ? _caller.absolute_path : options.fetch(:file)
        else
          method = options[:method] unless options[:method].blank?
          line = options[:line] unless options[:line].blank?
          file = options[:file] unless options[:file].blank?
        end
        method = config.model.connection.quote(method)
        line = config.model.connection.quote(line)
        file = config.model.connection.quote(file)

        parameters = options[:parameters].blank? ? "null" : config.model.connection.quote(options[:parameters].inspect)
        descriptions = options[:description].blank? ? "null" : config.model.connection.quote(options[:description])
        time_now = config.model.connection.quote(Time.now.strftime("%Y-%m-%d %H:%M:%S"))

        if config.model.connection.transaction_open?
          config.model.connection.rollback_transaction
        end
        config.model.connection.begin_transaction
        config.model.connection.execute <<-SQL
          INSERT INTO #{config.model.table_name} (
           md5, level, message, backtrace,
           class_name, method_name, line, file_name,
           parameters, description, created_at, updated_at)
          VALUES (#{md5}, #{Integer level}, #{message}, #{backtrace}, #{class_name},
           #{method}, #{line}, #{file}, #{parameters}, #{descriptions},
           #{time_now}, #{time_now});
        SQL
        config.model.connection.commit_transaction
      end

      # mark already logged if DisplayableError
      if message_object.is_a?(StandardError) || message_object.is_a?(DisplayableError)
        message_object.already_logged = true
      end

      # if owner_by is given, associate this log to the owned_by user
      unless options[:owned_by].blank?
        owned_by = config.model.connection.quote(options[:owned_by])
        config.model.connection.begin_transaction
        config.model.connection.execute <<-SQL
          INSERT INTO #{config.model_owner.table_name} (
           log_md5, identifier_id
          ) VALUES (#{md5}, #{owned_by})
        SQL
        config.model.connection.commit_transaction
      end

      nil # don't return anything for logging!
    end

    def info(message_object, options = {})
      write INFO, message_object, options
    end

    def warning(message_object, options = {})
      write WARNING, message_object, options
    end

    def error(message_object, options = {})
      write ERROR, message_object, options
    end

    def fatal(message_object, options = {})
      write FATAL, message_object, options
    end
  end

end