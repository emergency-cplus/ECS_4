class AddLoginCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :login_count, :integer, default: 0
  end
end
