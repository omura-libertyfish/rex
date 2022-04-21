# Update of Ruby and Gems

Ruby のバージョンをあげる場合は、必ずGemsetの更新も必要になります。
Gemの中には、最新バージョンのRubyが利用できない可能性もあるので、動作確認は必須です。

## 開発時に修正する箇所

### Update Ruby

ruby-license の現在の ruby バージョンは `2.4.10` です。
`2.4.10` でディレクトリを `grep` して変更が必要なファイルを一覧化します。
現時点では、以下がヒットします。

* `.ruby-version`
* `Dockerfile`
* `config/deploy.rb`

それぞれをアップデート対象の ruby バージョンに更新します。

ruby バージョンを更新したら、以下の観点でテストして、動作が問題ないことを確認します(本来はテストを実装したい)。

* GitHub account でログインできる。
* Gold チャレンジから問題に回答できる。
* 過去の試験一覧から「もう一度やる」を押下して、回答ページに遷移できる。
* 過去の試験一覧から「続きからやる」を押下して、回答ページに遷移できる。
* 過去の試験一覧の2ページ目などに遷移できる。
* 学習マラソンを始めることができる。

## デプロイ時に行う設定

### Update Ruby

今回は `2.7.1` を利用する場合の例をあげます。

```sh
rvm install 2.7.1
rvm use 2.7.1
```

Ruby を更新したら、 Update gems の手順も行います。

### Update Gems

使用するRubyバージョンに最初に利用するように改めて設定します。

```sh
rvm use 2.7.1
```

Gemsetを設定します。

```sh
rvm gemset create rex-gemset
rmv gemset use rex-gemset
```

gemset の作成が終われば、[システムのデプロイ](update_of_system.md)を行います。
