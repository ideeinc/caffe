FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04
LABEL com.nvidia.digits.version="6.0"

RUN apt-get update && apt-get install -y --no-install-recommends \
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
        python-six \
        python-requests \
        python-gevent \
        python-gevent-websocket \
        python-wtforms \
        python-flask \
        python-flaskext.wtf \
        python-socketio \
        python-psutil \
        python-magic \
        python-boto \
        python-tk \
        graphviz \
        gcc \
        g++ \
        libhdf5-dev \
        ssh \
        software-properties-common \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Adding NVIDIA PPA
RUN add-apt-repository ppa:nvidia-digits/dev && \
    apt-get update && apt-get install -y --no-install-recommends \
        python-flaskext.socketio \
        python-skfmm && \
    rm -rf /var/lib/apt/lists/*
        

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

ENV CLONE_TAG=ssd-idee

RUN git clone https://github.com/NVIDIA/nccl.git && cd nccl && \
    make -j"$(nproc)" CUDA8_GENCODE="-gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_61,code=sm_61" && \
    make install && cd .. && rm -rf nccl

WORKDIR $CAFFE_ROOT
RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/ideeinc/caffe.git . && \
    sed -i -e 's/set(Caffe_known_gpu_archs .*/set(Caffe_known_gpu_archs "70")/' cmake/Cuda.cmake && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DUSE_CUDNN=1 .. && \
    make pycaffe -j"$(nproc)" && \
    make -j"$(nproc)" && \
    make install

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

#
# DIGITS
#
ENV DIGITS_PKG_VERSION 6.1.1

WORKDIR /usr/share
RUN curl -sL https://github.com/NVIDIA/DIGITS/archive/v${DIGITS_PKG_VERSION}.tar.gz | tar xz && \
    mv DIGITS-${DIGITS_PKG_VERSION} digits

WORKDIR /usr/share/digits
COPY patch.diff .
RUN patch -p1 < patch.diff

VOLUME /data
VOLUME /jobs

ENV DIGITS_JOBS_DIR=/jobs
ENV DIGITS_LOGFILE_FILENAME=/jobs/digits.log

EXPOSE 34567
CMD ["/usr/share/digits/digits-devserver", "-p", "34567"]

