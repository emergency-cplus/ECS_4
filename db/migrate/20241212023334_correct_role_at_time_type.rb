class CorrectRoleAtTimeType < ActiveRecord::Migration[7.1]
  def change
    remove_column :send_lists, :role_at_time
    add_column :send_lists, :role_at_time, :integer
  end
end
