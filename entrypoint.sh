#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# データベースの接続確認を追加
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c '\q' 2>/dev/null; do
  echo "PostgreSQLの接続を待機中..."
  sleep 2
done

echo "PostgreSQL接続確認完了"

# データベースのマイグレーション実行
echo "データベースマイグレーションを実行"
bundle exec rails db:migrate 2>/dev/null || bundle exec rails db:create db:migrate

# アセットのプリコンパイル確認
if [ "$RAILS_ENV" = "production" ]; then
  echo "本番環境用のアセット確認"
  bundle exec rails assets:precompile
fi

echo "Railsサーバーを起動します"
# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
