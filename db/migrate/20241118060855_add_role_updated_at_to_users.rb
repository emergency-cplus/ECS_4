class AddRoleUpdatedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role_updated_at, :datetime
  end
end
