FROM ubuntu:18.04
LABEL maintainer caffe-maint@googlegroups.com

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV CAFFE_ROOT /opt/caffe

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        devscripts \
        debhelper \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        && \
    apt-get install -y \
        cython \
        python-dev \
        python-setuptools \
        python-numpy \
        python-scipy \
        python-matplotlib \
        python-skimage \
        python-pil \
        python-pydot \
        python-wheel \
        python-pandas \
        python-gflags \
        python-h5py \
        python-protobuf \
        python-nose \
        python-leveldb \
        python-lmdb \
        python-yaml \
        python-dateutil \
        && \
    rm -rf /var/lib/apt/lists/*

WORKDIR $CAFFE_ROOT

ENV CLONE_TAG=ssd-idee

RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/ideeinc/caffe.git . && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCPU_ONLY=1 .. && \
    make pycaffe -j"$(nproc)" && \
    make -j"$(nproc)" && \
    make install

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

#RUN mkdir -p `dirname $PRETRAINED`
#RUN wget -q -O $PRETRAINED http://cs.unc.edu/~wliu/projects/ParseNet/VGG_ILSVRC_16_layers_fc_reduced.caffemodel

WORKDIR /jobs
WORKDIR /workspace
VOLUME  ["/workspace", "/jobs"]
