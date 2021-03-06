---
layout: post
title:  "zsh で predict-on を使う"
categories: zsh config
---
zsh の補完機能は非常に便利。その、さらに便利なモードが先方予測機能
ってやつ。ただ、先鋭過ぎてちょっと困っている。

* TOC
{:toc}

# 先方予測機能とは
コマンドラインの編集（ZLE）で、キー入力毎にヒストリを参照して
候補を表示してくれる機能。

有効にするには

```sh
autoload predict-on
predict-on
```
とする。


web の解説を見ていると「鍛えれば非常に便利」とある。
と言っても、自動的に鍛えられるので、やる事は単に使い続けるだけ。
その一方、「合わなければ使わない方が良い」との記述もある。
また、方々で公開されている .zshrc を見るとコメントアウト
してある事が多い。

つまり、非常にクセが強いって事なのだろう。
特にある程度使い込むまでは。


# つ、使いにくい
こなれてくるまで時間がかかる。それまではむしろ使いにくいって事は
予想していた。

でも、コマンドラインの編集モードが変わったと思える挙動が。

編集業の途中にカーソルを持って行き、2 文字程度入力すると
その位置から後ろが全部消されてしまう。

例えば、

```console
$ ls /some/path/some.file
```
として、先頭にカーソルを持っていって

```console
$ cat /some/path/some.file
```
としようとすると

```console
$ ca
```
なんて事になるって事。


# 調査
検索してみたけど、同様の現象に言及しているページが 1 件あっただけ
だった。そのページでは単に使用をやめていただけなので、
解決につながる情報は無かった。

で、いろいろ検索しつつ考えた。

これって「後半を消去している」んではなくて、
「ヒストリでマッチしたものを表示」しているんではないだろうか。

と、いう事は「補完候補を見つけたら単にインサートする」って
挙動にするオプションが有れば良いってことになるのか？


# とりあえず回避
当面、predict-on と predict-off を手動で切り替える事にした。
検索すると、トグルするコマンドを作ったページも有ったが、
そこまではせず、単純に短いエイリアスを定義した。

```sh
alias pon='predict-on'
alias poff='predict-off'
```
こんな感じ。行の途中で編集する場合は、先に poff を実行する。
その後、pon で戻すって形。

predict-on を使い続けるかどうか、まだ考え中。


# 追記：数ヶ月使った結果

なんとなく、挙動が分かってきた。

結局 zsh がやっていることはキー入力に一致する候補をヒストリから探してきて
コマンドラインに展開する事なんだ。まぁ、その他にもファイルとかコマンドの
引数とか展開する候補が多いので最初は「賢い！？」とか思うのだが。

入力位置を前に戻して入力すると後ろが消えるのも、単にヒストリから先方が一致する
候補を見つけてきて展開しているだけなんだ。

この、内部の動きがある程度読める様になってからは
（こちらの理解が合ってるかどうかはともかく）
ストレスが軽減され、そこそこうまく使える様になった気がする。
それこそ、1 回か 2 回のキー入力でコマンド入力が済んでしまうような
場面も増えた。

キーを前に戻してコマンドライン編集する場合は poff （alias で predict-off）を
実行して一時的にモードを変える様にしている。

つまり、相手の挙動が読める様になったので、先回りしてストレスフルな動きを
封じてしまえるようになったって事。

結局、この、自分にとってストレスになる動きを封じる事が、少ない入力で
できる様になったのが良かったのだと思う。そこから挙動をコントロール
している感が広がり、predict-on を使うのに抵抗が無くなった。
で、使っていると 1 ～ 2 回のキー入力でコマンド入力が済む場面も多くなり、
満足度も上がった。

まぁ、キー入力後に [CTRL+K] で以前の入力の不要部分を消すのは
相変わらず多い。
