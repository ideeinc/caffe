#!/bin/bash
#
# ./detect.sh model-root-path image-file
#

usage_exit() {
  echo "usage: $0 [-t threshold] [-m mean_value] caffemodel-dir image-dir" >&2
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
DEPLOYTXT=/tmp/.deploy.prototxt$$
TMPDIR=/tmp/.testres$$/
MEAN_VALUE="104,117,123"
THRESHOLD=0.4

while getopts "t:m:h" OPT; do
  case $OPT in
  t) THRESHOLD=$OPTARG
     ;;
  m) MEAN_VALUE=$OPTARG
     ;;
  h) usage_exit
     ;;
  esac
done
shift $((OPTIND - 1))

#
IMGDIR=`absolute_path $2`
CAFFEMODEL=`absolute_filepath $1`
MODELROOT=$(absolute_path `dirname $CAFFEMODEL`)

trap 'rm -f $FILELISTTXT $DETECTLIST $RESIMG $DEPLOYTXT; rm -rf $TMPDIR; exit' 2 3 15 EXIT

if [ ! -d "$IMGDIR" -o ! -f "$CAFFEMODEL" ]; then
  usage_exit
fi

cd $CAFFE_ROOT

mkdir -p $TMPDIR
cp $MODELROOT/deploy.prototxt $DEPLOYTXT
sed -i -e "s|output_directory:.*|output_directory: \"$TMPDIR\"|" $DEPLOYTXT
sed -i -e "s|label_map_file:.*|label_map_file: \"$MODELROOT/labelmap.txt\"|" $DEPLOYTXT
sed -i -e "s|name_size_file:.*|name_size_file: \"$MODELROOT/name_size.txt\"|" $DEPLOYTXT

for f in `ls $IMGDIR/*.jpg $IMGDIR/*.JPG $IMGDIR/*.jpeg $IMGDIR/*.JPEG 2>/dev/null`; do
  echo $f > $FILELISTTXT
  RESIMG=`basename $f`.png
  ./build/examples/ssd/ssd_detect --mean_value=$MEAN_VALUE --confidence_threshold=$THRESHOLD $DEPLOYTXT $CAFFEMODEL $FILELISTTXT >$DETECTLIST 2>/dev/null
  if [ "$?" != 0 ]; then
    ./build/examples/ssd/ssd_detect --mean_value=$MEAN_VALUE --confidence_threshold=$THRESHOLD $DEPLOYTXT $CAFFEMODEL $FILELISTTXT
    exit
  fi

  cat $DETECTLIST
  if [ -n "`cat $DETECTLIST`" ]; then
    python ./examples/ssd/plot_detections.py $DETECTLIST / --save-dir .
    eog $RESIMG
  fi
done