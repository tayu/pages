---
layout: post
title:  "Jekyll: 設定"
categories: jekyll memo
---
# 基本情報

- [本家サイト](http://jekyllrb.com/)
- [日本語](https://jekyllrb-ja.github.io/)
- [Liquid](http://wiki.shopify.com/Liquid)
- [変数](http://jekyllrb-ja.github.io/docs/variables/)
- [シンタックスハイライト](http://hhsprings.pinoko.jp/site-hhs/2015/06/pygments%E3%81%AE%E5%AF%BE%E5%BF%9C%E8%A8%80%E8%AA%9E%E4%B8%80%E8%A6%A7/)
GitHub 上のドキュメントもあったはず。
[Pygments](http://pygments.org/languages/)


# 設定の調整

## コードブロックの行番号とコードが近くて見にくい
行番号は ```<span class="line-numbers">～</span>```の様に設定されている。
ここに属性を指定してやる。

css/main.css に以下を追記する

```css
.line-numbers {
    padding-right: 0.5em;
}
```


## テーブルの枠線が無い
とりあえず、幅は 1 の実線とする

css/main.css に以下を追記する

```css
table, td {
    border: 1px solid gray;
}
```

## 変換元の改行が `<br>` に変換される
元ファイル中の改行は無視すると思っていたので、一寸驚いた。

_config.yml に以下を追記する

```yaml
kramdown:
  hard_wrap: false
```

Redcarpet 用の設定らしかったが、上記で効いてくれた。


## シンタックスハイライトのエンジンを指定する
pygments を使う
_config.yml に以下を追記する

```yaml
highlighter: pygments
```

css を生成させる方法もあるらしい

```shell
$ pygmentize -a .highlight -S monokai -f html > css/monokai.css
```

似た記述が css/main.css に在るので、後で試してみよう
