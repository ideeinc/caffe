#!/bin/bash
#
# ./detect.sh model-root-path image-file
#
absolute_path() {
  if [ -d "$1" ]; then
    cd "$1"
    pwd
  else
    echo $1
  fi
}

absolute_filepath() {
  if [ -f "$1" ]; then
    DIR=$(absolute_path `dirname $1`)
    echo $DIR/`basename $1`
  else
    echo $1
  fi
}

#
FILELISTTXT=/tmp/.flist$$
DETECTLIST=/tmp/.detected$$
JPGFILE=`absolute_filepath $2`
RESIMG=`basename $2`.png
THRESHOLD=0.4
MODELROOT=`absolute_path $1`

trap 'rm -f $FILELISTTXT $DETECTLIST $RESIMG' 2 3 15 EXIT

if [ ! -f "$JPGFILE" -o ! -n "$MODELROOT" ]; then
  echo "no such file or directory."
  exit
fi
CAFFEMODEL=`ls $MODELROOT/*.caffemodel | sort | tail -1`
echo $JPGFILE > $FILELISTTXT

cd $CAFFE_ROOT
./build/examples/ssd/ssd_detect --confidence_threshold=$THRESHOLD $MODELROOT/deploy.prototxt $CAFFEMODEL $FILELISTTXT 2>/dev/null | tee $DETECTLIST
if [ -z "`cat $DETECTLIST`" ]; then
  echo 'no detection'
  eog $JPGFILE
  exit
fi

python ./examples/ssd/plot_detections.py $DETECTLIST / --save-dir .
[ -f $RESIMG ] && eog $RESIMG

