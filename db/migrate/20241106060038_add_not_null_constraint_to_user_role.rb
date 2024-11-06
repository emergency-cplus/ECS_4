class AddNotNullConstraintToUserRole < ActiveRecord::Migration[7.1]
  def up
    # 既存のNULLのroleを:general (1)に設定
    execute "UPDATE users SET role = 1 WHERE role IS NULL"
    
    # NOT NULL制約を追加
    change_column_null :users, :role, false, 1
  end

  def down
    # NOT NULL制約を削除 (ロールバック時にNOT NULL制約を削除)
    change_column_null :users, :role, true
  end
end
