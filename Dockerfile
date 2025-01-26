FROM rust:latest AS builder

RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

ARG REPO_URL=https://github.com/jeroenflvr/safe-shutdown.git
ARG BRANCH=main

# Clone the specified branch of the repository into /usr/src/app
RUN git clone --branch $BRANCH $REPO_URL /usr/src/app

# Set the working directory
WORKDIR /usr/src/app

# Build the project in release mode
RUN cargo build --release

# === Stage 2: Create the runtime image ===
FROM alpine:latest

# Install necessary libraries (if your binary is not fully static)
# RUN apk add --no-cache libssl1.1

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/target/release/safe-shutdown /usr/local/bin/safe-shutdown

# Set the binary as the entry point
ENTRYPOINT ["/usr/local/bin/safe-shutdown"]

# Optionally, expose a port (adjust as needed)
EXPOSE 8080

# Option 2: Using scratch for an even smaller image (binary must be statically linked)
# FROM scratch
# COPY --from=builder /usr/src/app/target/release/my_binary /my_binary
# ENTRYPOINT ["/my_binary"]
# EXPOSE 8080
