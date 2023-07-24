FROM mattlu/tpumlir-dev:22.04-base
ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Asia/Shanghai

WORKDIR /workspace
COPY requirements.txt ./
RUN pip3 install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cpu 
RUN rm -rf ~/.cache/pip/*

ENV LC_ALL=C.UTF-8


