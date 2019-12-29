---
layout: post
title:  "Xming の接続エラー"
categories: Xming pklink
---
VM 上の X11(Debian) への接続に
[Xming](http://www.straightrunning.com/XmingNotes/) を使っている。
jessie(stable) への接続は問題なかったのだが、
stretch(testing) への接続でエラーになっていた。
結論として Xming のバージョンアップで解決すると思われるのだが、
とりあえず対症療法で手当てしたのでめもめも。



* TOC
{:toc}

# エラーの内容

接続時に

```sh
expected key exchange group packet from server
```

というメッセージボックスが表され、接続失敗になる。

# 原因

## 検索してみる

```sh
expected key exchange group packet from server
```

で検索してみると、「PuTTY Fatal Error: expected key exchange group packet from server」というページが先頭に来る。PuTTY が出しているメッセージらしい。

確かに Xming では ssh で接続してしている。Xming で ssh 接続を担当するのは
別プログラムになっている。plink.exe だ。 Xming のインストールディレクトリ内に
置かれている。

幾つか検索先を読んでいると plink.exe の設定（接続情報）をクリアする等と
あるが、それらしいファイルは無い。レジストリかもしれないが、それだと
ちょっと面倒。などと思っていた。


## テストしてみる

とりあえず、接続できる方と失敗する方の動きを比べてみる。

DOS 窓を開き、plink.exe を直接叩いてみる。


接続に成功する場合は以下

```sh
>plink.exe -v -P 59022 user@127.0.0.1
Looking up host "127.0.0.1"
Connecting to 127.0.0.1 port 59022
Server version: SSH-2.0-OpenSSH_6.7p1 Debian-5+deb8u2
We claim version: SSH-2.0-PuTTY_Release_from_0.60_2007_05_02
Using SSH protocol version 2
Doing Diffie-Hellman group exchange
Doing Diffie-Hellman key exchange with hash SHA-256
Host key fingerprint is:
ssh-rsa 2048 2f:39:c1:1d:21:f0:13:bc:11:b2:fa:61:8d:62:b1:6c
Initialised AES-256 SDCTR client->server encryption
Initialised HMAC-SHA1 client->server MAC algorithm
Initialised AES-256 SDCTR server->client encryption
Initialised HMAC-SHA1 server->client MAC algorithm
Using username "user".
```


接続に失敗する場合は以下

```sh
>plink.exe -v -P 52022 user@127.0.0.1
Looking up host "127.0.0.1"
Connecting to 127.0.0.1 port 52022
Server version: SSH-2.0-OpenSSH_7.2p2 Debian-5
We claim version: SSH-2.0-PuTTY_Release_from_0.60_2007_05_02
Using SSH protocol version 2
Doing Diffie-Hellman group exchange
expected key exchange group packet from server
```

どうやら鍵交換で止まっているらしい。


## 予想してみる
そういえば少し前、SSL が TSL に置き換わるとか SHA-1が非推奨になるとかの
話題があったなぁ、と思い出した。

これは、もしかしたら plink.exe が古い暗号化方式しか使えない一方、
ssh サーバ側はそれらを全て廃止したために、双方で使用する方式の
ネゴが失敗しているのではないか。そんな予想が立った。

そうなら、対策は plink.exe を新しくすること、となる。
暗号の鍵も方式も実行ファイルの中に持っているのだから。


# 対症療法

[Xming](http://www.straightrunning.com/XmingNotes/) のページから
辿って
[PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/) のページへ移動
する。Download ページから各種プログラムのダウンロードができる。
その中に Plink もあるのでダウンロードする。

Xming のインストールディレクトリ中の plink.exe を入れ替え、前回と
同様に DOS 窓で動かしてみる。

```sh
>plink.exe -v -P 52022 user@127.0.0.1
Looking up host "127.0.0.1"
Connecting to 127.0.0.1 port 52022
We claim version: SSH-2.0-PuTTY_Release_0.67
Server version: SSH-2.0-OpenSSH_7.2p2 Debian-5
Using SSH protocol version 2
Doing Diffie-Hellman group exchange
Doing Diffie-Hellman key exchange with hash SHA-256
Host key fingerprint is:
ssh-rsa 2048 c6:6a:f6:b8:32:36:eb:1a:dd:92:47:1e:b3:94:c2:72
WARNING - POTENTIAL SECURITY BREACH!
The server's host key does not match the one PuTTY has
cached in the registry. This means that either the
server administrator has changed the host key, or you
have actually connected to another computer pretending
to be the server.
The new rsa2 key fingerprint is:
ssh-rsa 2048 c6:6a:f6:b8:32:36:eb:1a:dd:92:47:1e:b3:94:c2:72
If you were expecting this change and trust the new key,
enter "y" to update PuTTY's cache and continue connecting.
If you want to carry on connecting but without updating
the cache, enter "n".
If you want to abandon the connection completely, press
Return to cancel. Pressing Return is the ONLY guaranteed
safe choice.
Update cached key? (y/n, Return cancels connection) y
Initialised AES-256 SDCTR client->server encryption
Initialised HMAC-SHA-256 client->server MAC algorithm
Initialised AES-256 SDCTR server->client encryption
Initialised HMAC-SHA-256 server->client MAC algorithm
Using username "user".
user@127.0.0.1's password:
Sent password
```

一度入力待ちになるが、正常に接続できた。

と、言うか。この、キャッシュ情報の更新を行わないと Xming の接続処理が
途中で止まる。

ちなみに接続先が 127.0.0.1 なのは [VirtualBox](https://www.virtualbox.org/) で
立ち上げた VM だから。


# 結論

Xming の HP を久しぶりに見たのだが、新しいバージョンがリリースというか
フリーダウンロードできるようになっている。今まで使っていたものは 6.9.0.31 。
この時はバージョン 7 は有料になっていた記憶がある。で、今は 7.7.0.9 が
ダウンロードできる。

まぁ、これを使えば済む話だったと思う。

ただ、まぁ、流れとして plink.exe を入れ替えて正しく動く事を
確認したかったので、良し。



# 補足：新規接続先につながらない

マヌケな事に最近判明した。

新規に作成した VM になぜかつながらなかったが、1 度、手動で接続したら
その後はつながる様になった。

どうやら、Update cached key? (y/n) の辺りで
入力待ちになっていたらしい。元々の添付のものは、
そこは自動で入力される様になっていたのだろう。

VM 側は OS のバージョンが上がってたりしたので、そっちで何か変わったの
だろうと思っていた。ただ、ssh（Tera Term） の接続で間に合っていたので
深く追求しなかった。

でも、接続先で X を使用する必要が出て、調査を開始することに。
ログを見ても sshd の設定を変えても変わらない。しかもエラーはどこにも
出ていない。単にいつまでもつながらない。タイムアウトにもならない。
そんな状態だった。

どうにも分からなくなり、基本から動作確認してみようとして、前項の手動接続
を試した。つながる。Xming を起動する。つながる。あれって流れ。

おそらく known_hosts の情報をレジストリに保存しているのだろう。
で、その確認で Y/N の入力を求めていた、と。

この確認の入力は初回接続時にだけあるので 1 度接続してしまえば
次からは出ない。

逆に言うと、新規の接続先へは 1 度手動での接続が必要ということ。

