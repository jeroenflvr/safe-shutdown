FROM rust:latest AS builder

RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

ARG REPO_URL=https://github.com/jeroenflvr/safe-shutdown.git
ARG BRANCH=main

RUN git clone --branch $BRANCH $REPO_URL /usr/src/app

WORKDIR /usr/src/app

RUN cargo build --release
# 
# === Stage 2: Create the runtime image ===
FROM debian:bookworm 
# 
# # Install necessary libraries (if your binary is not fully static)
# # RUN apk add --no-cache libssl1.1
# 
# # Copy the compiled binary from the builder stage
RUN apt update && apt install -y tini && apt clean
COPY --from=builder /usr/src/app/target/release/safe-shutdown /usr/local/bin/safe-shutdown
# 
# # Set the binary as the entry point
ENTRYPOINT ["/usr/bin/tini"]
# 
# # Optionally, expose a port (adjust as needed)
EXPOSE 8999

# Option 2: Using scratch for an even smaller image (binary must be statically linked)
# FROM scratch
# COPY --from=builder /usr/src/app/target/release/my_binary /my_binary
# ENTRYPOINT ["/my_binary"]
# EXPOSE 8080
=======
#
# === Stage 2 ===
FROM debian:bookworm

RUN apt update && apt install -y tini && apt clean
COPY --from=builder /usr/src/app/target/release/safe-shutdown /usr/local/bin/safe-shutdown

ENTRYPOINT ["/usr/bin/tini"]

EXPOSE 8999
