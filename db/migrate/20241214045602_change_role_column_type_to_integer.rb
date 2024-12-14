class ChangeRoleColumnTypeToInteger < ActiveRecord::Migration[7.1]
  def up
    # まずデフォルト値を削除
    change_column_default :users, :role, nil
    change_column_default :send_lists, :role_at_time, nil

    # NULL許容に変更
    change_column_null :users, :role, true
    change_column_null :send_lists, :role_at_time, true
    
    # 型を変更
    change_column :users, :role, 'integer USING CAST(role AS integer)'
    change_column :send_lists, :role_at_time, 'integer USING CAST(role_at_time AS integer)'
    
    # デフォルト値を設定し直す
    change_column_default :users, :role, 2
    change_column_default :send_lists, :role_at_time, 2
    
    # NOT NULL制約を再設定
    change_column_null :users, :role, false, 2
    change_column_null :send_lists, :role_at_time, false, 2
  end

  def down
    change_column_default :users, :role, nil
    change_column_default :send_lists, :role_at_time, nil

    change_column :users, :role, :string
    change_column :send_lists, :role_at_time, :string
    
    change_column_default :users, :role, '2'
    change_column_default :send_lists, :role_at_time, '2'
    
    change_column_null :users, :role, false
    change_column_null :send_lists, :role_at_time, false
  end
end
