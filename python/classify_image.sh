#!/bin/sh

RESULT=result-$$.npy

trap 'rm -f $RESULT' 2 3 15 EXIT

[ -z "$1" ] && exit
cd `dirname $0`
python ./classify.py --gpu --output $RESULT $@ 2>/dev/null
echo
python ./show_npy.py ../data/ilsvrc12/synset_words.txt $RESULT
