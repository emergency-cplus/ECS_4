class AddUuidToUsers < ActiveRecord::Migration[7.1]
  def change
    # 新しいカラムを追加して、デフォルト値を設定
    add_column :users, :uuid, :string, default: -> { "gen_random_uuid()" }, null: false

    # 既存のユーザーにUUIDを設定
    User.find_each do |user|
      user.update(uuid: SecureRandom.uuid)
    end

    # UUIDにユニークインデックスを追加
    add_index :users, :uuid, unique: true
  end
end
