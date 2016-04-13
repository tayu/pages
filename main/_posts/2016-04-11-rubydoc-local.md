---
layout: post
title:  "Ruby リファレンスマニュアルをローカルで参照する"
categories: ruby rubydoc
---
* TOC
{:toc}

# Ruby のドキュメントを手元で参照する

手元にドキュメントを置いておくと何かと便利。
Ruby のドキュメントをローカルで参照できるように
したのでめもめも。

実施したのはちょっと前なので今は古いかもしれない

# 概要
Ruby のドキュメントは[ここ](http://docs.ruby-lang.org/ja/)にある。
が、html でまとめてダウンロードできる様なリンクは見当たらない。

このページの一番下にある[るりまプロジェクト](https://github.com/rurema)を
見ていたら、html を作成する工程があった。
そこから逆算する様に手順を調べ、やってみた。


# 手順。

## 概要

大体の手順は以下の様になる

0. るりまの github リポジトリからソースを取得する。
0. DB を作る
0. DB から 静的 html を生成する

元にした手順は[Tutorial](https://github.com/rurema/doctree/wiki/Tutorial)と
[BitClust](https://github.com/rurema/doctree/wiki/BitClust)のページ


## コマンドの準備

`bitclust` を使える様にする。bitclust はパッケージになっていないので
Ruby の gem としてインストールする。

※ root 権限が不要な、ユーザのホーム配下にインストールする方法もある様だが、
ここでは標準的な方法

```console
$ su -c 'gem install bitclust-core'
```

/usr/local/bin/bitclust がインストールされた。


## ソース取得
github から clone する。適当なディレクトリで以下を実行する。

```console
$ git clone git://github.com/rurema/doctree.git
```

## DB を作る（続けて更新する）

作業ディレクトリで `bitclust` を実行する

```console
$ cd doctree/refm/api
$ bitclust -d ./db-2.0.0 init version=2.0.0 encoding=UTF-8
$ bitclust -d ./db-2.0.0 update --stdlibtree=src
```


## 静的 html を生成する

```console
$ mkdir -p ../../../html/function
$ bitclust -d ./db-2.0.0 statichtml -o ../../../html
```
リポジトリと別のディレクトリ（`html`）に出力する。

最初、エラーが出て終了したが、html/function/ ディレクトリを
作ったらうまく行った




## 後始末
db やリポジトリは不要なので消してしまう。

翻訳作業とかするなら、別途 clone する方が
余計なファイル（db）が無くて安全。






