ARG CUDA_VERSION=12.8.1
FROM nvcr.io/nvidia/cuda:${CUDA_VERSION}-devel-ubuntu22.04

ARG GDRCOPY_VERSION=2.5.1
ARG LIBFABRIC_VERSION=2.3.0
ARG FABTESTS_VERSION=${LIBFABRIC_VERSION}

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y wget 

RUN apt-get install -y libibverbs1 libibverbs-dev

ARG APP_DIR=/workspace
WORKDIR ${APP_DIR}
RUN mkdir -p build
WORKDIR ${APP_DIR}/build
ENV BUILD_DIR=${APP_DIR}/build

# gdrcopy
RUN wget -O gdrcopy-${GDRCOPY_VERSION}.tar.gz https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v${GDRCOPY_VERSION}.tar.gz && \
    tar xf gdrcopy-${GDRCOPY_VERSION}.tar.gz && \
    cd gdrcopy-${GDRCOPY_VERSION}/ && \
    make prefix="${BUILD_DIR}/gdrcopy" \
        CUDA=/usr/local/cuda \
        -j$(nproc --all) install

ENV LD_LIBRARY_PATH=${BUILD_DIR}/gdrcopy/lib:${LD_LIBRARY_PATH}

# libfabric
RUN wget https://github.com/ofiwg/libfabric/releases/download/v${LIBFABRIC_VERSION}/libfabric-${LIBFABRIC_VERSION}.tar.bz2 && \
    tar xf libfabric-${LIBFABRIC_VERSION}.tar.bz2 && \
    cd libfabric-${LIBFABRIC_VERSION} && \
    ./configure --prefix="${BUILD_DIR}/libfabric" \
        --with-cuda=/usr/local/cuda \
        --with-gdrcopy="${BUILD_DIR}/gdrcopy" && \
    make -j$(nproc --all) && \
    make install

ENV LD_LIBRARY_PATH=${BUILD_DIR}/libfabric/lib:${LD_LIBRARY_PATH}

RUN ln -sf /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
    ln -sf /usr/local/cuda/lib64/stubs/libnvidia-ml.so /usr/local/cuda/lib64/stubs/libnvidia-ml.so.1

RUN LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH} ${BUILD_DIR}/libfabric/bin/fi_info

# fabtests
RUN wget https://github.com/ofiwg/libfabric/releases/download/v${FABTESTS_VERSION}/fabtests-${FABTESTS_VERSION}.tar.bz2 && \
    tar xf fabtests-${FABTESTS_VERSION}.tar.bz2 && \
    cd fabtests-${FABTESTS_VERSION} && \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH} \
    ./configure --prefix="${BUILD_DIR}/fabtests" \
        --with-cuda=/usr/local/cuda \
        --with-libfabric="${BUILD_DIR}/libfabric" && \
        make -j$(nproc --all) && \
        make install
