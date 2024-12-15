class FixRoleValuesAndDefaults < ActiveRecord::Migration[7.0]
  def up
    # admin_userのroleを0に設定
    execute <<-SQL
      UPDATE users SET role = 0 WHERE name = 'admin_user';
    SQL

    # guで始まるユーザーのroleを1(general)に設定
    execute <<-SQL
      UPDATE users SET role = 1 WHERE name LIKE 'gu%';
    SQL

    # duで始まるユーザーのroleを2(demo)に設定
    execute <<-SQL
      UPDATE users SET role = 2 WHERE name LIKE 'du%';
    SQL

    # SendListsの更新
    execute <<-SQL
      UPDATE send_lists 
      SET role_at_time = (
        SELECT users.role 
        FROM users 
        WHERE users.id = send_lists.user_id
      )
      WHERE user_id IS NOT NULL;
    SQL

    # デフォルト値を 2 (demo) に設定
    change_column_default :users, :role, 2
    change_column_default :send_lists, :role_at_time, 2
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "このマイグレーションは取り消せません。手動でのデータ修正が必要です。"
  end
end
