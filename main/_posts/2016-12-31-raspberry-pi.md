---
layout: post
title:  "Raspberry Pi 雑記"
categories: RaspberryPi
---
[Raspberry Pi](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/) を買った。いろいろ、細かい設定をしたので備忘録としてめも。

OS は Raspbian 。


* TOC
{:toc}


# Raspberry Pi 本体

## 有線 LAN (NIC) へ固定アドレスを設定する

DHCP が無い場合やケーブル直結などの場合、双方の PC （の NIC）に
手動で固定アドレスを振ることになる。

通常の設定先である `/etc/network/interfaces` の先頭を見ると

```
# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'
```

「注意。このファイルは dhcpcd が使用する。静的アドレスは
`/etc/dhcpcd.conf` を参照。あるいは `man dhcpcd.conf` すること」

とある。（あまり見たことが無い。どこの流儀なのだろう）
なので `/etc/dhcpcd.conf` に追加する。内容は以下。

```
interface eth0
static ip_address=192.168.1.7/24
static routers=192.168.1.1
static domain_name_servers=
```

routers へは、デフォルトゲートウェイがあればそれを、直結なら対向を設定。
DNS の設定はとりあえず無しでも OK。

設定を反映するには network の起動スクリプトを実行するか、リブートする。


```sh
sudo /etc/init.d/networking reload
```

あるいは

```sh
sudo /etc/init.d/networking restart
```

直結先が Windows で、Windows 側のアドレスを変更する場合は、
「アダプターの設定の変更」でネットワークデバイスを無効化～有効化する。





## 無線 LAN のアクセスポイントへ接続する

以下、接続パラメータを SSID 、PASSPHRASE とする
暗号化は WPA2 。ステルスも OK 。

ifconfig で見ると wlan0 が既に上がっている

```
wlan0     Link encap:Ethernet  HWaddr b8:27:eb:XX:XX:XX
```

### wifi のアクセス情報を設定ファイルにを書き込む。

```sh
$ sudo sh -c 'wpa_passphrase SSID PASSPHRASE >> /etc/wpa_supplicant/wpa_supplicant.conf'
```

`/etc/wpa_supplicant/wpa_supplicant.conf` に以下が追加される

```
network={
	ssid="SSID"
	#psk="PASSPHRASE"
	psk=vmlMzm8zhCGAu4dm0zpb6Q8AJVwDVn3uJjGvWZyWOwBA
}
```

生パスワードが書いてある行は削除する。
あるいは上記の様に '#' でコメントアウトする。


### 設定を反映する

```sh
$ sudo /etc/init.d/networking restart
```

### 確認する

```sh
$ ifconfig
wlan0     Link encap:Ethernet  HWaddr b8:27:eb:XX:XX:XX
          inet addr:192.168.200.5  Bcast:192.168.200.255  Mask:255.255.255.0
	  inet6 addr: fe80::XXXX:XXXX:XXXX:XXXX/64 Scope:Link
	  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
	  RX packets:422 errors:0 dropped:302 overruns:0 frame:0
	  TX packets:172 errors:0 dropped:0 overruns:0 carrier:0
	  collisions:0 txqueuelen:1000
	  RX bytes:93874 (91.6 KiB)  TX bytes:31328 (30.5 KiB)
（wlan0 以外は省略）
```

AP から DHCP でアドレス（192.168.200.5）を取得している。



## USB シリアルで接続

### /boot/config.txt の修正

/boot/config.txt に以下を追加する

```
dtoverlay=pi3-miniuart-bt
```

どうやら RPi3 の中でも途中で方法が変わったらしい。
web で検索してヒットする情報の半分は RPi2 か RPi3 の変更前なので、要注意。
その頃はこの作業は不要だったらしい。

