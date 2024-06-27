class EnableUuidExtension < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' # PostgreSQLのpgcrypto拡張を有効に
  end
end
