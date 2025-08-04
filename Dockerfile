FROM rust:latest AS builder

RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

ARG REPO_URL=https://github.com/jeroenflvr/safe-shutdown.git
ARG BRANCH=main

RUN git clone --branch $BRANCH $REPO_URL /usr/src/app

WORKDIR /usr/src/app

RUN cargo build --release
# === Stage 2 ===
FROM debian:bookworm

RUN apt update && apt install -y tini && apt clean
COPY --from=builder /usr/src/app/target/release/safe-shutdown /usr/local/bin/safe-shutdown

ENTRYPOINT ["/usr/bin/tini"]

EXPOSE 8999
