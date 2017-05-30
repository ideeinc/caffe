#!/bin/bash -x
#
# create_data.sh image-dir xml-dir out-dir
#

absolute_path() {
  [ -d "$1" ] || return
  cd $1
  pwd
}

BASEDIR=`absolute_path $(dirname $0)`
IMAGEDIR=`absolute_path $1`
XMLDIR=`absolute_path $2`
OUTDIR=`absolute_path $3`
ROOTDIR=`absolute_path $IMAGEDIR/..`
LABELMAP=${ROOTDIR}/labelmap.txt
FILELIST=${ROOTDIR}/filelist.txt

#
create_label() {
  namelist=`grep '<name>' $XMLDIR/*.xml 2>/dev/null | uniq | sed -e 's/<\/\?name>//g'`
  [ -z "$namelist" ] && return

  echo -e "item {\n  name: \"none_of_the_above\"\n  label: 0\n  display_name: \"background\"\n}" > ${LABELMAP}
  local i=1
  for name in $namelist; do
  	echo -e "item {\n  name: \"$name\"\n  label: ${i}\n  display_name: \"$name\"\n}" >> ${LABELMAP}
  	let i=$i+1
  done
}

# 
create_list() {
  rm -f $FILELIST

  for img in `ls $ROOTDIR/$(basename $IMAGEDIR)`; do
  	base=${img%.*}
    [ -f "$ROOTDIR/$(basename $XMLDIR)"/${base}.xml ] && echo "`basename $IMAGEDIR`/$img `basename $XMLDIR`/${base}.xml" >> $FILELIST
  done

  [ -f $FILELIST ] || return

  # Generate image name and size infomation.
  #if [ ${dataset} == "test" ]; then
  #  ${BASEDIR}/../../build/tools/get_image_size $ROOTDIR ${listfile} ${BASEDIR}/${dataset}"_name_size.txt"
  #fi

  # Shuffle trainval file.
  rand_file=${FILELIST}.rand$$
  cat ${FILELIST} | perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);' > ${rand_file}
  mv ${rand_file} ${FILELIST}
  echo "filelist: ${FILELIST}"
}


[ $# != 3 ] && exit 1
[ -d $IMAGEDIR -a -d $XMLDIR ] || exit 1
[ `absolute_path $IMAGEDIR/..` != `absolute_path $XMLDIR/..` ] && exit 1
[ -d $OUTDIR ] || mkdir -p $OUTDIR

create_label
create_list

redo=1
anno_type="detection"
db="lmdb"
min_dim=0
max_dim=0
width=0
height=0
example_dir=$ROOTDIR/examples
[ -d $example_dir ] || mkdir -p $example_dir

extra_cmd="--encode-type=jpg --encoded"
if [ $redo ]; then
  extra_cmd="${extra_cmd} --redo"
fi

echo "list file: $FILELIST"
echo "out dir: $OUTDIR"
echo
python $BASEDIR/../../scripts/create_annoset.py --anno-type=$anno_type --label-map-file=${LABELMAP} --min-dim=$min_dim --max-dim=$max_dim --resize-width=$width --resize-height=$height --check-label $extra_cmd "$ROOTDIR" "$FILELIST" "$OUTDIR" "$example_dir"
