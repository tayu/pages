---
layout: post
title:  "Tera Term で scp を使う"
categories: TeraTerm scp
---
[Tera Term](https://osdn.net/projects/ttssh2/) で、 scp でファイルを
取得するスクリプトを作った。
途中、色々引っかかったのでその記録。また、それに対する変更の要望など。


* TOC
{:toc}


# 背景

あるホストを常時稼働させている。そこに有るファイルを今までは手動で
手元のホストに持ってきていた。[WinSCP](https://winscp.net/)を使って。

そのホスト上でファイルを変換して、それぞれを手元に持ってくる様に
変えた。結果、対象ディレクトリが 2 つになった。WinSCP でやると
送信元と送信先のディレクトリをそれぞれ切り替え、ファイルを選択、と
操作が多くなってしまった。つまり、面倒になった。[^WinSCP]

[^WinSCP]: もちろん WinSCP のサイト登録をディレクトリ毎にするって手はある


そこでスクリプト化し、複数のディレクトリを一回の操作で処理できる様に
しようと考えた。スクリプトは Tera Term でなくとも良かったのだが、
Windows 上に scp コマンドが無いので VBScript は除外。その他の言語は
インストールしていない[^LangOnWindows]し、
[MSYS2](https://www.msys2.org/)を立ち上げるのも一寸違うし。
なら、いつもログインに使っている ttl でやってみようか、となった。
ヘルプを見ていて scprecv コマンドを見つけたので、なんとかなるかなと思って。
いや、WinSCP でもディレクトリの同期とかの機能は有るらしかったのだが、
余計なファイルを消されるといけないし、やはりスクリプトの方が細かく
動きを記述できるので好みなんだな。

[^LangOnWindows]: Windows にはできるだけインストールしないようにしている。特に Admin 権限を必要とするものはシステム側に何が入ってしまうか分からない怖さがある。同様に zip で提供されているものはインストーラを使用せず、zip の展開で導入する様にしている。なので、Windows に最初から入っている言語処理系として VBScript は良く使う。

# 環境
Tera Term は現時点の最新。4.105 (2019-12-17 15:05)。

ホストは Debian 。ハードは Raspberry Pi 。ただし開発時は
ローカルの VirtualBox 上の Debian[^Debian]で行っている。

[^Debian]:Raspberry Pi でも Debian 。Raspbian ではない。


# 結果
なんとか動くものが出来上がった[^source]。

そうそう、ローカル側では、各ディレクトリにファイルしか無い前提。
ディレクトリが有ると一覧の取得で間違ってしまう[^ls]。あと、
パスワードは直接書いてある

[^source]:なんか空行を除かないとソースとして認識されないので見にくくなってしまった

[^ls]:ls でファイルだけの一覧って取れたっけ

```ttl
; connect via ssh by password
; need IPv4 conn. use '/4'.
; env
name = 'dl-download'
host = ''dl
port = '22'
user = 'username'
pass = 'password'
prompt = '] '
waitsec = 2
waitexitsec = 4
; env for dl
REMOTEHOME = "/home/username"
LOCALHOME = "D:\home\dl"
DLNUM = 2
strdim REMOTEDIR DLNUM
strdim LOCALDIR DLNUM
REMOTEDIR[0] = "Downloads"
LOCALDIR[0] = "Downloads"
REMOTEDIR[1] = "dl2/day1"
LOCALDIR[1] = "dl2\day1"
; const
TMPBASE = "temp"
WATCHINTERVAL = 3	; sec.
FILELISTMAX = 1000
strdim Filelist FILELISTMAX
Filelistnum = 0
; variable(s)
conn = ""
srcdir = ""
dstdir = ""
fname = ""
tmpremote = ""
tmplocal = ""
watchfile = ""
size_prev = -1
size_curr = 0
msg = ""
yyyymmdd = ""
hhmmss = ""
tempfile = ""
CountTarget = 0
CountFile = 0
; connect
sprintf2 conn '%s:%s /4 /ssh /auth=password /user=%s /passwd=%s /W=%s' host port user pass name
connect conn
wait prompt
; Download Target(s)
for CountTarget 0 (DLNUM - 1)
  sprintf2 srcdir '%s/%s' REMOTEHOME REMOTEDIR[ CountTarget ]
  sprintf2 dstdir '%s\%s' LOCALHOME LOCALDIR[ CountTarget ]
  call sub_dl_dir
next
; end
:end
pause waitexitsec
sendln #4
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sub routine
; ファイルリストへ追加する
; IN: inputstr
:sub_add_file
Filelist[ Filelistnum ] = inputstr
Filelistnum = Filelistnum + 1
if Filelistnum >= FILELISTMAX then
  messagebox "エラー: ファイル数が多すぎる" "エラー"
  goto end
endif
return
; 転送完了を待つ
;; ローカルファイルの監視がうまくないのでサーバ上で scp プロセスを見る
; IN: watchfile
:sub_wait_rcv
sprintf2 cmd "ps aux | grep ^%s | grep -v grep | grep %s" user "scp"
while 1
  pause WATCHINTERVAL
  flushrecv
  sendln cmd
  wait prompt
  sendln "echo $?"
  recvln
  recvln
  str2int rc inputstr
  if 1 != result then
    continue
  endif
  if 0 != rc then
    break
  endif
endwhile
return
; download one file
; IN: fname, srcdir, dstdir
:sub_dl_file
sprintf2 srcfile '%s/%s' srcdir fname
sprintf2 dstfile '%s\%s' dstdir fname
getdate yyyymmdd "%Y%m%d"
gettime hhmmss "%H%M%S"
sprintf2 tempfile "%s-%s%s.bin" TMPBASE yyyymmdd hhmmss
sprintf2 tmpremote '%s/%s' srcdir tempfile
sprintf2 tmplocal '%s\%s' dstdir tempfile
; コビー先 temp ファイルが存在したら削除する
filesearch tmplocal
if result then
  filedelete tmplocal
endif
; コビー先ファイルが存在したら終了する
filesearch dstfile
if result then
  sprintf2 msg "エラー: ローカルファイルが存在: %s 。中断します" dstfile
  messagebox msg "エラー"
  goto end
endif
; コビー元をリネーム
sendln "mv '" srcfile "' '" tmpremote "'"
wait prompt
pause waitsec
; ダウンロード
scprecv tmpremote tmplocal
; 転送完了を待つ
watchfile = tmplocal
call sub_wait_rcv
pause waitsec
; コビー元のファイル名を戻す
sendln "mv '" tmpremote "' '" srcfile "'"
wait prompt
pause waitsec
; コビー先のファイル名を戻す
filerename tmplocal dstfile
if 0 != result then
  messagebox "エラー: filerename が失敗" "エラー"
  goto end
endif
return
; download from directory
; IN: srcdir, dstdir
:sub_dl_dir
Filelistnum = 0
; check count
sendln "/bin/ls " srcdir " | wc -l"
recvln
recvln
str2int n inputstr
if 1 != result then
   messagebox 'error: str2int' inputstr
   goto end
endif
if 0 = n then
  goto sub_dl_dir_end
endif
; get list
oldtimeout = timeout
timeout = 3
sendln "/bin/ls -1 " srcdir
recvln		; skip prompt, at 1st
result =  1
do
  recvln
  if 1 = result then
    call sub_add_file	; arg: inputstr
  endif
loop while 1 = result
; タイムアウトで抜けるため、プロンプトは表示済み
timeout = oldtimeout
flushrecv
; 各ファイルを取得
for CountFile 0 (Filelistnum - 1)
  fname = Filelist[ CountFile ]
  call sub_dl_file
next
wait prompt
:sub_dl_dir_end
return
```

色々不慣れな記述とか散見されるワケだが、取りあえず動く。

まだ使い込んでいないので、不具合等があれば、適宜修正する予定。

さてさて、今回の本題はここから。


# 引っかかった点

## ファイル名に漢字が使えない
対象ファイルは日本語（漢字）のファイル名がついている。で、これらは
もれなく scprecv が失敗する。理由は file not found 。

最初は転送が失敗しているかと思ったが、ascii のファイル名だと転送できた。
つまり、日本語のファイル名がマズいのだと分かった。

環境は utf-8。サーバ側では LANG が ja_JP.UTF-8 としてあり、
locales パッケージでの生成も行ってある。
Tera Term の設定では送受信とも UTF-8 としてある。
locale も Japanese になってる。

これで ssh でログインした環境で日本語ファイルの
扱いはうまく行っている。
検索してみたけど、ここで引っかかってるページは見当たらなかった。
当然、解決策も見つからない。本当にみんなはうまく行っているのか。
それとも日本語のファイル名なんて鬼門だから近づいていないのか。
その辺りは不明。

せめてうまく行ってる例があれば、それに倣うのに。

仕方ないので、一度 ascii のファイル名にリネームして転送後に戻す事にした。
本当はサーバ側では何も変更したくなかったのだが[^mv]。

[^mv]:サーバ側に変更を加えると、スクリプトが何らかの原因で途中で止まった場合、あるいは予期しない副作用が有った場合に戻せなくなる。従って再実行も難しくなる。


## 完了待ちができない（事はない）
scprecv は非同期で動く。でも、サーバに負荷をかけたり、同時接続をむやみに
増やしたりしたくなかったので、1 本ずつ転送したかった。これが結構難しい。

検索すると
[ファイルのサイズを監視する方法](https://qiita.com/KurokoSin/items/b4d2d0a81c8d05f110ef)と
[サーバ側で scp プロセスを監視する方法](https://www.j-oosk.com/teraterm/macro-command/601/)が見つかった。最初はローカルで済むファイルサイズの監視で
やってみたが、うまく行かなかった。監視間隔を 30 秒とかに長くしても同様。
Tera Term 側の書き込みバッファのフラッシュとか Windows 側のキャッシュ
のフラッシュとかのタイミングでファイルサイズの更新が遅れるとかなのかなぁ。

ちなみにコードは以下。元の ```goto``` を使う形から書き換えた。

```ttl
:sub_wait_rcv
size_prev = -1
size_curr = 0
mtime_prev = ""
mtime_curr = ""
while 1
  size_prev = size_curr
  mtime_prev = mtime_curr
  pause WATCHINTERVAL
  filestat watchfile size_curr mtime_curr
  if size_prev != size_curr then
    continue
  endif
  strcompare mtime_prev mtime_curr
  if 0 != result then
    continue
  endif
  break
endwhile
return
```
最初は do ～ loop while ～ としていたが後で書く様に ')' アンマッチ
エラーが出たので上記の様に変えてしまった。ループの最後に break が有って、
ループの末尾で必ず抜ける、ヘンな形になっているのはそのため。
また、上手く動かない事の対処に更新時刻のチェックを追加したりもした。

なお、scp プロセスを監視する方法は以下

```ttl
:sub_wait_rcv
sprintf2 cmd "ps aux | grep ^%s | grep -v grep | grep %s" user "scp"
while 1
  pause WATCHINTERVAL
  flushrecv
  sendln cmd
  wait prompt
  sendln "echo $?"
  recvln
  recvln
  str2int rc inputstr
  if 1 != result then
    continue
  endif
  if 0 != rc then
    break
  endif
endwhile
return
```
こっちもループの作り方がイマイチな感じだし、```wait "0" "1"``` とか使えば
もうちょっとスマートになったらしい。それ以前に echo $? とかしなくとも
wc -l とかして行数を数えるとかの方が良かったかも。

取りあえず、本来したかった形は以下

```ttl
:sub_wait_rcv
size_prev = -1
size_curr = 0
mtime_prev = ""
mtime_curr = ""
do
  size_prev = size_curr
  mtime_prev = mtime_curr
  pause WATCHINTERVAL
  filestat watchfile size_curr mtime_curr
  strcompare mtime_prev mtime_curr
loop while ((size_prev != size_curr) || (0 != result))
return
```


## エラーメッセージが違う

前述のファイル更新の監視で loop while 部分で ```')' expected``` と言う
エラーが出た。そんなに長い文でもないのに。目視でさえ確認できる範囲だ。

結局原因は文字列と数値の比較であり、```Type mismatch``` となるのが
正しい。


### 検証してみた

以下は ```Type mismatch.``` となる

```ttl
s = "z"
if s = "a" then messagebox "" ""
```

以下は ```')' expected.``` となる

```ttl
s = "z"
do
  messagebox "" ""
loop while (s = "a")
```

結局、エラーの内容は '=' 演算子が比較対象として整数を要求しているのに、
そこに文字列を与えたためである。
だからメッセージとしては ```Type mismatch``` が正しい。
後者では同じ式でありながらメッセージは ```')' expected.``` となっている。

おそらくエラーの評価順とかなのだろう（ソースは追っていない）。
エラーは検出したものの、```loop while``` 節の中であることか、
括弧の中であることの評価順辺りの関係で適用すべきメッセージが
異なってしまっているとかなのかな、と思っている。

ちなみに ```loop while``` 節の括弧を外すとちゃんと```Type mismatch``` と
なる。うーん、である。ただ、条件節の全体を括弧で囲う方が
（特に複数の条件を書く時に）書き方として好み[^compiler]なので
外したくはないんだよなぁ。

[^compiler]:よく C コンパイラに曖昧だから括弧で囲えって言われたっけなぁ


# 雑感

## 情報が少ない
検索してみると Tera Term の情報はそこそこ有る。でも、それらは
ほんの入門、スクリプト（マクロ[^macro]）を動かすまで辺りで終わってる。
scprecv についてはもっと少ない。まして、scprecv で日本語ファイル名[^jp]と
なると。まぁ、探し方が悪かったのだろう。

[^macro]:そう言えば、マクロだったなぁ。でもここまでスクリプトって書いちゃったからもう良いや。

[^jp]:scprecv で日本語ファイル名がマズイとして、その前の xmodem とか B-Plus とかの時代はどうだったのだろう。当時は全て Shift-JIS だったろうからちゃんと動いていたのだろうか。対応先が EUC とか UTF-8 とか増えてちゃんと検証されていないとか有るのかなぁ。あるいは FTP をスキップせずに SCP になっていたらもっと使用例も増えて情報も多かったのかなぁ、とか。

いや、もう、Linux(*NIX) 周りは UTF-8 で統一されたものとして、
限られた開発リソースを絞っても良いと思うんだ。
取りあえず、ちゃんと動く環境が有るって確認が取れれば、それをマネる
事もできるのに、と思うことしきりって状況である。


## SCP の完了待ち

いや、非同期で動かす方が処理として難しいとは思うんだが、
同期、またはそれに近い使い方をしたいって要望も有ると思うんだ。

つまり、転送の完了待ちを簡単にできる様にちょっとした機能を
追加してほしい。

以下、方式を考えてみた

### 内部変数
inputstr 、result の様なシステムグローバルで単一の変数を新設する。

最も簡単な実装としては以下辺り

- スクリプトの開始時に 0 にセットされる
- 転送の開始時に 1 にセットされる
- 転送の終了時に 0 にセットされる
- 変更不可。リードオンリー

もうちょっと柔軟性を求めるなら、以下

- 変更可にする。

汎用フラグとして使えるかも

更に追加するなら、以下

- 転送中に値をチェックして 0（1 以外） であったら転送を中断する

などなどが考えられる

あるいは変数は固定でなく、任意の変数とした方が良いかも。
転送毎に別の変数を使うので処理の自由度が上がる。

ただし、その場合、システムグローバル（単一）でなくなるので、
後付けで修正しようとすると大変な労力になる可能性ってのは良く有るケースだ。

書式としては scprecv の省略可のオプションとするのが良さそう。

前例として sprintf から sprintf2 がある[^sprintf2]。出力先を
システム変数固定から指定した内部変数へと拡張されている。

[^sprintf2]:書式は異なる


### コールバック
非同期処理では良く使われる方法。あんまり細かくしてもキリが無いので、
転送の終了時に 1 度だけ call する位が良いだろう。

プログレス的な表示がしたいとか、処理が長引いた場合に中断したいとかの
要望が有るとしても、最大、最初～途中～最後の 3 箇所だろう。
途中の粒度をどうするか、内部処理の適当なところってのが、
取りあえずの候補として適当かな。〇KBype 毎とか、〇秒毎とかにすると
大変そうだ。そのうちタイマ割込みが欲しいとか言い始めそうだし。

書式としてはやはり scprecv の省略可のオプションとするのが良さそう。


## 要望

### login マクロを sprintf2 バージョンにしてほしい

今回検索していて ```sprintf2``` を知った。
現在同梱されている ```ssh2login.ttl``` は以下の様になっているが、
```sprintf2``` を使うと短くできる。

```ttl
username = 'nike'
hostname = '192.168.1.3'
msg = 'Enter password for user '
strconcat msg username
passwordbox msg 'Get password'
msg = hostname
strconcat msg ':22 /ssh /auth=password /user='
strconcat msg username
strconcat msg ' /passwd='
strconcat msg inputstr
connect msg
```

これを次の様にする。

```ttl
username = 'nike'
hostname = '192.168.1.3'
msg = 'Enter password for user '
strconcat msg username
passwordbox msg 'Get password'
sprintf2 msg "%s:22 /ssh /auth=password /user=%s  /passwd=%s" hostname username inputstr
connect msg
```

全体に短くできて可読性が上がるし、```strconcat``` が幾つも並ぶのは
本質的でなく、読みにくくもある。


### 設定の Title のデフォルトを /W= から取らないでほしい

コマンドラインで /W=XXXX を使用しているとウインドウのタイトル部分に
表示される。これはいくつものホストにログインする場合には便利な機能である。

問題はこの文字列が設定メニュー[^menu]の Title のデフォルトとして採用される事。
つまり、どこかのホストにログインした状態でメニューから設定を
保存すると、```TERATERM.INI``` ファイルに保存され、その他の
（/w= を指定しない全ての）Tera Term の実行時にウインドウの Title として
表示されてしまう。つまり /W=XXX を指定しないでログインしたときに、
他のホストでのタイトルが表示されてしまう事になる。

[^menu]:メニューの Setup - Window の Title の項目

使用場面としても、敢えて /W=XXX と指定するのはデフォルトと異なる接続先
である事を意識するためだったりしそうに思う。だから、デフォルトはデフォルトと
して残しておいて、少なくとも コマンドラインの /W=XXX から取らない方が
うれしいのではないかな、と思う。

必要なら（全てのデフォルトとして特定のホスト名を使いたいなら）、むしろ
メニューから設定する手間をかけるだろうし。

### その他、コツなど

思ったことを順不同で

#### 少しずつ書く
少しずつ、動作確認しながら、つまり動かしながら作成する方が
結局は早くできる。

思いついたことをなるべく早く（忘れない内に）書いてしまいたいなんて
事もあるが、他の部分での動きによって、特に受信バッファの状態が
変わったりする事もある。特に同じルーチンを再度呼び出すとかの
場合など、ありがち。


#### 受信バッファの状態を気にする

前項とも関連するが、コマンドを送り、その応答を受信する動作を繰り返す場合、
以前の応答の内容が受信バッファに残っていたりすると動作が変わってしまう。

今回は以下に留意した

- プロンプト待ち（waitln など）を sendln の前後のどちらに置くか統一する
- バッファフラッシュを適宜する。wait の前とか後とか
- タイムアウトも使った方が良い場面もある。プロンプト待ちと使い分けると吉。
- 怪しいところには適宜 pause なり mpause させた方が良いかもしれない

今回の環境では、ログイン後はシェルが zsh で RPROMPT も使っている
のでプロンプトと同時に右プロンプトも表示されている。
そのため、プロンプト表示で止まっていても受信バッファの終端に
ゴミ（意図しない文字列）が入っている事が結構有った。

特に recvln を使う時には数値なら数値が欲しいワケなので、そこにゴミが
入っていると、数値変換が失敗したりする。
