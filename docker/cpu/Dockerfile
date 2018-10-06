FROM ubuntu:16.04
LABEL maintainer caffe-maint@googlegroups.com

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
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
        python-dev \
        python-numpy \
        python-pip \
        python-setuptools \
        python-scipy && \
    rm -rf /var/lib/apt/lists/*

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# FIXME: use ARG instead of ENV once DockerHub supports this
ENV CLONE_TAG=ssd-idee

RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm -f get-pip.py
RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/ideeinc/caffe.git . && \
    cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd .. && \
    mkdir build && cd build && \
    cmake -DCPU_ONLY=1 -DUSE_CUDNN=0 .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

#WORKDIR ${CAFFE_ROOT}/data/mnist
#RUN ./get_mnist.sh
#WORKDIR ${CAFFE_ROOT}/data/cifar10
#RUN ./get_cifar10.sh
#WORKDIR ${CAFFE_ROOT}/data/ilsvrc12
#RUN ./get_ilsvrc_aux.sh
#ADD http://dl.caffe.berkeleyvision.org/bvlc_reference_caffenet.caffemodel ${CAFFE_ROOT}/models/bvlc_reference_caffenet
#ADD http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel ${CAFFE_ROOT}/models/bvlc_googlenet

WORKDIR /workspace
