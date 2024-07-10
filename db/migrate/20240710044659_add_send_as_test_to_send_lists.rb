class AddSendAsTestToSendLists < ActiveRecord::Migration[7.1]
  def change
    add_column :send_lists, :send_as_test, :boolean, default: false
  end
end
