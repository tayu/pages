---
layout: post
title:  "Raspberry Pi のバックアップ"
categories: raspberrypi backup
---

Raspberry Pi を常時稼働させている。これのバックアップか取りずらい。

Debian なので時々アップデートするし、なんならカーネルの入れ替えもする。
つまり、結構頻繁に書き込みが発生している。
なので、定期気にバックアップを取りたいのだが、サーバなので電源を
落としたくない。

そこで稼働状態のまま、なんとかバックアップをとれないか、やってみた。


まぁ、電源を落として母艦の PC につないで MicroSD カードをダンプするのが
正当なやり方なのだが。


実のところ、取得まではやったのだが、レストア～リブートは実際にはやっていない。
まぁ、その程度の確実性として。


* TOC
{:toc}


# 問題は

電源を落としたくない。動作した状態のまま MicroSD のイメージをファイル
として取得したい。


# 方針
ssh で接続し、両側で dd を動かし、間をパイプでつなぐ


参考は、
[SSHでscpを使わずにファイルをコピーする](http://labs.timedia.co.jp/2011/04/rawssh-filecopy.html)



# 手順

Raspberry Pi にログインして

```sh
$ sudo dd if=/dev/mmcblk0 | ssh -p 59022 user@192.168.180.4 dd of=dump.img
```
の様にする

* 192.168.180.4 は sshd が動いているサーバ。母艦、PC 。テスト環境では VM 。
* dump.img は出力ファイル名。
* ssh の接続先で sudo を使わない

これで、母艦側に dump.img というファイルができ上る。

レストアは母艦にて（電源を OFF にして、カードを挿し替えて）

```sh
$ sudo dd if=dump.img of=/dev/sdc
```
の様にする。*sdc* の辺りは実環境に合わせる。



# 説明

最初は母艦側での操作で済ますつもりだった。以下の様に。

```sh
$ ssh -p 22 user@raspberrypi dd if=/dev/mmcblk0 | dd of=dump.img
```
通常のファイルならば問題なく動く。だが、/dev/mmcblk0 へのアクセスに
root 権限が必要で、sudo を使う必要があった。
ssh の接続先で sudo 経由のコマンド実行がうまく行かなかった。

それで、raspberrypi 側から母艦に接続する形になった。


# 言い訳
先述の通り、レストアは実施していない。MidroSD の書き込みは変に時間が
掛かる事が多いし、何よりサーバの電源を OFF にしたくないから。

もしかしたらダンプ取得中に syslog やアプリのログ辺りで不整合になってるかも、
な気はする。でも、fsck で自動で修復させる程度で済むんじゃないかな。

ログなら多少おかしくなってもシステムに影響はないだろうし、時間（日数）が
経てば上書きされて消えていくものだから。

って思うんだけどなぁ。どうだろう。
