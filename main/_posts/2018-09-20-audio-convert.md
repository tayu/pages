---
layout: post
title:  "mp3 ファイルへの変換が 90 分で止まる（解決？編）"
categories: audio convert
---

[前回]({% post_url 2018-09-20-audio-convert %})の続き

* TOC
{:toc}


# 簡単なまとめ

mp3 に変換すると 90 分までしか変換してくれない

いろいろ調べてみて、pipe で渡している wav ファイルのヘッダ情報の中の
サイズ情報が不正なのだろうと見当をつけた。

が、対処方法まで辿り着けず、wav をファイルとして書き出す方法で逃げた



# その後の進展

## 同じ問題を扱っているサイトを見つけた

別件で検索中に[見つけた](http://gcg00467.xii.jp/wp/archives/461)。

同様の問題に当たり、同様の結論に至った。ただ、こちらは解答を持っていた。

解答は以下

9. mplayer に ヘッダを付けさせない
9. lame に ヘッダを無視させる

つまり、

```sh
$ mplayer -really-quiet -ao pcm:nowaveheader:file=/dev/stdout infle | lame -r - outfile
```
の様にする。

これは効いた。一応は。


## 変換できないファイルが（むしろ）多い
試したところ、mp3 から mp3 への変換はできた。でも、flv や wma からの
変換はうまくいかなかった。

上記サイトにもあるが、man ページをみると、-r を使う時は
同時に ```Sampling rate``` と ```mono/stereo/jstereo``` の別も
指定する必要がある、とのこと。

いろいろな値を試したが、うまく変換が成功する値を見つけることができなかった。

まぁ、見つかったとしてもそれが別のファイルに適用できるとは限らない。

ここに至って、こっちのルートは遠いと判断した。


## で、考えた

たまたま mp3 から mp3 変換できたのはヘッダの値が同じだったからなのではないだろうか。いや、ヘッダから値を読んではいない。と、なると、おそらくデフォルト値。

と、なると、サイズ以外のパラメータはヘッダから読み込ませた方が無難と言うか、
それ以外無い。

つまり、サイズ情報だけを無視すれば良い。


# ソースの修正

ここに至って、やっとソースを読むことにした。[本家](http://lame.sourceforge.net/)からソースを取ってくる。現在の最新の[tar ボール](https://sourceforge.net/projects/lame/files/lame/3.100/)をダウンロードした。

frontend/lame_main.c の lame_main() から読み進む

結果、以下の様になった

get_audio.c の get_audio_common() 関数

```c
    if (global.count_samples_carefully) {
        ・・・
    }
```
これを以下の様に修正する```

```c
    if (0 && global.count_samples_carefully) {
        ・・・
    }
```
このブロックを丸ごと無効にするだけ。#if 0 ～ #endif でも良いのだが、
記述量を最小にしたかった。


この if ブロックの中で、何をしているかというと、
読み込み時に、最後の半端なサイズの残りを読み込む際、そのバイト数を
読み込むべきサイズとして上書きしている。

remaining や samples_to_read という変数名にもそれが出ている


if ブロックの全体は以下

```c
    if (0 && global.count_samples_carefully) {
        unsigned int tmp_num_samples;
        /* get num_samples */
        if (is_mpeg_file_format(global_reader.input_format)) {
            tmp_num_samples = global_decoder.mp3input_data.nsamp;
        }
        else {
            tmp_num_samples = lame_get_num_samples(gfp);
        }
        if (global.num_samples_read < tmp_num_samples) {
            remaining = tmp_num_samples - global.num_samples_read;
        }
        else {
            remaining = 0;
        }
        if (remaining < (unsigned int) framesize && 0 != tmp_num_samples)
            /* in case the input is a FIFO (at least it's reproducible with
               a FIFO) tmp_num_samples may be 0 and therefore remaining
               would be 0, but we need to read some samples, so don't
               change samples_to_read to the wrong value in this case */
	  samples_to_read = remaining;
    }
```


ちなみに diff は以下

```sh
$ diff -u -r lame-3.100.orig lame-3.100
diff -u -r lame-3.100.orig/frontend/get_audio.c lame-3.100/frontend/get_audio.c
--- lame-3.100.orig/frontend/get_audio.c	2017-09-07 04:33:35.000000000 +0900
+++ lame-3.100/frontend/get_audio.c	2018-09-21 06:44:26.864000000 +0900
@@ -771,7 +771,7 @@
      * files which have id3 or other tags at the end.  Note that if you
      * are using LIBSNDFILE, this is not necessary 
      */
-    if (global.count_samples_carefully) {
+    if (0 && global.count_samples_carefully) {
         unsigned int tmp_num_samples;
         /* get num_samples */
         if (is_mpeg_file_format(global_reader.input_format)) {
lame-3.100.orig のみに存在: lame.spec
lame-3.100/libmp3lame のみに存在: .deps
```
コンパイルした残滓のlame.spec や .deps があるが、ソースはこの 1 点の変更だけ。


プログラムの動きは以下の様に変わる

- remaining の計算がされなくなり、毎回 samples_to_read 分の読み取りをトライする
- 結果、ファイル終端で読み込みバイト数が 0 になるまで読み込み続ける



ちなみに、この処理は読み込みループで毎回実行されるワケだから、
全体をコメントアウトして、処理自体を無くした方が処理が減り、
プログラムが速くなることが期待できる。



# その他

これはパイプ経由で読み込む前提の汚いハックであり、upstream に投げるなら
もっとちゃんとしないといけない。例えば以下の様にする。

- コマンドラインオプションでヘッダのサイズ情報を無視するフラグを追加する
- コマンドライン解析で stdin からの入力が指定されたことを識別できているので、その場合だけ、などに条件を絞る

つまり、入力が stdin の場合にサイズ情報を無視するオプションの新設。


ただ、stdin に限るのか、など、議論して決めるべき点もありそう。



# ToDo: あれ、オプションがある？

lame --longhelp してみると、


```
--ignorelength  ignore file length in WAV header
```

なんてオプションがある。これは Ver. 3.99.5 （Debian LTS の stable）には無い。

ひょっとして、対処済み？

