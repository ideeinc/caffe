FROM ideeinc/caffe:ssd_gpu

ENV DIGITS_PKG_VERSION 6.1.1
LABEL com.nvidia.digits.version="6.0"

# workaround: gcc and libhdf5-dev are dependencies that are currently missing from the torch package
RUN apt-get update && apt-get install -y --no-install-recommends \
        graphviz \
        libhdf5-dev \
        ssh \
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
        curl \
        software-properties-common \
        git && \
    rm -rf /var/lib/apt/lists/*

# Adding NVIDIA PPA
RUN add-apt-repository ppa:nvidia-digits/dev && \
    apt-get update && apt-get install -y --no-install-recommends \
        python-flaskext.socketio \
        python-skfmm && \
    rm -rf /var/lib/apt/lists/*

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
ENTRYPOINT ["/usr/share/digits/digits-devserver", "-p", "34567"]
