#!/bin/bash

HOMEBREW_PREFIX=$(brew --prefix)
PROJECT_DIR="$(pwd)"

CAFFE_ROOT=$(dirname $(dirname ${PROJECT_DIR}))
CAFFE_BUILD="${CAFFE_ROOT}/.build_release"
MACOS_BUILD="${CAFFE_BUILD}/macos"

LIBCAFFE="${CAFFE_BUILD}/lib/libcaffe.so.1.0.0-rc3"

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
            install_name_tool -change "${lib}" "@loader_path/../Frameworks/${libname}" "${1}"
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

# change dyld symbols manually each files.
cp "${HOMEBREW_PREFIX}/opt/boost/lib/libboost_system-mt.dylib" "${MACOS_BUILD}/lib/libboost_system-mt.dylib"
chmod +w "${MACOS_BUILD}/lib/libboost_system-mt.dylib"
install_name_tool -id "@rpath/libboost_system-mt.dylib" "${MACOS_BUILD}/lib/libboost_system-mt.dylib"
chmod -w "${MACOS_BUILD}/lib/libboost_system-mt.dylib"


# copy headers.
cp -r "${CAFFE_ROOT}/include/caffe" "${MACOS_BUILD}/include/caffe"
mkdir -p "${MACOS_BUILD}/include/caffe/proto"
cp "${CAFFE_BUILD}/src/caffe/proto/caffe.pb.h" "${MACOS_BUILD}/include/caffe/proto/caffe.pb.h"

cp -r "${HOMEBREW_PREFIX}/opt/boost/include/boost" "${MACOS_BUILD}/include/boost"
cp -r "${HOMEBREW_PREFIX}/opt/gflags/include/gflags" "${MACOS_BUILD}/include/gflags"
cp -r "${HOMEBREW_PREFIX}/opt/glog/include/glog" "${MACOS_BUILD}/include/glog"
cp -r "${HOMEBREW_PREFIX}/opt/protobuf/include/google" "${MACOS_BUILD}/include/google"

