class RemoveMessageTemplateFromUsers < ActiveRecord::Migration[7.1]
  def changeo
    remove_column :users, :message_template, :text
  end
end
