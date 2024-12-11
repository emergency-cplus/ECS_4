class UpdateExistingSendListsRoleAtTime < ActiveRecord::Migration[7.1]
  def up
    SendList.reset_column_information
    SendList.find_each do |send_list|
      send_list.update(role_at_time: send_list.user.role)
    end
  end

  def down; end
end
