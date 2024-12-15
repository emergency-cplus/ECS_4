class ChangeRoleTypeToString < ActiveRecord::Migration[7.0]
  def up
    # Usersテーブルの変更
    add_column :users, :role_string, :string
    
    # 既存データの移行（NULLの場合はデフォルト値を設定）
    execute <<-SQL
      UPDATE users 
      SET role_string = CASE 
        WHEN role IS NULL THEN 'general'
        ELSE role::text 
      END
    SQL
    
    remove_column :users, :role
    rename_column :users, :role_string, :role

    # SendListsテーブルの変更
    add_column :send_lists, :role_at_time_string, :string
    
    # 既存データの移行（NULLの場合はデフォルト値を設定）
    execute <<-SQL
      UPDATE send_lists 
      SET role_at_time_string = CASE 
        WHEN role_at_time IS NULL THEN 'general'
        ELSE role_at_time::text 
      END
    SQL
    
    remove_column :send_lists, :role_at_time
    rename_column :send_lists, :role_at_time_string, :role_at_time

    # NULL値を持つレコードにデフォルト値を設定
    execute "UPDATE users SET role = 'general' WHERE role IS NULL"
    execute "UPDATE send_lists SET role_at_time = 'general' WHERE role_at_time IS NULL"

    # NOT NULL制約の追加
    change_column_null :users, :role, false
    change_column_null :send_lists, :role_at_time, false
  end

  def down
    # Usersテーブルの巻き戻し
    add_column :users, :role_int, :integer
    
    execute <<-SQL
      UPDATE users 
      SET role_int = CASE role
        WHEN 'admin' THEN 1
        WHEN 'general' THEN 0
        ELSE 0
      END
    SQL
    
    remove_column :users, :role
    rename_column :users, :role_int, :role
    
    # SendListsテーブルの巻き戻し
    add_column :send_lists, :role_at_time_int, :integer
    
    execute <<-SQL
      UPDATE send_lists 
      SET role_at_time_int = CASE role_at_time
        WHEN 'admin' THEN 1
        WHEN 'general' THEN 0
        ELSE 0
      END
    SQL
    
    remove_column :send_lists, :role_at_time
    rename_column :send_lists, :role_at_time_int, :role_at_time

    # デフォルト値とNOT NULL制約の設定
    change_column_default :users, :role, 0
    change_column_default :send_lists, :role_at_time, 0
    change_column_null :users, :role, false
    change_column_null :send_lists, :role_at_time, false
  end
end
