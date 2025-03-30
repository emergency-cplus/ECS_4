class AddSharedWithGeneralToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :shared_with_general, :boolean, default: false, null: false
    add_index :items, :shared_with_general
  end
end
