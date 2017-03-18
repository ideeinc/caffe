FROM ideeinc/caffe:gpu

ENV DIGITS_PKG_VERSION 5.0.0
LABEL com.nvidia.digits.version="5.0"

# workaround: gcc and libhdf5-dev are dependencies that are currently missing from the torch package
RUN apt-get update && apt-get install -y --no-install-recommends \
            graphviz \
            gcc \
            g++ \
            libhdf5-dev \
            ssh \
            python-pip \
            curl \
            git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/share
RUN curl -sL https://github.com/NVIDIA/DIGITS/archive/v${DIGITS_PKG_VERSION}.tar.gz | tar xz && \
    mv DIGITS-${DIGITS_PKG_VERSION} digits

WORKDIR /usr/share/digits
RUN pip install -r requirements.txt && \
    pip install -e .

VOLUME /data
VOLUME /jobs

ENV DIGITS_JOBS_DIR=/jobs
ENV DIGITS_LOGFILE_FILENAME=/jobs/digits.log

EXPOSE 34567
ENTRYPOINT ["/usr/share/digits/digits-devserver", "-p", "34567"]
