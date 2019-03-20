FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04
LABEL maintainer caffe-maint@googlegroups.com

ENV CAFFE_ROOT /opt/caffe
ENV MAX_ITER 200000
ENV SNAPSHOT 20000
ENV BATCH_SIZE 32
ENV MEAN_VALUE 53,73,144
ENV GPUS 0,1
ENV PRETRAINED $CAFFE_ROOT/models/VGGNet/VGG_ILSVRC_16_layers_fc_reduced.caffemodel

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
        && \
    rm -rf /var/lib/apt/lists/*

WORKDIR $CAFFE_ROOT

ENV CLONE_TAG=ssd-idee

RUN git clone https://github.com/NVIDIA/nccl.git && cd nccl && \
    make -j"$(nproc)" CUDA8_GENCODE="-gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_61,code=sm_61" && \
    make install && cd .. && rm -rf nccl

WORKDIR $CAFFE_ROOT
RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/ideeinc/caffe.git . && \
    sed -i -e 's/set(Caffe_known_gpu_archs .*/set(Caffe_known_gpu_archs "60 61")/' cmake/Cuda.cmake && \
    mkdir build && cd build && \
    cmake -DUSE_CUDNN=1 .. && \
    make pycaffe -j"$(nproc)" && \
    make -j"$(nproc)" && \
    make install

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

RUN mkdir -p `dirname $PRETRAINED`
RUN wget -q -O $PRETRAINED http://cs.unc.edu/~wliu/projects/ParseNet/VGG_ILSVRC_16_layers_fc_reduced.caffemodel

RUN mkdir /jobs
WORKDIR /workspace
VOLUME  ["/workspace", "/jobs"]

CMD /opt/caffe/scripts/ssd_vgg.py --pretrained="$PRETRAINED" --label_map=/workspace/train/labelmap.txt --val_image_list=/workspace/val/filelist.txt  --name_size=/workspace/train/name_size.txt  --batch_size=$BATCH_SIZE --snapshot=$SNAPSHOT --mean_value="$MEAN_VALUE"  --max_iter=$MAX_ITER --job_root=/jobs --gpus=$GPUS /workspace/train/db  /workspace/val/db
