---
layout: post
title:  "radiko の放送局一覧を作った"
categories: radiko xml
---
radiko の放送局の ID 一覧が欲しかったので一覧を作成した。

ちょっと遠くに持ち出した影響か、しばらく前から外部接続の IP アドレスが
安定しない。そうすると radiko に東京リージョン(JP13)と認めてもらえず
東京圏の放送が聞けない。

とはいえ、どこからにはつながっているので、その時点で聞ける放送局が
何かを探すのが、毎回となると結構大変って事で。

なので、ID の一覧。

* TOC
{:toc}


# 背景
radiko をスクリプトで聞いている。のだが、上述の様な事になって、
東京圏の放送局が聞けたり聞けなくなったりしていた。

状況は、（時々）radiko のエリア判定で他の地域と判定されるって状態。
しかも、それが一定でなく、本当に北海道から沖縄までの判定を食らったりしている。

でも、何か音を出しておく状態に慣れてしまったので、他局ではあっても
radiko で放送を聞きたい。幸い、スクリプトは ID を指定すれば[^areacode]
どこの放送局でも聞ける様になっている。

[^areacode]: radiko 側の地域判定に沿っている限り

問題は「今、どの放送局が聞けるのか。その ID は」を迅速に見つけること


# 構想
日本には 47 都道府県があり、JP13 が東京都ってのも
[ISO_3166-2:JP](https://ja.wikipedia.org/wiki/ISO_3166-2:JP)
の様に標準の規定に則っているものだ。

つまり、県単位って事。

この辺の話は
[ここ](http://www.dcc-jpl.com/foltia/wiki/radikomemo)にお世話になった

入力は県（JP* ってやつ）毎に xml ファイルとして取得できる。
それをいい感じに処理して、出力は html とすることにした。

xml の扱いは xpath で扱えることが録音スクリプトの作成時に分かっていた。
実はここが一番大きい。ここの見通しが立っていたので周辺の作業をスクリプト化
することで多くない作業量で作成できる見通しが立っていた。



# スクリプト

スクリプトは最後に

## 注釈

途中で IFS を設定しているのは項目を for 文に並べるときに間に空白があると
うまく動かないので、そのために一時的に区切り文字からスペースを抜くため。

他の言語なら必要無いだろう

最初に JP13 を処理し、その後 47 までループしつつ JP13 をスキップするのは
自分が良く使う JP13 を先頭に持ってくるため。
全く同じ処理を 2 度書いたのは残念だったけど、1st バージョンとして
とにかく動かすのを急いだため。


## 感想
最初は手作業でやろうかなとも考えたけど、スクリプトの力って
やっぱり大きい。

一度、スクリプトを作っておけば何度でも実行できるし、
なによりヒューマンエラーが入らない。

もっともデータのエラーには無力で、今回で言うと放送局へのリンクに使った画像が
幾つか入っていない。


## ToDo
上記の[ページ](http://www.dcc-jpl.com/foltia/wiki/radikomemo)によると
V3 が出ているので、そっちへの対応。

新バージョンが出てるって事は、今の v2 が何時まで使えるか分からないって事だから


## スクリプト

```sh
#! /bin/bash

HTML="radiko.html"
ODIR="area"
HRER="13"

declare AREANAME=(
    "北海道"
    "青森県"
    "岩手県"
    "宮城県"
    "秋田県"
    "山形県"
    "福島県"
    "茨城県"
    "栃木県"
    "群馬県"
    "埼玉県"
    "千葉県"
    "東京都"
    "神奈川県"
    "新潟県"
    "富山県"
    "石川県"
    "福井県"
    "山梨県"
    "長野県"
    "岐阜県"
    "静岡県"
    "愛知県"
    "三重県"
    "滋賀県"
    "京都府"
    "大阪府"
    "兵庫県"
    "奈良県"
    "和歌山県"
    "鳥取県"
    "島根県"
    "岡山県"
    "広島県"
    "山口県"
    "徳島県"
    "香川県"
    "愛媛県"
    "高知県"
    "福岡県"
    "佐賀県"
    "長崎県"
    "熊本県"
    "大分県"
    "宮崎県"
    "鹿児島県"
    "沖縄県"
)


# IN: エリアコード
_genHtml() {
    local area xml opt
    local ids names hrefs banners
    local i w e

    ids=()
    names=()
    hrefs=()
    banners=()

    area=$1
    xml="${ODIR}/${area}.xml"
    if [ ! -f ${xml} ]; then
	opt="-q -O ${xml} http://radiko.jp/v2/station/list/${area}.xml"
	wget ${opt}
    fi

    for w in $(cat ${xml} | xpath -q -e 'stations/station/id/text()'); do
	ids+=(${w})
    done
    for w in $(cat ${xml} | xpath -q -e 'stations/station/href/text()'); do
	hrefs+=(${w})
    done
    for w in $(cat ${xml} | xpath -q -e 'stations/station/banner/text()'); do
	banners+=(${w})
    done
    IFS='	
'
    for w in $(cat ${xml} | xpath -q -e 'stations/station/name/text()'); do
	names+=(${w})
    done
    IFS=' 	
'

    for i in $(seq 0 $((${#ids[@]} - 1))); do
	cat <<EOF
<tr class="radiko_tr">
<td class="radiko_td">${names[i]}</td>
<td class="radiko_td">${ids[i]}</td>
<td class="radiko_td">
  <a href="${hrefs[i]}">
    <img class="banner"
    src="${banners[i]}"
    alt="${names[i]}"
    />
  </a>
</td>
</tr>
EOF
    done
}

_head() {
    cat <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja-JP" xml:lang="ja-JP">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    <link rel="INDEX" href="./index.html" />
    <link rel="stylesheet" type="text/css" href="web/index.css" />
    <title>radiko</title>
  </head>
  <body>
  <div class="title">radiko</div>
  <hr />
EOF
}
_foot() {
    cat <<EOF
  </body>
</html>
EOF
}

_areahead() {
    local aid aname

    aid=$1
    aname=$2

    cat <<EOF
  <div id="${aid}">
  <span class="area_name">${aid} ${aname}</span>
  <table>
EOF
}

_areafoot() {
    cat <<EOF
  </table>
  </div>
  <hr />
EOF
}


_toc() {
    local i

    cat <<EOF
  <div>
  <span class="area_list">
EOF
    for i in $(seq ${HRER} ${HRER}); do
	cat <<EOF
  <a href="#JP${i}">JP${i}:${AREANAME[$((i - 1))]}</a>
EOF
    done
    for i in $(seq 1 47); do
	if [ ${HRER} -eq $i ]; then continue; fi
	cat <<EOF
  <a href="#JP${i}">JP${i}:${AREANAME[$((i - 1))]}</a>
EOF
    done
    cat <<EOF
  </span>
  </div>
  <hr />
EOF
}


_main() {
    local i n

    echo "" > ${HTML}
    _head >> ${HTML}

    _toc >> ${HTML}
    for i in $(seq ${HRER} ${HRER}); do
	n="${AREANAME[$((i - 1))]}"
	_areahead JP${i} ${n} >> ${HTML}
	_genHtml JP${i} ${n} >> ${HTML}
	_areafoot JP${i} ${n} >> ${HTML}
    done
    for i in $(seq 1 47); do

	if [ ${HRER} -eq $i ]; then continue; fi

	n="${AREANAME[$((i - 1))]}"
	_areahead JP${i} ${n} >> ${HTML}
	_genHtml JP${i} ${n} >> ${HTML}
	_areafoot JP${i} ${n} >> ${HTML}
    done

    _foot >> ${HTML}
}
_main
```


