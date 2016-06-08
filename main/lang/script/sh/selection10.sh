#! /bin/sh

P="$(expr `date '+%S'` % 5)"
case $P in
    0 | 2 )
	echo "even ."
	;;
    1 | 3 )
	echo "odd ."
	;;
    * )
	echo "unknown ."
	;;
esac

