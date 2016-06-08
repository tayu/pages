---
layout: post
title:  "Polipo の設定"
categories: proxy config
---
vm 上の Debian で proxy として使用していた
[Polipo](http://www.pps.jussieu.fr/~jch/software/polipo/) の設定を見直した。
いやぁ、ちょっとあせった。


* TOC
{:toc}

# ディスクがフルに
走らせていた、とあるアプリケーションが止まった。再起動してみるかな、と
思ったが、その前にちょっとだけ環境の確認、と df してみて驚いた。
ルートのディスク使用率が 100% になっていた。

いやぁ、ひさびさ。

リブートしなくて良かった。起動中にログの書き込み失敗で
エラー終了するものがそこそこあるってのは既にやった事がある。

とりあえず、一寸で良い、ディスクに空きを作らなければ。
/var/log 配下の .gz ファイルを全部消してみたりしたが、100% のまま。
多分、キャッシュ分なのだろう。キャッシュを全て書き出すには
空きが足りない、と。

# 犯人は・・・
直前に何かやってたかな、と考えてみた。
思い当たるのは、ちょっとまとまった量を wget で
ダウンロードさせていた事くらい。

ひょっとしたらキャッシュ？

確認のため、/var/cache/polipo/ で du してみる。バッチリ容量を
食ってた。


# とりあえず、空きをつくる
Polipo のパラメータの一覧から当たりをつける。

```sh
# polipo -v
```

`/etc/polipo/config` を編集して

```menuconfig
diskCacheTruncateSize = 0
diskCacheTruncateTime = 0
diskCacheUnlinkTime = 0
diskCacheWriteoutOnClose = 0
```
として、

```sh
# polipo -x
```

したところ、キャッシュが全て消え、無事、ディスクの空きができた。


# キャッシュさせないための設定
その後、少し調べた結果

- キャッシュさせないためには `maxDiskCacheEntrySize`
- キャッシュをクリアさせるには `diskCacheUnlinkTime`

を設定すれば良いことが分かった。

最終的に、以下を追記した。

```menuconfig
maxDiskCacheEntrySize = 0
diskCacheUnlinkTime = 0
```
キャッシュクリアは次の cron.daily 時。


# そもそもなぜ
確か、polipo パッケージの説明にキャッシュしないって有ったはず。

今、確認してみたら `caching web proxy` となっていた。
思い違いをしてたらしい。


# 環境について
VM が複数あり、そこからの http アクセスをキャッシュするのが目的。
全てをホスト側にある proxy にリレーさせている。
これで、キャッシュを重複して持たずに済む（つもりだった）。

VM に polipo をインストールするのは VM 内のアプリケーション
の設定を 127.0.0.1 に統一できて良いかな、と思ったから。
proxy のアドレスが変わった場合でも設定変更が 1 箇所で済む。

