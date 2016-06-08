#! /bin/sh

P=$(expr `date '+%S'` % 2)

if [ 0 = $P ]; then
    echo "hello ."
else
    echo "goodby ."
fi
