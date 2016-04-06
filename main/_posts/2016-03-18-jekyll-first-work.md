---
layout: post
title:  "Jekyll: 最初にやるべきこと"
categories: jekyll memo
---
# 最初にやるべきこと

## 出力先の指定
GitHub Pages の html 置き場に直接生成する。

_config.yml に以下を追記する

```yaml
destination: ../../username.github.io
```

username は GitHub のアカウント名

## 自動生成ファイルの修正
サイト情報等を書き変える。例えば、以下

_config.yml | title 、description など |
index.html | トップページ。各記事の見せ方など、今後の課題 |
about.me | ページ情報など |
_includes/head.html | html ヘッダ |
_includes/footer.html | ヘッダ部 |
_includes/header.html | フッタ部 |
css/main.css | メインの CSS |


## 相対パス
GitHub Pages では url は http://username.github.io/ の様に username は
サイト名となるため、ファイルは絶対パスで指定できる。

しかし、ローカルで参照する場合はそうも行かない。

とりあえずの解。_includes/head.html に細工して、css ディレクトリへの
パスを作成する。

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

html に空行が出るのは、ToDo 。

## ベース URL
前項と同様に url も相対パスにする。

_config.yml に以下を追記する

```yaml
baseurl: "."
```

## マークダウンの書式
マークダウンもいろいろと流儀が生まれている模様。でも、ここでは GitHub の
方式としたい。つまり GFM(GitHub Flavored Markdown) ってやつ。

_config.yml に以下を追記する

```yaml
kramdown:
  input: GFM
```
