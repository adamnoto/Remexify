module Remexify
  module Retrieve
    class << self
      def all(options = {})
        if options[:order]
          return Remexify.config.model.order(options[:order]).all.to_a
        end
        return Remexify.config.model.all.to_a
      end

      def today(options = {})
        ar_statement = Remexify.config.model.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day)
        if options[:order]
          return ar_statement.order(options[:order]).all.to_a
        end
        return ar_statement.all.to_a
      end

      def where_fingerprint_is(fingerprint)
        Remexify.config.model.where(md5: fingerprint).first
      end
    end
  end

  class << self
    def delete_all_logs
      Remexify.config.model.delete_all
    end
  end
end