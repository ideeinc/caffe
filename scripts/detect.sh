#!/bin/bash

FILELISTTXT=.flist.$$
DETECTLIST=.detected.$$
RESIMG=`basename $1`.png
THRESHOLD=0.1
cd ..

[ -z "$1" ] && exit
trap 'rm -f $FILELISTTXT $DETECTLIST $RESIMG' 2 3 15 EXIT

echo $1 > $FILELISTTXT
./build/examples/ssd/ssd_detect --confidence_threshold=$THRESHOLD models/VGGNet/VOC0712/SSD_300x300/deploy.prototxt models/VGGNet/VOC0712/SSD_300x300/VGG_VOC0712_SSD_300x300_iter_120000.caffemodel  $FILELISTTXT 2>/dev/null | tee $DETECTLIST

python ./examples/ssd/plot_detections.py $DETECTLIST / --save-dir .
[ -f $RESIMG ] && eog $RESIMG
