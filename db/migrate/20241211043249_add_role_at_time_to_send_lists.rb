class AddRoleAtTimeToSendLists < ActiveRecord::Migration[7.1]
  def change
    add_column :send_lists, :role_at_time, :integer
  end
end
