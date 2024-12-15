class CorrectRoleAtTimeType < ActiveRecord::Migration[7.1]
  def up
    remove_column :send_lists, :role_at_time
    add_column :send_lists, :role_at_time, :integer
  end

  def down
    remove_column :send_lists, :role_at_time
    add_column :send_lists, :role_at_time, :string
  end
end
