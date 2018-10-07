FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04
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
# https://github.com/docker/hub-feedback/issues/460
ENV CLONE_TAG=ssd

RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm -f get-pip.py
RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/weiliu89/caffe.git . && \
    cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd ..
RUN git clone https://github.com/NVIDIA/nccl.git && cd nccl && make -j src.build NVCC_GENCODE="-gencode=arch=compute_60,code=sm_60" CUDA_HOME=/usr/local/cuda && cd .. && rm -rf nccl
RUN sed -i -e 's/set(Caffe_known_gpu_archs .*/set(Caffe_known_gpu_archs "60 61")/' cmake/Cuda.cmake && \
    mkdir build && cd build && \
    cmake -DUSE_CUDNN=1 .. && \
    make pycaffe -j"$(nproc)" && \
    make -j"$(nproc)" && \
    cd ..

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /workspace
