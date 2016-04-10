---
layout: post
title:  "Jekyll の TIPS"
categories: jekyll tips
---
* TOC
{:toc}

# 目次を生成する
次の 2 行を .md 中に記述する

```
* TOC
{:toc}
```
http://www.seanbuscay.com/blog/jekyll-toc-markdown/

kramdown で有効らしい


# 相対パスを使用する

GitHub Pages では url は http://username.github.io/ の様に username は
サイト名となるため、ファイルは絶対パスで指定できる。

しかし、ローカルで参照する場合はそうも行かない。

以下、例として CSS の場合。

`_includes/head.html` にコードを仕込み、各ページ生成時に
上位ディレクトリを参照する様にする。


{% comment %} liquid が効かない。ので html {% endcomment %}
```html
{% raw %}{% assign urlpaths = page.url | split: '/' %}
{% assign csspath = "/" %}
{% assign limit = urlpaths.size | minus: 1 %}
{% for i in (1..limit) %}
  {% assign csspath = csspath | append: "../" %}
{% endfor %}
{% assign css = csspath | append: "css/main.css" %}
    <!-- Custom CSS -->
    <link rel="stylesheet" href="{{ css | prepend: site.baseurl }}">{% endraw %}
```

つまり、url のハスを分解してカウントし、その分上位に上る。
`minus: 1` 辺りは完全に現物合わせ。




# ページ内で使用する変数を先頭で宣言する

スクリプトとかで良くやる手。

ファイル先頭の [Front-matter](http://jekyllrb-ja.github.io/docs/frontmatter/)
で、任意の変数と値を設定できる。

```liquid
---
var1: value1
---
```

参照は以下の様になる

```liquid
{% raw %}{{ page.var1 }}{% endraw %}
```
html 生成時に `value1` と展開される



# 配列を使う
ファイル先頭の `Front-matter` で以下の様に書く

```liquid
---
array1: [ e1, e2, e2 ]
---
```

参照は

```liquid
{% raw %}{{ page.array1[1] }}{% endraw %}
```
の様になる。この時 `[ 1 ]` の様に括弧の前後にスペースを入れてはいけない。

もちろん `for ～ in` 構文でアクセスできる。
添え字でアクセスする場合は `for ～ in (1..3)` の構文が使える。


# ハッシュを使う
ファイル先頭の `Front-matter` で以下の様に書く

```liquid
---
hash1: { k1: v1, k2: v2, k3: v3 }
---
```

`':'`(コロン) ＋ `' '`(スペース) でキーと値をペアにする。

参照は

```liquid
{% raw %}{{ page.hash1['k1'] }}{% endraw %}
```
の様になる。
配列と同様、括弧の前後にスペースを入れてはいけない。

`for ～ in` 構文でアクセスできるのも同様。



