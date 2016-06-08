#! /bin/sh

P=$(expr `date '+%S'` % 5)

if [ 0 = $P ]; then
    echo "hello ."
elif [ 1 = $P ]; then
    echo "goodby ."
elif [ 2 = $P ]; then
    echo "hi ."
else
    echo "ho ."
fi
