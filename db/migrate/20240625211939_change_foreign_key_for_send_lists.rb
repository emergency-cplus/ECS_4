class ChangeForeignKeyForSendLists < ActiveRecord::Migration[6.0]
  def change
    # 外部キー制約を削除
    remove_foreign_key :send_lists, :items

    # 外部キーを再設定（nullを許可）
    add_foreign_key :send_lists, :items, on_delete: :nullify
  end
end
