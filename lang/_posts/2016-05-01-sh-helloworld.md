---
layout: post
title:  "ハローワールド"
categories: sh
tags: helloworld
---
{% include path.md %}
# スクリプトを作成する

[helloworld.sh]({{ rootpath | prepend: site.baseurl | append: "script/helloworld.sh" }})という名前のファイルを、以下の内容で作成する。

```shell
#! /bin/sh
echo "Hello World"
```

# 実行属性をつける。

```console
$ chmod u+x helloworld.sh
$ ls -F helloworld.sh
helloworld.sh*
```
-F を指定した場合、実行属性が設定されていると、ファイル名の後ろに '*' が付く。

# 実行する

```console
$ ./helloworld.sh
Hello World
```
