# 保守で利用する Linux command 一覧

## `cat`

ファイルの内容を出力するのに使用します。

```sh
cat /var/www/rails/rex/current/log/nginx.access.log
```

`cat` から新しいファイルを作成することも可能です。

```sh
cat <<EOF > target.txt
heredoc> this is test file.
heredoc> EOF
```

## `tail`

ファイルの最後から出力

`-`に数字を指定するとその行から出力します。

```sh
tail -200 /var/www/rails/rex/current/log/nginx.access.log
```

ログファイルを開いたままにして、自分でアクセスして状態を確認したいとき。

```sh
tail -f /var/www/rails/rex/current/log/nginx.access.log
```

## `less`

長いファイルをコンソール上で表示するときにウィンドウ枠ないでページングするために利用します。
終了するときは、`q`を押下します。検索は、`/`を押下して、検索ワードを入力します。

```sh
less /var/www/rails/rex/current/log/nginx.access.log
```

ログファイルを最後から見たいが、ページネーションを利用したいときはパイプ(`|`)を使います。

```sh
tail -200 /var/www/rails/rex/current/log/nginx.access.log | less
```

### `history`

実行したコマンド履歴を出力する。引数に数字を設定すると多くの履歴を確認できる。デフォルトは `10`

### `grep`

ファイルから検索する。パイプで文字列を渡せばその中を検索することも可能。

不具合があると言われた問題を探す。

```sh
grep -rn <検索ワード> .
```
