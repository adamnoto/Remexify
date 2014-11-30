require "singleton"

module Remexify
  module Retrieve
    class << self
      def all(options = {})
        logs = options[:owned_by].blank? ? Remexify.config.model.all : Remexify::Retrieve::Filter.owned_by(options)
        logs = Remexify::Retrieve::Filter.order logs, options
        logs = Remexify::Retrieve::Filter.level logs, options

        logs.to_a
      end

      def today(options = {})
        logs = options[:owned_by].blank? ? Remexify.config.model.all : Remexify::Retrieve::Filter.owned_by(options)
        logs = logs.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day)
        logs = Remexify::Retrieve::Filter.order logs, options
        logs = Remexify::Retrieve::Filter.level logs, options

        logs.to_a
      end

      def where_fingerprint_is(fingerprint)
        Remexify.config.model.where(md5: fingerprint).first
      end
    end
  end

  module Remexify::Retrieve::Filter

    module_function

    def order(obj, options)
      if options[:order]
        obj = obj.order(options[:order])
      end
      obj
    end

    def level(obj, options)
      lvl_option = options[:level]
      if lvl_option
        lvl = lvl_option.gsub(/[^0-9]/, "")
        raise "Level must all be a number" if (lvl =~ /^[0-9]+$/).nil?

        if lvl_option =~ />=/
          obj = obj.where("level >= ?", lvl)
        elsif lvl_option =~ /<=/
          obj = obj.where("level <= ?", lvl)
        elsif lvl_option =~ />/
          obj = obj.where("level > ?", lvl)
        elsif lvl_option =~ /</
          obj = obj.where("level < ?", lvl)
        elsif lvl_option =~ /=/
          obj = obj.where("level = ?", lvl)
        else
          raise "Unknown operator for level"
        end
      end
      obj
    end

    def owned_by(options)
      my_logs = Remexify.config.model_owner.where(identifier_id: options.fetch(:owned_by)).pluck(:log_md5)
      owned_logs = Remexify.config.model.where(md5: my_logs).all
      owned_logs
    end
  end

  class << self
    def delete_all_logs
      Remexify.config.model.delete_all
    end
  end
end