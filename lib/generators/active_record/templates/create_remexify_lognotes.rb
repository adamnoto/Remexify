class CreateRemexifyLognotes < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
      # 0 the more high the level, the more important.
      t.integer :level, null: false, default: 0

      # let your log be unique
      t.string :md5, null: false

      t.text :message, null: false
      t.text :backtrace
      t.text :file_name

      t.string :class_name, null: false
      t.string :method_name
      t.string :line

      # additional parameters that want to be logged as well
      t.text :parameters

      # additional description that want to be logged as well
      t.text :description

      # how many times the system logging this error?
      t.integer :frequency, null: false, default: 1

      t.timestamps
    end
    add_index :<%= table_name %>, [:md5], unique: true
  end

  def self.down
    # we don't want to make assumption of your roll back, please
    # by all mean edit it.
    # drop_table :<%= table_name %>
    raise ActiveRecord::IrreversibleMigration
  end
end