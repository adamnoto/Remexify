require "singleton"

module Remexify
  module Retrieve
    class << self
      def all(options = {})
        logs = Remexify.config.model.all
        logs = Remexify::Retrieve::Filter.instance.order logs, options
        logs = Remexify::Retrieve::Filter.instance.level logs, options

        logs.to_a
      end

      def today(options = {})
        logs = Remexify.config.model.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day).all
        logs = Remexify::Retrieve::Filter.instance.order logs, options
        logs = Remexify::Retrieve::Filter.instance.level logs, options

        logs.to_a
      end

      def where_fingerprint_is(fingerprint)
        Remexify.config.model.where(md5: fingerprint).first
      end
    end
  end

  class Remexify::Retrieve::Filter
    include Singleton

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

        if lvl =~ />=/
          obj = obj.where("level >= ?", lvl)
        elsif lvl =~ /<=/
          obj = obj.where("level <= ?", lvl)
        elsif lvl =~ />/
          obj = obj.where("level > ?", lvl)
        elsif lvl =~ /</
          obj = obj.where("level < ?", lvl)
        elsif lvl =~ /=/
          obj = obj.where("level = ?", lvl)
        else
          raise "Unknown operator for level"
        end
      end
      obj
    end
  end

  class << self
    def delete_all_logs
      Remexify.config.model.delete_all
    end
  end
end