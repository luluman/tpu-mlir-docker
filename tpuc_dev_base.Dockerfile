FROM ubuntu:22.04
ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Asia/Shanghai

# ********************************************************************************
#
# satge 0
# ********************************************************************************

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

ENV CMAKE_VERSION 3.25.3

RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.sh \
    --no-check-certificate \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && /tmp/cmake-install.sh --skip-license --prefix=/usr/local \
    && rm /tmp/cmake-install.sh


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
