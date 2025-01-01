FROM ubuntu:22.04

ARG VERSION
ENV ARCH=aarch64-unknown-linux-gnu

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

# Create working directory
WORKDIR /app

# Copy source code
COPY . .

# Build the library
RUN cd native/kuzu_ex && \
    cargo build --release --target aarch64-unknown-linux-gnu && \
    cd target/aarch64-unknown-linux-gnu/release && \
    mv libkuzu_ex.so libkuzu_ex-v${VERSION}-nif-2.17-${ARCH}.so && \
    tar -czf libkuzu_ex-v${VERSION}-nif-2.17-${ARCH}.so.tar.gz libkuzu_ex-v${VERSION}-nif-2.17-${ARCH}.so

# The output file will be at:
# /app/native/kuzu_ex/target/aarch64-unknown-linux-gnu/release/libkuzu_ex-v${VERSION}-nif-2.17-aarch64-unknown-linux-gnu.so.tar.gz


