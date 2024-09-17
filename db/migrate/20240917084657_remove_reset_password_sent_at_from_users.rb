class RemoveResetPasswordSentAtFromUsers < ActiveRecord::Migration[7.0]
  def up
    remove_column :users, :reset_password_sent_at
  end

  def down
    add_column :users, :reset_password_sent_at, :datetime
  end
end
