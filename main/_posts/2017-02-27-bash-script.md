---
layout: post
title:  "bash でオプション解析"
categories: bash script
---
シェルスクリプトでコマンドラインのオプションを解析するために、自分用の
ロジックを実装してみた。

いつもは Posix shell の範囲で作るのだが、今回は bash 用。
配列が使えると何かと便利そうなので。

まあ、脱 bash も後でやるかも。


* TOC
{:toc}


# 問題は

コマンドラインから取得されるオプションの解析。

C 言語なら、[getopt.3](http://linuxjm.osdn.jp/html/LDP_man-pages/man3/getopt.3.html)にある、getopt() や getopt_long() の例を使えば良い。

ところがシェルスクリプトだと、イマイチ定番の手法が確立されていない
[模様](http://qiita.com/b4b4r07/items/dcd6be0bb9c9185475bb)。

このページのスクリプトにちょっと追加して、まぁまぁ、使えるものが
できたので、自分用のテンプレとする事にした。


# 検索してみる
前出の
[bash によるオプション解析](http://qiita.com/b4b4r07/items/dcd6be0bb9c9185475bb)
ページが詳しい。

手法としては 3 つある。

- [bash](http://linuxjm.osdn.jp/html/GNU_bash/man1/bash.1.html)の組み込みコマンドである getopts を使う
- 外部コマンドである [getopt](http://linuxjm.osdn.jp/html/util-linux/man1/getopt.1.html) を使う
- 自前のロジックを実装する

で、このページの一番下に出てくる以下を元にする事にした。



```bash
declare -i argc=0
declare -a argv=()

while (( $# > 0 ))
do
    case "$1" in
	-*)
	    if [[ "$1" =~ 'n' ]]; then
		nflag='-n'
	    fi
	    if [[ "$1" =~ 'l' ]]; then
		lflag='-l'
	    fi
	    if [[ "$1" =~ 'p' ]]; then
		pflag='-p'
	    fi
	    shift
	    ;;
	*)
	    ((++argc))
	    argv=("${argv[@]}" "$1")
	    shift
	    ;;
    esac
done
```


# 改良してみる

上記で不満だったのは、-nl なんかが使える一方、-x とか、対象外のオプションを
指定されたときに検出できないこと。

また、オプションの形式も -o XXX、-oXXX 、--option XXX に加えて --option=XXX も
欲しいなぁ、と思った。

結果、以下の様になった。

```bash
declare -i argc=0
declare -a argv=()

while (( $# > 0 )); do
    case "$1" in
	'--' | '-' )		# <-- (1)
	    shift
	    ((argc+=$#))
	    argv=("${argv[@]}" "$@")
	    break
	    ;;
	'-o' | '--option' )	# <-- (2)
	    if _isValue "$2" ; then
		arg_o="$2"
		shift
	    else
		_usage
	    fi
	    ;;
	--option=* )		# <-- (2)
	    arg_o="${1#--option=}"
	    ;;
	-o* )			# <-- (2)
	    arg_o="${1#-o}"
	    ;;
	-* )
	    if ! getopt ":lnp" "$1" 2>&1 >/dev/null ; then	# <-- (3)
		_usage
	    fi
	    if [[ "$1" =~ 'l' ]]; then
		arg_l="true"
	    fi
	    if [[ "$1" =~ 'n' ]]; then
		arg_n="true"
	    fi
	    if [[ "$1" =~ 'p' ]]; then
		arg_p="true"
	    fi
	    ;;
	* )
	    ((++argc))
	    argv=("${argv[@]}" "$1")
	    ;;
    esac
    shift
done
```

スクリプト中の # <-- (n) がポイント

以下、ポイント毎に説明する

1. `--` や `-` でオプション解析を中断し、以後の引数をまとめる
2. -o XXX 、-oXXX 、--opton XXX 、--opton=XXX の解析。くっついている場合先頭の `-o` や `--option=` を削除して取り込む
3. -l 、-n 、-p を -np などと指定しつつ、":lnp" でそれ以外をエラーにする

解析終了後にはオプション（-で始まる引数）以外の引数が argv に入り、
その個数が argc に入る。


ちなみに _usage は使用法を表示して exit 1 する関数。
_isValue は後続の引数がオプション（`-` で始まる）であるか
調べる関数で、以下の様になる。

```bash
function _isValue() {
    local opt
    opt="$1"
    if [[ -z "$opt" ]] || [[ "$opt" =~ ^-+ ]]; then
	return 1
    fi
    return 0
}
```

# まとめ

一個のオプションである、-o XXX、-oXXX 、--option XXX 、--option=XXX を
解析するのに 3 個も case のターゲットを記述するのは冗長にもなるし、
同じ処理を複数の場所に書かなければならないのも悩ましい。また、
全体が長くなるのも避けられない。が、それらを割り切れれば、まぁまぁ
良いんじゃないかな、と思う。

記述を少しでも短くし、読みやすくするために、共通処理は関数化するなどして、
記述量を減らすのも大事。


