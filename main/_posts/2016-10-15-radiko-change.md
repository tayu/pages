---
layout: post
title:  "radiko の仕様変更"
categories: radiko
---
10/11 に始まった
[radiko](http://radiko.jp/)の
[タイムフリー](http://radiko.jp/rg/timefree/)視聴の影響
なのだろう、仕様変更があり、今までのスクリプトが使えなくなった。

* TOC
{:toc}

# 現状
心配していた通り、10/11 に PC を立ち上げて放送を聴こうとしたら、
聴けなくなっていた。

エラーを見ると、player.swf ファイルの取得ができない様だった。

その後、ダメ元で試してみたのだが、以前のファイルを置いてみたら、
聴けてしまった。？？？

どうやら player.swf の url が変わったらしい。
当初はそれ位の変更なのだと思っていた。


# 変更点

検索して情報を探していたのだが、ようやく対応した人に行き当たった。

[Radikoを録音するWSH](https://gist.github.com/booska/8861693)

そのスクリプトを見てみたところ、もう少し、微妙に変わっていた。

変更点は以下らしい

- player.swf の url
- 認証画像の展開のパラメータ
- 認証で使用するバージョン番号

修正したスクリプトは
[ここ](https://github.com/tayu/linuxtools/tree/master/radio)
に置いた。

差分は一寸ノイズもあるけど、[こんな感じ](https://github.com/tayu/linuxtools/commit/feef666a2b050637ae74f26d8a2439d88fb0e664#diff-a398fb77df76e6153df57cd65fd0a7c5)
。


# まとめ

つまり、メジャーバージョン を 3 --> 4 に上げ、
以前の url でダウンロードできない様にした。
だけど、認証で接続する場合には両方のバージョンを
受け付けている。今はそういう事の様だ。

自作のスクリプトではダウンロードしたファイルを /tmp に置いている。
/tmp 配下はブート時に消えてしまうため、問題が早く出たとも言える。

今後、バージョン 3 で聴いていた人が、player.swf を取り直そうとした時に
聴けなくなる事になる。あるいはバージョン 3 での認証を radiko 側が
何時まで継続してくれるかって不安要素にもなる。
