# テスト環境構築

## OAuth Apps 登録

GitHub にアクセスし、ユーザホームから [Settings] - [Developer settings] - [OAuth Apps] - [New OAuth App] に進み、 `Register a new OAuth application` ページにアクセスし、以下の設定を行います。

設定項目

* Application name: 適当な値
* Homepage URL: http://localhost:3000/
* Authorization callback URL: http://localhost:3000/auth/github/callback

設定が終われば、`Register application` をクリックします。

## 環境設定

`./apikey.env.sample`をコピーし、`./apikey.env`ファイルを作成します。

GitHub にアクセスし、ユーザホームから [Settings] - [Developer settings] - [GitHub Apps] に進み、先ほど登録したアプリケーションを選択します。
ページ下部の、`Auth credentials` の `Client ID` と `Client secret` の値を`apikey.env`ファイルの `GITHUB_KEY` と `GITHUB_SECRET` にそれぞれ設定します。

## アプリケーション起動

以下のコマンドを実行します。

```sh
cd /application/path
docker-compose build
docker-compose up -d
docker-compose exec app rake db:create
docker-compose exec app rake db:migrate
```

`http://localhost:3000` にアクセスすれば、アプリケーションが起動します。

## コンソールを表示する

デーモンで起動した場合や、コンソールを閉じた場合に、Railsの出力結果を取得するには、次のようにします。

```sh
docker-compose up -d
docker-compose ps
# 起動しているコンテナが表示されるので Name を確認します。
docker attach <container_name>
```

## 問題インポート

`./lib/tasks/config/env.yml.sample`をコピーし、`./lib/tasks/config/env.yml`を作成します。

Rake タスク`exam:deploy`の中で SSH の git clone を使用しているので各種設定が必要です。
次のコマンドを実行して、`exam-master`を clone できることが前提です。

```sh
git clone git@github.com:libertyfish-co/exam-master.git
```

問題をDBにインポートするために、以下のコマンドを実行します。

```sh
bundle install --path vendor/bundle
bundle exec rake exam:deploy
```
