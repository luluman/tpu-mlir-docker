FROM ubuntu:22.04 as builder
ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Asia/Shanghai

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates && \
    apt-get install -y build-essential \
    git vim sudo \
    # python
    python3-dev \
    python3-venv \
    python3-pip \
    virtualenv \
    swig \
    tzdata \
    # tablgen
    libncurses5-dev libncurses5 \
    # tools
    ninja-build \
    parallel \
    curl wget \
    unzip \
    graphviz \
    gdb \
    ccache \
    clang lld lldb clang-format \
    libomp-dev \
    # for opencv
    libgl1 \
    libnuma1 libatlas-base-dev \
    # for document
    texlive-xetex && \
    # clenup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

ENV CMAKE_VERSION 3.25.3

RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.sh \
    --no-check-certificate \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && /tmp/cmake-install.sh --skip-license --prefix=/usr/local \
    && rm /tmp/cmake-install.sh

# MLIR python dependency
RUN pip install pybind11-global==2.11.1 numpy==1.24.3 PyYAML==5.4.1 && \
    rm -rf ~/.cache/pip/*

ARG LLVM_VERSION="c67e443895d5b922d1ffc282d23ca31f7161d4fb"
RUN git clone https://github.com/llvm/llvm-project.git && \
    cd llvm-project/ && \
    git checkout ${LLVM_VERSION} && \
    mkdir build && cd build && \
    cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir" \
    -DLLVM_TARGETS_TO_BUILD="" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DMLIR_INCLUDE_TESTS=OFF \
    -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_LLD=ON && \
    cmake --build . --target install && \
    cd / && rm -rf llvm-project /tmp/* ~/.cache/*



RUN TZ=Asia/Shanghai \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    # install some fonts
    && wget "http://mirrors.ctan.org/fonts/fandol.zip" -O /usr/share/fonts/fandol.zip \
    && unzip /usr/share/fonts/fandol.zip -d /usr/share/fonts \
    && rm /usr/share/fonts/fandol.zip \
    && git config --global --add safe.directory '*' \
    && rm -rf /tmp/*

ENV LC_ALL=C.UTF-8

WORKDIR /workspace
# ********************************************************************************
#
# satge 1 caffe
# ********************************************************************************

FROM builder as builder1
RUN apt-get update && apt-get install -y --no-install-recommends \
    libboost-all-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libhdf5-serial-dev \
    libleveldb-dev \
    liblmdb-dev \
    libprotobuf-dev \
    libsnappy-dev \
    protobuf-compiler \
    libopenblas-dev
# RUN pip install numpy
WORKDIR /root
RUN git clone https://github.com/sophgo/caffe.git && \
    mkdir -p caffe/build && cd caffe/build && \
    cmake -G Ninja .. \
    -DCPU_ONLY=ON -DUSE_OPENCV=OFF \
    -DBLAS=open -DUSE_OPENMP=TRUE \
    -DCMAKE_CXX_FLAGS=-std=gnu++11 \
    -Dpython_version="3" \
    -DCMAKE_INSTALL_PREFIX=caffe && \
    cmake --build . --target install
RUN cd /root/caffe/python/caffe && rm _caffe.so && cp /root/caffe/build/lib/_caffe.so .

# ********************************************************************************
#
# satge 2 
# ********************************************************************************
FROM builder as builder2
COPY --from=builder1 /root/caffe/python/caffe /usr/local/python_packages/caffe
COPY --from=builder1 /root/caffe/src/caffe/proto /usr/local/python_packages/proto
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libboost_filesystem.so.1.74.0 /usr/local/lib/
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libboost_python310.so.1.74.0 /usr/local/lib/
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libboost_regex.so.1.74.0 /usr/local/lib/
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libboost_system.so.1.74.0 /usr/local/lib/
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libboost_thread.so.1.74.0 /usr/local/lib/
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libgflags.so.2.2 /usr/local/lib/
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libglog.so.0 /usr/local/lib/
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libopenblas.so.0 /usr/local/lib/
COPY --from=builder1 /usr/lib/x86_64-linux-gnu/libprotobuf.so.23 /usr/local/lib/
WORKDIR /workspace