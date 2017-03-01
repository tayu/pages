---
layout: post
title:  "Raspberry Pi の導入"
categories: RaspberryPi
---
[Raspberry Pi](https://www.raspberrypi.org/) を買った。

のだが、色々、進んでいない。

まぁ、のんびりやるとするかな。なので、このページは随時更新していく。


* TOC
{:toc}

# ブツ
[Raspberry Pi 3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
ってやつ。

Amazon を見ていたら、ケース付きで出ていた。
今まで手を出していなかった理由の一つに基板なんかがむき出しのままだと
使いにくそうってのがあった。それが解消され、値段もそこそこって事で
ポチってしまった。

# 基礎知識

入手前に知っておいた方が良い知識。
手に入れて、あれやこれややっていると当たり前になってしまうのだが。

なので、検索すれば出てくる情報でもある



## 購入前に知っておくと良いこと

### 全般

- 単体で PC の様に使える。PC 用のモニタ、キーボード、マウスをつないで使える
- OS はダウンロードしたものを（マイクロ）SD カードに書き込んで使える
- OS は Linux （の独自カスタマイズ）になるので Limux の使用経験があると吉
- OS は Window 環境もあるので、大抵はマウスで操作できる
- 有線の LAN アダプタがあり、DHCP でアドレスが取れると何もしなくても使える
- 無線の LAN アダプタがあり、アクセスポイントを設定すればすぐに使える
- 別売りの USB シリアルをつなぐとモニタ無しで使用できて便利。
- OS の起動はマイクロ SD カードで行う
- 電源スイッチは無い。（マイクロ）USB をつなぐと起動する

カジュアルに安い PC として使う事もできるって感じ。
ノート PC 化するキットもあるし。

### 接続

簡単な順に挙げると

1. モニタ、他をつないで単体で使う
1. 有線 LAN に（DHCP or 固定） でアドレスを振って TeraTerm 等で接続する
1. 無線 LAN に SSID 等を設定して TeraTerm 等で接続する
1. USB シリアルをつないで、TeraTerm 等で接続する（要、起動パラメータ設定）

となる。試すなら、この順で経験値を稼ぐのが良さそう。


### USB シリアル接続

そうそう、USB シリアルについては以下も知っておくと良い。

- Raspberry Pi 2 だとつないですぐに使えた模様。3 だと起動パラメータを仕込まないといけない
- ケーブルが 4 本あるが、検索で見つかる画像だと 3 本しかつないでいない。もう 1 本は電源。つまり、USB から給電する以外にこっちからも給電できる。（両方つないで良いかは知らない。ショートしないのだろうか）
- 一部、使えないものがある。購入時は注意。Windows のバージョンとかでも異なる。


### SD カード

- マイクロ SD カードを使う
- Raspbian の full イメージは 4G 位あるので、カード容量はそれ以上欲しい
- イメージファイルを書き込むとそのイメージファイルの容量しか有効にならないが、残り容量いっぱいにパーティションを拡張するツールがある。[GNU Parted](http://www.gnu.org/software/parted) など
- PC へは USB 接続のカードリーダを使う事が多いと思われる
- PC 接続のカードリーダは マイクロ SD カード専用が小さくて扱いやすい。


## 本体以外に必要なもの

使用形態に応じて。前項を参照

- 給電するための USB ケーブル。一方の口がマイクロ USB であること。
- ブート用のメディアとして、マイクロ SD カード
- マイクロ SD カードを PC に接続するためのカードリーダ


その他

- 有線 LAN を使うなら、ケーブル（100均でも買える。ストレートの直でも使える（事もある））
- 単体で使用するなら、モニタ(HDMI)、マウス、キーボード
- USB 接続機器。Raspberry Pi にポートがあるので、いろいろつなげる。ただ、Windows じゃないので、大抵はドライバなど無い。最低でも Linux でサポートされているものが良いが、それでも動作する保証はない。検索して使用実績を探すのが無難。位のスタンスで。



## ブートまでの手順

### ブートイメージの取得

[ダウンロードページ](https://www.raspberrypi.org/downloads/) から
NOOBS か Raspbian のイメージファイルを取得できる。

どちらも full と lite の 2 種類がある。lite の方は Window 環境が無い分、
ダウンロードサイズが小さい。

最初に使うなら、Raspbian の full イメージが良いと思う。


### ブートイメージの書き込み

取得したファイルを展開し、ディスクイメージファイルを SD カードに書き込む。

Linux なら dd コマンドで。バッファを大きめにすると、多少書き込み速度が上がる。

Windows なら
[Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) など
が使える。


### 起動

SD カードを Raspberry Pi に装着し、USB 給電をつなぐ。

起動すると、ログイン画面になる。ユーザ／パスワードは pi/raspberry 。

ログイン後は普通の Linux 環境として使える。

root 権限で何かするときは sudo する。また、この時要求されるパスワードは
自分のもの、つまり "raspberry" である。この辺りは Ubuntu っぽい。

注意。外部からのアクセスの可能性があるのなら、別ユーザを作るか、
少なくともパスワードは変更しておく。


### アップデート

Raspbian だと [Debian](http://www.debian.org/) や
[Ubuntu](http://www.ubuntu.com/) と同様に、ネットワーク経由で
アプリケーションの追加やアップデートができる。
セキュリティ関連とかは対処しておきたいところ。

```
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install someapp
```

あるいは aptitude コマンドで。この辺は Debian や Ubuntu のマニュアルを
参照のこと。



# 設定変更

## PC に接続して書き込み

Windows でもできないことは無いかもだが、Linux のファイルシステムを
使用していることもあるし、やはり Linux で扱うのが楽。

常用が Windows なら、Linux を VM で動かすのが簡単。
VMware や VirtualBox などが使える。SD カードを使うには、USB 接続の
カードリーダを VM 側に横取りさせる。
そうすると、カードリーダが Windows からは見えなくなり、VM 側（の Linux）で
見える様になる。

Linux からは（大抵は） /dev/sd* として認識されるので、
適宜マウントして読み書きする。

Linux 上なら、SD カードに書き込む前のファイルをマウントして読み書きする
事も簡単にできる。ファイル中にパーティションが存在する場合は
オフセットを指定すれば正しくマウントできる。
この場合は、更新したイメージファイルを SD カードに書き込むことになる。


## 有線 lan (NIC) への固定アドレスの設定

通常の設定先である /etc/network/interfaces の先頭を見ると

```
# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'
```

とある。なので /etc/dhcpcd.conf に以下を追加する

```
interface eth0
static ip_address=192.168.1.2/24
static routers=192.168.1.1
static domain_name_servers=
```

routers へは、デフォルトゲートウェイがあればそれを、直結なら対向を設定。
DNS の設定はとりあえず空にしておく。

TeraTerm などで 192.168.1.2 に接続できる様になる。

このやり方は Raspbian 独自なのだろうか。


## wlan への SSID の設定

ifconfig で見ると wlan0 が既に上がっている


```
wlan0     Link encap:Ethernet  HWaddr b8:27:eb:XX:XX:XX
```

wifi の設定を書き込む。SSID 、PASSPHRASE は AP の設定値。

```
$ sudo sh -c 'wpa_passphrase SSID PASSPHRASE >> /etc/wpa_supplicant/wpa_supplicant.conf'
```

/etc/wpa_supplicant/wpa_supplicant.conf に以下が追加される

```
network={
	ssid="SSID"
	#psk="PASSPHRASE"
	psk=vmlMzm8zhCGAu4dm0zpb6Q8AJVwDVn3uJjGvWZyWOwBA
}
```

生パスワードが書いてある行は削除する。上記では '#' でコメントアウトしている。


設定を反映する

```
$ sudo /etc/init.d/networking restart
```

確認


```
$ ifconfig
wlan0     Link encap:Ethernet  HWaddr b8:27:eb:XX:XX:XX
          inet addr:192.168.179.3  Bcast:192.168.179.255  Mask:255.255.255.0
	  inet6 addr: fe80::XXXX:XXXX:XXXX:XXXX/64 Scope:Link
	  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
	  RX packets:422 errors:0 dropped:302 overruns:0 frame:0
	  TX packets:172 errors:0 dropped:0 overruns:0 carrier:0
	  collisions:0 txqueuelen:1000
	  RX bytes:93874 (91.6 KiB)  TX bytes:31328 (30.5 KiB)
（wlan0 以外は省略）
```

AP から DHCP でアドレスを取得している。
TeraTerm などで 192.168.179.3 に接続できる様になる。


## USB シリアル用パラメータの設定

ToDo 。後で


## qemu で動かす

デスクトップの CPU が早いので、エミュレーション環境でも実機より速い（かも）

ToDo 。後で


## クロスでビルドする

ToDo 。後で


## Debian をインストールする

armhf が使えるらしい

ToDo 。後で


# その他の情報

## CPU の温度を取得する

````
$ cat /sys/class/thermal/thermal_zone0/temp
40780
````

または

````
$ vcgencmd measure_temp
temp=40.8'C
````

24 時間運用するなら、モニタしておいた方が安心。
とは言え、何度までなら OK なのだろう。（今は冬なので、良いのだが）

あと、[psensor](http://wpitchoune.net/psensor/) は使えなかった。
