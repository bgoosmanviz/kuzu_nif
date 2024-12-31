FROM ubuntu:22.04

# Install build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    g++ \
    cmake \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create working directory
WORKDIR /app

# Copy source code
COPY . .

# Build the library
RUN cargo build --release

# Set the final artifact path
ENV LIBRARY_PATH="/app/target/release"

