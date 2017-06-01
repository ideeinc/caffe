#!/bin/bash -x
#
# ./detect.sh model-root-path image-file
#
FILELISTTXT=.flist
DETECTLIST=.detected
RESIMG=`basename $2`.png
THRESHOLD=0.2
MODELROOT=$1
cd $CAFFE_ROOT

trap 'rm -f $FILELISTTXT $DETECTLIST $RESIMG' 2 3 15 EXIT

[ -f "$2" -a -n "$MODELROOT" ] || exit
CAFFEMODEL=`ls $MODELROOT/*.caffemodel | sort | tail -1`
echo $2 > $FILELISTTXT
./build/examples/ssd/ssd_detect --confidence_threshold=$THRESHOLD $MODELROOT/deploy.prototxt $CAFFEMODEL $FILELISTTXT | tee $DETECTLIST

python ./examples/ssd/plot_detections.py $DETECTLIST / --save-dir .
[ -f $RESIMG ] && eog $RESIMG
