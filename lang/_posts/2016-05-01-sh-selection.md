---
layout: post
title:  "分岐"
categories: sh
tags: selection
---
{% include path.liquid %}
* TOC
{:toc}

# if 文
形式は
`if list; then list; [ elif list; then list; ] ... [ else list; ] fi` 。

## 単純な形式

[selection.sh]({{ rootpath | prepend: site.baseurl | append: "script/sh/selection.sh" }})

```shell
#! /bin/sh
P=$(expr `date '+%S'` % 2)
if [ 0 = $P ]; then
    echo "hello ."
fi
```
条件が真なら、処理を実行する。

if ～ then 部分は 2 行に分けても良い。この辺のスタイルは好み。

```shell
if [ 0 = $P ]
then
    echo "hello ."
fi
```

## または

[selection2.sh]({{ rootpath | prepend: site.baseurl | append: "script/sh/selection2.sh" }})

```shell
#! /bin/sh
P=$(expr `date '+%S'` % 2)
if [ 0 = $P ]; then
    echo "hello ."
else
    echo "goodby ."
fi
```
else 節を持つ。必ずどちらかの処理を通る。


## 複数の場合
[selection3.sh]({{ rootpath | prepend: site.baseurl | append: "script/sh/selection3.sh" }})

```shell
#! /bin/sh
P=$(expr `date '+%S'` % 5)
if [ 0 = $P ]; then
    echo "hello ."
elif [ 1 = $P ]; then
    echo "goodby ."
elif [ 2 = $P ]; then
    echo "hi ."
else
    echo "ho ."
fi
```
複数の場合を持つ場合。ブロック if 文。
条件判定の対象が同じなら case 文にしても同じ。


# case 文

形式は
`case word in [ [(] pattern [ | pattern ] ... ) list ;; ] ... esac` 。

[selection10.sh]({{ rootpath | prepend: site.baseurl | append: "script/sh/selection10.sh" }})

```shell
#! /bin/sh
P="$(expr `date '+%S'` % 5)"
case $P in
    0 | 2 )
	echo "even ."
	;;
    1 | 3 )
	echo "odd ."
	;;
    * )
	echo "unknown ."
	;;
esac
```
実行部の終わりに、必ず `;;` が必要。

その他のケースは `*` と記述する。

pattern 部は文字列のマッチングなので、正規表現なども使える。
また、変数展開も機能する。つまり、`"$V"` などと書ける。

