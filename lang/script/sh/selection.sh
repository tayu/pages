#! /bin/sh

P=$(expr `date '+%S'` % 2)

if [ 0 = $P ]; Then
    echo "hello ."
fi
