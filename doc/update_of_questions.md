# Update of questions

本番環境で公開している ruby-license に登録された問題情報は、 [exam-master](https://github.com/libertyfish-co/exam-master) レポジトリによって管理されています。
問題を追加する場合や、問題に不具合がある場合は、 `exam-master` を修正してから、問題情報の更新を行います。

## 前提条件

* 既にサーバーの設定が完了していること
* GitHub に `exam-master` レポジトリをクローン可能なように設定されていること

## 問題更新

[infomation](infomation.md) を参考に ruby-license サーバーに SSH ログインします。

```
cd /var/www/rails/rex/current
RAILS_ENV=production rails exam:deploy
```
