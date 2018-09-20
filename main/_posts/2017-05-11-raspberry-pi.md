---
layout: post
title:  "Raspberry Pi の設定"
categories: RaspberryPi
---
[Raspberry Pi](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
に
[Debian](http://www.debian.org/)
を
[インストール](http://tokyodebian.alioth.debian.org/pdf/debianmeetingresume201503-presentation-iwamatsu.pdf)
できたので、いろいろ設定していく。

そのメモ。


* TOC
{:toc}

# なぜ Debian か

普段使っている Linux が Debian である事が一番の理由。その他挙げると、

- update 等は本家のサーバの方が良さそう
- インストールパッケージ群はなるべく最小からスタートさせたい
- 環境設定の方法を Debian に合わせたい

辺りがある。

パッケージのアップデート時の動きを見ていると、Raspbian の場合は
ダウンロードが遅い。これはいろいろ理由が考えらる。CPU パワー。
サーバが遠い。サーバの回線が遅い。などなど。

Debian のアップデートでアクセスするサーバは近く（国内）で
負荷分散（CDN）されている。

辺りを考えると、Debian のサーバを使う方が Raspbian のサーバの負荷も減って
良いのではないかと考えた。

インストールパッケージに関しては完全に個人の趣味なのだが、
できる限り把握しておきたい。その一環として、一度は最小構成にして
不要なパッケージを削除する事にしている。

とは言ってもどれが不要かはわからないものもあるし、削除し過ぎて
ブートしなくなってしまってはいけないので、それだけは注意している。
作業は deborphan で「依存されていない」パッケージを表示させ、
その中で不要そうなものを削除。再度 deborphan で表示、の繰り返し。

パッケージが相互依存なんかしていると表示に出てこないので、
完全な方法ではないが、効率的に進める事ができて、ある程度の
成果があるので、よくやる。

最後に設定ファイル回り。Raspbian で固定アドレスを振る為に dhcpcd.conf を
編集した事がある。これ、目的とファイル名が一致していない。
この気持ち悪さがどうにも引っかかってしまった。

今後いろいろ設定していく中で、このような Raspbian 独自の方法が
出てくる可能性があると考えた。大抵は Linux の設定なので、
検索して上位に出てくるような一般的な方法が適用できてほしい。
そういう意味でも一般的なディストリビューションにしておく方が
迷わなくて良さそうである。



# Debian サーバの指定

インストール直後のスクリプトで /etc/apt/sources.list が作成されている。
サーバを CDN に向け、セキュリティ関係を追加。

```
deb http://cdn.debian.or.jp/debian/ jessie main
deb-src http://cdn.debian.or.jp/debian/ jessie main

deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main

deb http://cdn.debian.or.jp/debian/ jessie-updates main
deb-src http://cdn.debian.or.jp/debian/ jessie-updates main

```

その後、システムをアップデートしておく

```sh
# apt-get update
# apt-get upgrade
```

まぁ、古いやり方。



# ホスト名の設定

/etc/hostname に記述する。まだ FQDN は無い。

```sh
$ cat /etc/hostname
xxx
```

例なので伏字っぽく


# スワップの追加

メモリは 1G 程度あるので、まぁ使われることは無いと思われるが、
用意するだけはしておく。

空きパーティションは無いのでファイルで作成する。ファイル名は /swap とする。

```sh
# dd if=/dev/zero of=/swap bs=512M count=2
# mkswap /swap
# swapon /swap
# swapon
NAME  TYPE  SIZE USED PRIO
/swap file 1024M   0B   -1
```
dd で bs=1G とするとメモリが足りないってエラーになるので、2 回に分ける。

ブート後に有効になる様に /etc/fstab を修正する。

```
/swap swap swap defaults    0    0
```

修正した /etc/fstab をテストする

```sh
# swapoff -a
# swapon
# swapon -a
# swapon
NAME  TYPE  SIZE USED PRIO
/swap file 1024M   0B   -1
```

前項で実施したコマンドラインからのスワップの有効化を無効にするために、
一度 swapoff -a して全てのスワップを off にする。
その後、swapon -a する。

最終的にはリブート後に確認する。


# ロケールの設定

各コマンドの日本語表示がちゃんと表示される様に locales をインストールする。

```
# apt-get install locales
# dpkg-reconfigure locales
```

ja_JP.UTF-8 を導入し、システムデフォルトを C (C.UTF-8) にする。

個人環境は .zshrc で ja_JP.UTF-8 に設定済み。
（だから化けてたんだけどね）
root で作業する時は ascii で表示されるよう、C か none 、
最悪 en にする。


# 無線 LAN クライアント

とりあえず内蔵の NIC で AP につなげるための設定

## 関連コマンドのインストール

| コマンド | パッケージ |
| - | - |
| iwconfig | wireless-tools |
| lspci | pciutils |
| lsusb | usbutils  |


## デバイスの認識

おおっと！！！！！！

内蔵 NIC を認識してない！！！！！！！


rpi-update スクリプト or non-free+contrib でどうだろう


pci 接続を確認する

```sh
# lspci
pcilib: Cannot open /proc/bus/pci
lspci: Cannot find any working access method.
```

usb 接続を確認する









設定ファイル
確認






## パーティションのリサイズ

```sh
# parted /dev/sdc
```s

対話モードになる。タブによるコマンド補完やカーソルキーや ^P、^Nに
よるヒストリが使えるので便利

fdisk のような書き込みコマンドが無い。終了するとディスクが更新されている。
つまり、キャンセルできないので注意。

これだけだと mount 時に旧サイズで認識されるので resize2fs を
実行する。

# resize2fs /dev/sdc2

先に fs をチェックする必要があると言われたら、そっちを先に実行する。






