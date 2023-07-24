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
    # md5
    libssl-dev \
    # python
    python3-dev \
    python3-venv \
    python3-pip \
    virtualenv \
    swig \
    tzdata \
    # tools
    ninja-build \
    parallel \
    curl wget \
    unzip \
    graphviz \
    gdb \
    # for opencv
    libgl1 \
    libnuma1 libatlas-base-dev \
    libncurses5 libncurses5-dev libcairo2-dev\
    # for document
    texlive-xetex && \
    # clenup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 0 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 0

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
    # install ccache
    && wget "https://github.com/ccache/ccache/releases/download/v4.7.4/ccache-4.7.4-linux-x86_64.tar.xz" -O /tmp/ccache-4.7.4-linux-x86_64.tar.xz \
    && tar xf /tmp/ccache-4.7.4-linux-x86_64.tar.xz -C /tmp \
    && mv /tmp/ccache-4.7.4-linux-x86_64/ccache /usr/local/bin/ \
    && rm -rf /tmp/*

ENV LC_ALL=C.UTF-8

WORKDIR /workspace
