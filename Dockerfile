# 使いたいバージョンを決めて{{}}をruby:tag名の形で置き換えてください
# 例: ARG RUBY_VERSION=ruby:3.2.2
ARG RUBY_VERSION=ruby:3.2.2
# {{}}を丸ごと使いたいnodeのversionに置き換えてください、小数点以下はいれないでください
# 例: ARG NODE_VERSION=19
ARG NODE_VERSION=18

FROM $RUBY_VERSION
ARG RUBY_VERSION
ARG NODE_VERSION
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# Railsアプリケーションの環境変数の設定
ENV RAILS_ENV=production
ENV RACK_ENV=production
ENV NODE_ENV=production


# Node.jsとYarnのセットアップ
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y build-essential nodejs yarn libvips

# PostgreSQLクライアントのインストール
RUN apt-get install -y postgresql-client

RUN mkdir /app
WORKDIR /app

# Bundlerのインストール
RUN gem install bundler

# アプリケーションの依存関係をインストール
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Yarnの依存関係をインストール
COPY yarn.lock /app/yarn.lock
RUN yarn install

# アプリケーションコードをコピー
COPY . /app

# エントリーポイントスクリプトの設定
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# アセットのプリコンパイル
RUN bundle exec rails assets:precompile

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD [ "rails" , "server" , "-b" , "0.0.0.0" ]