（[参考](http://qiita.com/yamamotomanabu/items/33b6cf0d450051d33d41)）


### /boot/cmdline.txt の修正

修正と言うか、確認。
デバイスの指定は以下の様になっている。

```
console=serial0,115200 console=tty1
```

でも、web で検索すると以下が多い

```
console=ttyAMA0,115200 console=tty1
```

結果、どちらでも接続できた。

/dev を見てみたら、以下の様になっていた。

```
$ ls -laF /dev/serial0 /dev/ttyAMA0
lrwxrwxrwx 1 root root       7 May  1 14:00 /dev/serial0 -> ttyAMA0
crw------- 1 pi   tty  204, 64 May  1 14:23 /dev/ttyAMA0
```

つまり、ttyAMA0 というデバイスにアクセスする為に serial0 という
エイリアスを作った、と。なので、どちらでも OK 。


### 結線

Raspberry Pi 側の端子構成は[ここ](https://mynotebook.h2np.net/post/618)の
「Raspberry pi側情報」の項を参照

使用するピンは 3 個。GND、TXD、RXD 。

ケーブル側の配置はそのケーブルの諸元で確認するしかないが、
大抵は以下の配置らしい。

|赤|+5V|
|黒|GND|
|白|RXD|
|緑|TXD|

接続は以下

|赤|+5V|接続しない|
|黒|GND|RPi3のGNDへ接続する|
|白|RXD|RPi3のTXDへ接続する|
|緑|TXD|RPi3のRXDへ接続する|

TX（送信）とRX（受信）のクロス接続となる。

シリアル接続としては単純な形なので、フロー制御などはない。
その為、接続速度が合っていないと文字化けしたり、接続できなかったりする。



### TeraTerm で接続

TeraTerm に限らず、シリアル接続できる端末ソフトなら OK 。

設定する項目は 1 つだけ。速度を 115200 にすること。


#### メニューから接続

1. メニューの Setup-Serial port で速度を設定する
1. メニューの File-NewConnection でSerial を選択して接続する


#### 接続マクロ

TeraTerm の接続マクロは以下の様になった

下記を拡張子が .ttl のファイルとしてとして保存し、
TeraTerm でマクロとして実行する。（関連付け、またはメニューから）

COM ポートは 3 。ユーザ、パスワードはデフォルト。

```
comport = '3'
baudrate = '115200'
user = 'pi'
pass = 'raspberry'
UsernamePrompt = 'raspberrypi login: '
PasswordPrompt = 'Password: '

commandline = '/C='
strconcat commandline comport
strconcat commandline ' /BAUD='
strconcat commandline baudrate

connect commandline
sendln
wait   UsernamePrompt
sendln user
wait   PasswordPrompt
sendln pass
```

ちょっと説明すると、接続後、一度改行を送ってログインプロンプトを
再出力させている。
（接続しただけだと何も表示されない為。
スクリプトの動作トリガとして、ログインプロンプトを取得する）


## CPU の温度を取得する

````sh
$ cat /sys/class/thermal/thermal_zone0/temp
40780
````

または

````sh
$ vcgencmd measure_temp
temp=40.8'C
````

24 時間運用するなら、モニタしておいた方が安心。
とは言え、何度までなら OK なのだろう。（今は冬なので、良いのだが）

あと、[psensor](http://wpitchoune.net/psensor/) は使えなかった。


## USB 機器の接続

Raspberry Pi に USB ポートがあるので、いろいろつなげる。
ただ、Windows じゃないので、大抵はドライバなど無い。

Linux カーネルでサポートされているものが良い。
最近はメーカーがドライバを提供している場合もある。

それでも動作する保証はない。
検索して使用実績を探すのが確実。



# マイクロ SD カード

## Windows 上で扱う

イメージファイルをマイクロ SD カードに書き出すには
[Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) を
使う

マイクロ SD カードを Windows 上で認識させても、最初のパーティション
（/boot 配下）しか見えない。これは Linux のディスクフォーマット（file system）
に対応していないため。

第 2 パーティションにアクセスするには、別途 ext2 を扱うツールが
必要になる。


## Linux 上で扱う

dd コマンドで読み書きできる。また、マイクロ SD カードや
ディスクイメージをマウントして中のファイルを読み書きすることも可能。


## Windows 上の Linux で扱う

VMware や VirtualBox などを使って Linux 環境をつくる。

メインの環境が Windows の場合、一番使い易い。

- VM の機能で USB デバイスを横取りし、Windwos でなく Linux 側に認識させることができる
- VM の機能でディレクトリ共有すると、Windwos 上のファイルを直接読み書きできる。（もちろん SCP や FTP で接続しても良い。Windwos にドライブとして見せるツールもある）


## 構成

マイクロ SD カード（＝イメージファイル）中にはパーティションが 2 つある。
それぞれ、起動後は /boot 、 / （ルート）となる。

フォーマットは DOS 形式と ext4 。Windws は ext4 を認識しない。



## マウントする

USB メモリとして認識した場合、各パーティションは
sdX1 、sdX2 （X は a,b,c など）として認識される。どう認識されたかは
/var/log/syslog に出力されるので、

```
$ sudo tail -f /var/log/syslog
```

と、した状態で USB に挿す。

例えば sdb1 、sdb2 として認識されていたなら、

```
$ sudo mount /dev/sdb2 /mnt
```

などとしてマウントして、読み書きできる。


イメージファイルをマウントするには -o loop をつけ、ループパックマウントする。
更に、パーティションを指定するために offset を指定する。

```
$ sudo mount -o loop,offset=xxxx Raspbian.img /mnt
```

offset オプションの xxxx は 512 * 開始セクタ番号となる
（fdisk -l で確認できる）。



## イメージファイルのマイクロ SD カードへの読み書き

対象はあくまでデバイス（ディスク）であり、パーティションではない。
以下のように /dev/sdb と指定する。sdb1 とはならない。

```
$ sudo dd if=Raspbian.img of=/dev/sdb bs=512M
```


## 読み書きの TIPS

- dd コマンドで。bs の値（バッファサイズ）を大きめにすると、多少書き込み速度が上がる。




# その他の話題

- ブートイメージを VM で動かす。qemu で可能。遅い。
- Debian をインストールする。armhf が動く。カーネルは別。
- クロスでビルドする。カーネル、ドライバを別環境でコンパイルする。PC 上でコンパイルする方が Raspberry Pi 上でするよりも速い。


