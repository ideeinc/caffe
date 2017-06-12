#!/bin/bash
#
# ./detect.sh model-root-path image-file
#

usage_exit() {
  echo "usage: $0 [-t threshold] caffemodel-path image-file" >&2
  echo
  exit 1
}

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
THRESHOLD=0.4

while getopts "ht:" OPT; do
  case $OPT in
  t) THRESHOLD=$OPTARG
     ;;
  h) usage_exit
     ;;
  esac
done
shift $((OPTIND - 1))

#
JPGFILE=`absolute_filepath $2`
RESIMG=`basename $2`.png
CAFFEMODEL=`absolute_filepath $1`
MODELROOT=$(absolute_path `dirname $CAFFEMODEL`)

trap 'rm -f $FILELISTTXT $DETECTLIST $RESIMG' 2 3 15 EXIT

if [ ! -f "$JPGFILE" -o ! -f "$CAFFEMODEL" ]; then
  usage_exit
fi
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
