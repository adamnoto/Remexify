module Remexify
  module Retrieve
    class << self
      def all(options = {})
        if options[:order]
          return config.model.order(options[:order]).all.to_a
        end
        return config.model.all.to_a
      end

      def all_today(options = {})
        ar_statement = config.model.where(created_at: Time.now.beginning_of_day)
        if options[:order]
          return ar_statement.order(options[:order]).all.to_a
        end
        return ar_statement.all.to_a
      end
    end
  end

  class << self
    def delete_all_logs
      config.model.delete_all
    end
  end
end