FROM mattlu/tpumlir-dev:22.04-base
ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Asia/Shanghai

RUN pip3 install \
    argcomplete \
    Cython \
    decorator \
    dash \
    dash-bootstrap-components \
    dash-draggable \
    dash-cytoscape \
    dash-split-pane \
    dash-table \
    enum34 \
    gitpython \
    graphviz \
    grpcio \
    ipykernel \
    ipython \
    jedi \
    Jinja2 \
    jupyterlab \
    jsonschema \
    kaleido \
    leveldb \
    lmdb \
    matplotlib \
    networkx \
    nose \
    numpy \
    tensorflow-cpu \
    opencv-contrib-python \
    opencv-python \
    opencv-python-headless \
    packaging \
    paddle2onnx \
    paddlepaddle \
    pandas \
    paramiko \
    Pillow \
    plotly \
    ply \
    protobuf \
    pybind11[global] \
    pycocotools \
    python-dateutil \
    python-gflags \
    pyyaml \
    scikit-image \
    scipy \
    six \
    sphinx sphinx-autobuild sphinx_rtd_theme rst2pdf \
    termcolor \
    tf2onnx \
    tqdm \
    wheel && \
    pip3 install onnx onnxruntime onnxsim && \
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu &&  \
    rm -rf ~/.cache/pip/*

ENV LC_ALL=C.UTF-8

WORKDIR /workspace
