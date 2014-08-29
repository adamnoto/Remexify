class RemexifyLog < ActiveRecord::Migration
  def self.up
    create_table :remexify_logs do |t|
      # let your log unique
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

      t.timestamps
    end
    add_index :remexify_logs, [:md5], unique: true
  end

  def self.down
    # we don't want to make assumption of your roll back, please
    # by all mean edit it.
    # drop_table :remexify_logs
    raise ActiveRecord::IrreversibleMigration
  end
end