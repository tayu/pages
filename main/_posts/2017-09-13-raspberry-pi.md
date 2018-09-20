---
layout: post
title:  "Raspberry Pi のカーネル構築"
categories: RaspberryPi
---
[Raspberry Pi](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
でなんだかんだしていて、カーネルをコンパイルする事にした。
大きな理由は 2 つ。NIC のドライバのコンパイルにカーネルのヘッダ類が必要なこと。
もう一つは、nftables をパッケージから入れてみたら不安定になったため、
カーネルのパラメータを確認するため。

* TOC
{:toc}

# 信頼できる手順の確認

Raspberry Pi 自身の歴史も長くなり、web で検索すると前モデルの情報もいろいろ
ヒットする。また、同じモデルの中でも微妙にバージョンアップしてたりして、
欲しい情報ではない事も多い。

カーネルコンパイルがそんな状況で、ここで長くハマってしまった。

結局、たどり着いたのは
[公式 blog](https://www.raspberrypi.org/documentation/linux/kernel/building.md)
だった。

ここでは RPi2 と RPi3 に分けて書いてあるので、RPi3 用の手順がはっきりと
確認できる。



# 工夫

繰り返し実行するので、手順をスクリプト化し、.tar ファイルを生成するようにした。
それを SD カードの root で展開する。

昔の NetBSD あたりはこうしていたらしいから、ある意味、由緒正しい方法とも
言える（かも）。

