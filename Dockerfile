FROM nvidia/cuda:10.0-devel-ubuntu18.04

ARG hipsycl_branch=master
ARG hipsycl_commit=f45be0bcc5dc96102057c4bf9bfb4783757d974f
ARG celerity_commit=a961a51d1d3100a5631e6ea68a6443fccaaf5c9a
ARG hipsycl_origin=https://github.com/illuhad/hipSYCL

ENV hipsycl_branch=$hipsycl_branch
ENV hipsycl_origin=$hipsycl_origin
ENV celerity_DIR=/usr/lib
ENV hipSYCL_DIR=/usr/lib
ENV HIPSYCL_PLATFORM=cuda
ENV HIPSYCL_GPU_ARCH=sm_35
ENV CXX=clang++-10
ENV PATH=/usr/local/cuda/bin:$PATH
ENV LIBRARY_PATH=/usr/local/cuda/lib64:$LIBRARY_PATH

RUN apt-get update && \
      apt-get install -f -y git cmake libboost-all-dev python3 llvm-10 llvm-10-dev clang-10 libclang-10-dev libllvm10 libomp-10-dev llvm-10-runtime clang-tools-10 libclang-common-10-dev libclang1-10 libomp-10-dev
WORKDIR /tmp
RUN git clone -b $hipsycl_branch --recurse-submodules $hipsycl_origin && cd hipSYCL && git reset --hard $hipsycl_commit && git clean -f && git submodule update --recursive && mkdir /tmp/build
RUN cd /tmp/hipSYCL/contrib/HIP && git rev-parse --verify HEAD
RUN cd /tmp/hipSYCL/contrib/hipCPU && git rev-parse --verify HEAD
WORKDIR /tmp/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr -DWITH_CPU_BACKEND=ON -DWITH_CUDA_BACKEND=ON /tmp/hipSYCL && make -j$(($(nproc))) install && \
                                 echo "deb http://kambing.ui.ac.id/ubuntu/ focal main restricted universe multiverse" >> /etc/apt/sources.list && \
                                 echo "deb http://kambing.ui.ac.id/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
                                 echo "deb http://kambing.ui.ac.id/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list && \
                                 echo "deb http://kambing.ui.ac.id/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
                                 echo "deb http://kambing.ui.ac.id/ubuntu/ focal-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
                                 apt-get update && apt-get install -y ninja-build cmake 
WORKDIR /tmp
RUN git clone --recurse-submodules https://github.com/celerity/celerity-runtime && cd celerity-runtime && git reset --hard $celerity_commit && git clean -f && git submodule update --recursive  && mkdir build
WORKDIR /tmp/celerity-runtime/build
RUN cmake -G Ninja .. -DCMAKE_PREFIX_PATH="/usr/lib" -DCMAKE_INSTALL_PREFIX="/usr" -DCMAKE_BUILD_TYPE=Release && ninja -j$(($(nproc))) install 
WORKDIR /tmp
RUN git clone https://github.com/bcosenza/celerity-bench && cd celerity-bench && mkdir build
WORKDIR /tmp/celerity-bench/build 
RUN cmake .. && make
