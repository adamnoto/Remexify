module Remexify
  class << self
    # options = class, method, line, file, params/param/parameters, desc/description
    def write(level, obj, options = {})
      puts "I AM HERE 1"
      if (obj.is_a?(StandardError) || obj.is_a?(RuntimeError)) && obj.already_logged
        return
      end
      puts "I AM HERE 2"

      message = "message is nil"
      backtrace = "backtrace is nil"

      if obj.class <= Exception
        message = obj.message
        # censor some text
        backtrace = obj.backtrace.clone
        # fool proof
        if Remexify.config.censor_strings.is_a?(Array)
          Remexify.config.censor_strings.each do |str|
            backtrace.reject! { |b| !((b =~ /#{str}/i).nil?) }
          end
        end
        backtrace = backtrace.join("\n")
      elsif obj.class <= String
        message = obj
        backtrace = ""
      end

      puts "I AM HERE 3"

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

      puts "I AM HERE 4"

      # assure md5 is not yet exist, if exist, don't save
      log = config.model.where(md5: md5).first
      if log
        puts "I AM HERE 5A"
        log.frequency += 1
        log.save
      else
        puts "I AM HERE 5B"
        method = options[:method] || "null"
        line = options[:line] || "null"
        file = options[:file] || "null"
        parameters = (options[:parameters].blank? ? "null" : options[:parameters].inspect)
        descriptions = options[:description] || "null"

        config.model.connection.execute <<-SQL
          INSERT INTO #{config.model.table_name}
                                       (md5, level, message, backtrace,
                                       class_name, method_name, line, file_name,
                                       parameters, description, created_at, updated_at)
          VALUES ("#{md5}", #{Integer level}, "#{message}", "#{backtrace || ""}", "#{class_name}",
                  #{method}, #{line}, #{file}, "#{parameters}", #{descriptions},
                  "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}",
                  "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}");
          COMMIT;
        SQL
      end

      # mark already logged if DisplayableError
      if obj.is_a?(StandardError) || obj.is_a?(DisplayableError)
        obj.already_logged = true
      end

      puts "I AM HERE 6"

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

    def fatal(obj, options = {})
      write FATAL, obj, options
    end
  end

end