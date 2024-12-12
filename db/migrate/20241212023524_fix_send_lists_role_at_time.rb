class FixSendListsRoleAtTime < ActiveRecord::Migration[7.1]
  def up
    # モデルの最新のスキーマ情報を読み込む
    SendList.reset_column_information

    # すべてのSendListレコードを少しずつ処理（メモリ効率のため）
    SendList.find_each do |send_list|
      user = send_list.user

      # 送信時点でのroleを判定するロジック
      role_at_time = if user.role_updated_at && send_list.send_at < user.role_updated_at
        # ユーザーのrole更新日が存在し、かつ 送信日時がrole更新日より前の場合

        if user.demo?
          # 現在demoユーザーの場合
          # → 元々はgeneralだったことがわかっているので、generalの値(1)を設定
          User.roles['general']  # => 1
        else
          # demo以外のユーザーの場合
          # → 現在のroleをそのまま使用
          User.roles[user.role]  # => admin: 0, general: 1
        end
      else
        # role更新日がない、または 送信日時がrole更新日以降の場合
        # → 現在のroleをそのまま使用
        User.roles[user.role]    # => admin: 0, general: 1, demo: 2
      end

      # バリデーションをスキップして直接カラムを更新
      send_list.update_column(:role_at_time, role_at_time)
    end
  end

  def down
  end
end
