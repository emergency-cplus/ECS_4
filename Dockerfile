#ベースイメージの指定
FROM ruby:3.2.2

#環境変数
ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8
ENV LC_ALL C.UTF-8
ENV EDITOR=vim

#dbにpostgreSQLを使用するので対象のパッケージをインストール
RUN apt-get update && apt-get install -y postgresql-client vim

#appディレクトリを作成
RUN mkdir /app
#コマンドを実行するディレクトリを/appに指定
WORKDIR /app

#ローカルのGemfileとGemfile.lockをコンテナ内にコピー
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

#bundle installを実行
RUN bundle install

#ローカルの現在のディレクトリをコンテナ内にコピー
COPY . /app

#後述のentrypoint.shを実行するための記述
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

#コンテナがリッスンするPORTを指定
EXPOSE 3000

#コンテナ作成時にサーバーを立てる
CMD ["rails", "server", "-b", "0.0.0.0"]
