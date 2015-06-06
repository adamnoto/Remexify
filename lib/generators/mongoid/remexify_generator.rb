require "rails/generators/named_base"

module Mongoid
  module Generators
    class RemexifyGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      def generate_log_model
        Rails::Generators.invoke "mongoid:model", [name]
      end

      def generate_logowner_model
        Rails::Generators.invoke "mongoid:model", ["#{name}Owners"]
      end

      def inject_log_model
        log_data = <<RUBY
  include Mongoid::Timestamps::Short

  # 0; the more high the level, the more important
  field :level,       type: Integer, default: 0

  # let your log be unique
  field :md5,         type: String

  field :message,     type: String
  field :backtrace,   type: String
  field :file_name,   type: String

  field :class_name,  type: String
  field :method_name, type: String
  field :line,        type: String

  # additional parameters that want to be logged as well
  field :parameters,  type: String

  # additional description that want to be logged as well
  field :description, type: String

  # how many times the system logging this error?
  field :frequency,   type: Integer, default: 1

  validates_presence_of :level, :md5, :message, :class_name, :frequency
  index({ md5: 1 }, {unique: true})
RUBY

        inject_into_file File.join("app", "models", "#{file_path}.rb"), log_data, after: "include Mongoid::Document\n"
      end

      def inject_logowner_model
        log_data = <<RUBY
  include Mongoid::Timestamps::Short

  field :log_md5,       type: String
  field :identifier_id, type: String

  field :param1,        type: String
  field :param2,        type: String
  field :param3,        type: String

  validates_presence_of :log_md5, :identifier_id

  index({ md5: 1, identifier_id: 1 }, { unique: true })
RUBY
        inject_into_file File.join("app", "models", "#{file_path}_owners.rb"), log_data, after: "include Mongoid::Document\n"
      end

      def make_initializer
        template "initialize_remexify.rb", "config/initializers/00_remexify.rb"
      end

    end
  end
end