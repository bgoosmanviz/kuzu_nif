FROM ubuntu:22.04

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
RUN cargo build --release --target aarch64-unknown-linux-gnu


