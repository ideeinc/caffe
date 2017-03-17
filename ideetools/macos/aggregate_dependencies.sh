#!/bin/bash

HOMEBREW_PREFIX=$(brew --prefix)

[[ $0 = /* ]] && PROJECT_DIR=$(dirname $0) || PROJECT_DIR=$(dirname "$PWD/${0#./}")
if [ -z "${CAFFE_ROOT}" ]; then
    CAFFE_ROOT="$(dirname $(dirname ${PROJECT_DIR}))"
fi

CAFFE_BUILD="${CAFFE_ROOT}/build"
MACOS_BUILD="${CAFFE_BUILD}/ideetools/macos"

LIBCAFFE="${CAFFE_BUILD}/lib/libcaffe.1.0.0-rc5.dylib"

update_library() {
    needs_update_files=()

    chmod +w "${1}"
    for lib in $(otool -L "${MACOS_BUILD}/lib/$(basename ${1})" | awk '{print $1}' | grep "${HOMEBREW_PREFIX}"); do
        if [ -f "${lib}" ]; then
            libname="$(basename ${lib})"
            libfile="${MACOS_BUILD}/lib/${libname}"
            if [ ! -f "${libfile}" ]; then
                echo "copy '${libname}' from homebrew: $(dirname ${lib}) within $(basename ${1})"
                cp "${lib}" "${libfile}"

                chmod +w "${libfile}"
                install_name_tool -id "@rpath/${libname}" "${libfile}"
                #install_name_tool -add_rpath "@loader_path/../Frameworks" "${libfile}"
                chmod -w "${libfile}"
                
                needs_update_files+=("${libfile}")
            else
                echo "skip '${libname}' within $(basename ${1})"
            fi
            install_name_tool -change "${lib}" "@rpath/${libname}" "${1}"
        fi
    done
    chmod -w "${1}"

    for f in ${needs_update_files[@]}; do
        update_library "${f}"
    done
}

# create base directory
[ -d "${MACOS_BUILD}" ] && rm -rf "${MACOS_BUILD}"
mkdir -p "${MACOS_BUILD}/"{include,lib}

# copy libraries.
cp "${LIBCAFFE}" "${MACOS_BUILD}/lib/"
update_library "${MACOS_BUILD}/lib/$(basename ${LIBCAFFE})"

# copy headers.
cp -r "${CAFFE_ROOT}/include/caffe" "${MACOS_BUILD}/include/caffe"
mkdir -p "${MACOS_BUILD}/include/caffe/proto"
cp "${CAFFE_BUILD}/include/caffe/proto/caffe.pb.h" "${MACOS_BUILD}/include/caffe/proto/caffe.pb.h"

cp -r "${HOMEBREW_PREFIX}/opt/boost/include/boost" "${MACOS_BUILD}/include/boost"
cp -r "${HOMEBREW_PREFIX}/opt/gflags/include/gflags" "${MACOS_BUILD}/include/gflags"
cp -r "${HOMEBREW_PREFIX}/opt/glog/include/glog" "${MACOS_BUILD}/include/glog"
cp -r "${HOMEBREW_PREFIX}/opt/protobuf/include/google" "${MACOS_BUILD}/include/google"
cp -r "${HOMEBREW_PREFIX}/opt/opencv/include/opencv" "${MACOS_BUILD}/include/opencv"
cp -r "${HOMEBREW_PREFIX}/opt/opencv/include/opencv2" "${MACOS_BUILD}/include/opencv2"

