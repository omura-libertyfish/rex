# Update of system

## デプロイ

デプロイが正常に行えるか確認する

```
cap production deploy:check
```

デプロイする

```
cap production deploy
```

デプロイ後に Puma 再起動する

```
cap production deploy:restart
```

## 動作確認

https://rex.libertyfish.co.jp にアクセスし、次のポイントを確認する。

* GitHub account でログインできる。
* Gold チャレンジから問題に回答できる。
* 過去の試験一覧から「もう一度やる」を押下して、回答ページに遷移できる。
* 過去の試験一覧から「続きからやる」を押下して、回答ページに遷移できる。
* 過去の試験一覧の2ページ目などに遷移できる。
* 学習マラソンを始めることができる。
