FROM ubuntu:24.04

ARG VERSION
ENV ARCH=aarch64-unknown-linux-gnu

# https://github.com/actions/runner-images/issues/10901
COPY add-deb-sources.sh /add-deb-sources.sh
RUN chmod +x /add-deb-sources.sh
RUN /add-deb-sources.sh

# Add arm64 architecture and install build dependencies
RUN dpkg --add-architecture arm64 && \
    apt-get update && \
    apt-get install -y \
    curl \
    build-essential \
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu \
    libstdc++-12-dev:arm64 \
    cmake \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Add aarch64 target
RUN rustup target add aarch64-unknown-linux-gnu

# Set the C/C++ compiler for aarch64
ENV CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc
ENV CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++