---
layout: post
title:  "HTML5 文法チェッカ"
categories: html5 validator tomcat java install
---
* TOC
{:toc}


# HTML5 の lint が欲しい

ローカルで動く html の lint って事で、もう、長いこと
[Another HTML-lint](http://openlab.jp/k16/htmllint/htmllint.html)
を使ってきたのだけど、これは HTML5 に対応していない。

検索してみると、これを HTML5 に対応させたサービスは存在したのだけど、
ダウンロードのリンクは見当たらない。でも、ローカルで動かしたかった。

で、色々調べてみて、[W3C](https://validator.w3.org/) でも使われている
[Nu Html Checker](https://validator.w3.org/nu/)を見つけた。
ここの `get the latest release` から .jar ファイルを取得できる。
また、インストール関係の説明もここから辿れる。

で、[Debian](http://www.debian.org/) にインストールしてみた。
少し作業が必要になったので、めも。

ゴールは Tomcat で動かすこと。

Nu Html Checker は .jar と .war の 2 種類の方法で提供されている。
.jar は java コマンドで動かす。.war ファイルは Tomcat 等でサーブレット
として動かす。毎回手動で動かすのは面倒なのでパス。
スクリプトを書いて、起動時に動かしても良いが、
今回は Tomcat でやる事にした。


# 必要なもの
- Tomcat
- Java

Tomcat はパッケージになっている。でも Java は java8 が必要だけど、
パッケージには無い。
なので Oracle からダウンロードしてインストールする。
この辺りの手順は[ここ](http://astah.change-vision.com/ja/feature/install-linux-debian.html)を参考にした。

# Tomcat のインストール
パッケージを入れる

```console
# apt-get install tomcat8
```

確認の為に `http://localhost:8080/` にアクセスする。
`It works !` の表示が出たら OK 。

Tomcat を先にインストールするのは、

- 依存関係で JDK が Oracle のとは別にインストールされ、設定が上書きされる
- Tomcat 単体で動作確認できる

辺りが理由


# Java のインストール

## 入手
[OracelのJavaダウンロードページ](http://www.oracle.com/technetwork/java/javase/downloads/index.html) から環境に合わせてダウンロードする。
今回は Linux 用 64 bit で、.tar.gz な物を選択した。

## 展開
適当なディレクトリで

```console
$ tar xvf jdk-8u77-linux-x64.tar.gz
```

する。`jdk1.8.0_77/` ディレクトリが作成され、その中に展開される。

## 移動
ディレクトリ一式を `/usr/lib/jvm` 配下へ移動する。

```console
# mv jdk1.8.0_77 /usr/lib/jvm
```

また、他（OpenJDK など）と同様にオーナーを root にしておく。

```console
# chown -R root:root jdk1.8.0_77
```

## リンクを張る
`/usr/lib/jvm` 中の `default-java` が `jdk1.8.0_77` を指すようにする。

```console
# rm default-java
# ln -sf jdk1.8.0_77 default-java
```

Tomcat の起動スクリプト(`/etc/init.d/tomcat8`) を見てみると
`/usr/lib/jvm` 中で Oracel等の JDK がインストールされているか、
探している。その中のパスの 1 つが `default-java` で、
これを Oracel の JDK に向けてやる事で取りあえず動くように
なった。

つまり、正式な手段でもないし将来に渡って大丈夫とも言えない。


## デフォルトの java 関連コマンドのすり替え
Debian の機構を使って java コマンドなどを Oracel の JDK に向けてやる。

```console
# update-alternatives --install /usr/bin/java java /usr/lib/jvm/default-java/bin/java 1
# update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/default-java/bin/javac 1
# update-alternatives --install /usr/bin/javaws javaws /usr/lib/jvm/default-java/bin/javaws 1
# update-alternatives --config java
# update-alternatives --config javac
# update-alternatives --config javaws
```
選択を求められたら Java8 を選択する。


## Tomcat の再起動
java 関連のパスが変わったので、再起動して反映させる。

```console
# /etc/init.d/tomcat8 restart
```


# Nu Html Checker のインストール
取得した .war ファイルを `/var/lib/tomcat8/webapps` にコピーする。

```console
# cp vnu.war /var/lib/tomcat8/webapps
```

Tomcat が自動的に展開し、`vnu` ディレクトリが作られる。

`http://localhost:8080/vnu/` にアクセスして、Nu Html Checker の
画面が表示されたら成功。


# おまけ

## Nu Html Checker の再起動
Tomcat は設定ファイルの更新を監視しているので、web.xml を編集して
保存するとサーブレットの再読み込みが行われる。簡単にやるなら、
単にファイルの時刻を更新するだけで良い。

```console
# touch /var/lib/tomcat8/webapps/vnu/WEB-INF/web.xml
```

## .jar 版を動かす
ドキュメントにある通り

```console
$ java -cp ./vnu.jar nu.validator.servlet.Main 8888
```
とする。`http://localhost:8888` にアクセスすると画面が表示される。

