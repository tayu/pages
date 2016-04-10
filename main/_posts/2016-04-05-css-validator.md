---
layout: post
title:  "CSS チェッカ"
categories: css validator tomcat java install w3c
---
* TOC
{:toc}


# CSS のチェッカが欲しい

html のチェックは用意できた。そうなると CSS もチェックしたくなる。

以前も使ったことのある、[W3C](https://jigsaw.w3.org/css-validator/) のを
インストールする事にした。

インスールは一度やったのだが、今回、色々変わっていて、ちょっとハマった。
以前は .war ファイルがダウンロードでき、それを Tomcat の管理下の
ディレクトリに置くだけで済んだと思ったのだが、今回 .war のリンクは
見当たらない。

結果、成功した手順はソースを取得して、ローカルで .war を生成する手順だった。

で、またしても
[インストールドキュメント](https://jigsaw.w3.org/css-validator/DOWNLOAD.html)
に振り回されるという。
前回は英語のページを見て進められたのだが、今回は日本語と英語ページに
それ程差が無く、周辺情報を調べるのにちょっと時間がかかった。


# 環境
必要なものは以下

- Java 環境
- Ant
- Tomcat

Ant 以外は前回の html5 Validator のインストールで入れてある。
Ant は ant パッケージになっているのでそれをインストールするだけ。

```console
# apt-get install ant
```


# インストール手順

0. GitHub からソースを取得する
0. ライブラリへのパスを修正する
0. .war を作成する
0. .war を Tomcat の所定ディレクトリにコピーする

と、なる。

## GitHub からソースを取得する
適当なディレクトリで

```console
$ git clone https://github.com/w3c/css-validator
```

## ライブラリへのパスを修正する
build.xml を編集し、servlet.lib の項を自環境の servlet.ライブラリを
指すようにする。Tomcat8 のものを指定する。

```xml
<property name="servlet.lib" value="/usr/share/tomcat8/lib/servlet-api.jar"/>
```

## .war を作成する
```console
$ ant war
```
ワーニングがでつつもcss-validator.war が作成される


## .war を Tomcat の所定ディレクトリにコピーする

```console
# cp css-validator.war  /var/lib/tomcat8/webapps/
```
Tomcat が自動で展開し、`css-validator/` ディレクトリが作成される。


## アクセスする

`http://localhost:8080/css-validator/` にアクセスする


# ドキュメントについて
分かりにくいのは以下の 2 点

- build.xml って何？どこにあるの？
- `ソース`を `GitHub` から取得する

ちょっと調べて、build.xml は Java 環境の makefile だって事が分かる。
ただ、どうやって作ったら良いのかが分からない。
で、これってソース一式で取得するんじゃないか、に思い至るまで、
時間がかかった。まぁ、そこからは速かったのだが。

`ソース` って一言書いておいて欲しかった。

実は、良く読むと CVS で取得ってなってはいた。だけど、ソースの取得まで
必要って事がなかなか飲みころなかった。

とは言え、リンク先が GitHub なのだから git で clone すれば良いとは
思いつくし、実際それでできる。この辺りも記述しておいて欲しい所だ。
こっちの方が簡単だし、git の流儀だと思う。




