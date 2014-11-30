class CreateRemexifyLogowners < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %>_owners do |t|
      t.string :log_md5, null: false
      t.string :identifier_id, null: false

      # this can be used to store additional info, such as the class of identifier_id above, or anything else
      # you may read the gem documentation on how to use it.
      t.string :param1
      t.string :param2
      t.string :param3
    end
    add_index :<%= table_name %>_owners, [:log_md5, :identifier_id], unique: true
  end

  def self.down
    # we don't want to make assumption of your roll back, please
    # by all mean edit it.
    # drop_table :<%= table_name %>_owner
    raise ActiveRecord::IrreversibleMigration
  end
end