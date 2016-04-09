---
layout: post
title:  "Jekyll の設定"
categories: jekyll config
---
* TOC
{:toc}

設定関連で変更した項目

# 情報源

- [本家サイト](http://jekyllrb.com/)
- [日本語](https://jekyllrb-ja.github.io/)
- [Liquid](http://wiki.shopify.com/Liquid)
- [変数](http://jekyllrb-ja.github.io/docs/variables/)
- [シンタックスハイライト](http://hhsprings.pinoko.jp/site-hhs/2015/06/pygments%E3%81%AE%E5%AF%BE%E5%BF%9C%E8%A8%80%E8%AA%9E%E4%B8%80%E8%A6%A7/)
GitHub 上のドキュメントもあったはず。
[Pygments](http://pygments.org/languages/)




# _config.yml

## 出力先の指定
GitHub Pages の html 置き場に直接生成する。

_config.yml に以下を追記する

```yaml
destination: ../../username.github.io
```

username は GitHub のアカウント名

## ベース URL
相対パスでアクセスする様、~.~を前置する。
そういう用途のものではない気もするが。

```yaml
baseurl: "."
```

## マークダウンの書式
GFM(GitHub Flavored Markdown) とする


```yaml
kramdown:
  input: GFM
```

## .md ファイル中の改行を無視する
ちょっと驚いた。

```yaml
kramdown:
  hard_wrap: false
```

## シンタックスハイライトのエンジンを指定する
シンタックスハイライトには pygments を使う。

```yaml
highlighter: pygments
```

