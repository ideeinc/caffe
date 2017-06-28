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
DEPLOYTXT=/tmp/.deploy.prototxt$$
TMPDIR=/tmp/.testres$$/
MEAN_VALUE="104,117,123"
THRESHOLD=0.4
FILETYPE=image

while getopts "t:m:f:h" OPT; do
  case $OPT in
  t) THRESHOLD=$OPTARG
     ;;
  m) MEAN_VALUE=$OPTARG
     ;;
  f) FILETYPE=$OPTARG
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

trap 'rm -f $FILELISTTXT $DETECTLIST $RESIMG $DEPLOYTXT; rm -rf $TMPDIR; exit' 2 3 15 EXIT

if [ ! -f "$JPGFILE" -o ! -f "$CAFFEMODEL" ]; then
  usage_exit
fi
echo $JPGFILE > $FILELISTTXT

mkdir -p $TMPDIR
cp $MODELROOT/deploy.prototxt $DEPLOYTXT
sed -i -e "s|output_directory:.*|output_directory: \"$TMPDIR\"|" $DEPLOYTXT
sed -i -e "s|label_map_file:.*|label_map_file: \"$MODELROOT/labelmap.txt\"|" $DEPLOYTXT
sed -i -e "s|name_size_file:.*|name_size_file: \"$MODELROOT/name_size.txt\"|" $DEPLOYTXT

cd $CAFFE_ROOT
./build/examples/ssd/ssd_detect --file_type=$FILETYPE --mean_value=$MEAN_VALUE --confidence_threshold=$THRESHOLD $DEPLOYTXT $CAFFEMODEL $FILELISTTXT >$DETECTLIST 2>/dev/null
if [ "$?" != 0 ]; then
  ./build/examples/ssd/ssd_detect --file_type=$FILETYPE --mean_value=$MEAN_VALUE --confidence_threshold=$THRESHOLD $DEPLOYTXT $CAFFEMODEL $FILELISTTXT
  exit
fi

cat $DETECTLIST
if [ -z "`cat $DETECTLIST`" ]; then
  echo 'no detection'
  eog $JPGFILE
  exit
fi

python ./examples/ssd/plot_detections.py $DETECTLIST / --save-dir .
[ -f $RESIMG ] && eog $RESIMG
