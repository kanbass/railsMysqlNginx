FROM ruby:2.7.2

# リポジトリを更新し依存モジュールをインストール
RUN apt-get update -qq && \
    apt-get install -y build-essential \
                       libpq-dev \
                       nodejs \
                       sudo \
    && rm -rf /var/lib/apt/lists/* 
    
#bootstrapのJsを使うためにはWebpackerをインストールする必要がある。
#本当は「&&」でつなげたほうがいいと思う、、、キャッシュが軽くなるから。
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt update && sudo apt install yarn

# ルート直下にwebappという名前で作業ディレクトリを作成（コンテナ内のアプリケーションディレクトリ）
RUN mkdir /webapp
ENV APP_ROOT /webapp
WORKDIR $APP_ROOT

# ホストのGemfileとGemfile.lockをコンテナにコピー
#そのためもし0からRailsを作成する際には事前に以下のファイルを作成しておこう
#Gemfileは以下の通り、Gemfile.lockは空ファイル
#source 'https://rubygems.org'
#gem 'rails', '6.0.3.4'
ADD ./src/Gemfile $APP_ROOT/Gemfile
ADD ./src/Gemfile.lock $APP_ROOT/Gemfile.lock

# bundle installの実行
RUN bundle install

# ホストのアプリケーションディレクトリ内をすべてコンテナにコピー
ADD ./src/ $APP_ROOT

# puma.sockを配置するディレクトリを作成
RUN mkdir -p tmp/sockets
