class CreateSendLists < ActiveRecord::Migration[7.1]
  def change
    create_table :send_lists do |t|
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :phone_number
      t.datetime :send_at
      t.string :sender

      t.timestamps
    end
  end
end
