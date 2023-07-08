FROM debian:bookworm-slim

RUN apt update -y

RUN apt install -y \
        git sqlite3 \
        build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 \
        libevent-dev libboost-dev libsqlite3-dev tor wget

ARG DEBIAN_FRONTEND=noninteractive
ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID
ARG BITCOIN_NETWORK
ARG BITCOIN_PRUNE
ARG BITCOIN_USER
ARG BITCOIN_PASSWORD
ARG TOR_PROXY

ENV CONTAINER_USER=${CONTAINER_USER}
ENV CONTAINER_UID=${CONTAINER_UID}
ENV CONTAINER_GID=${CONTAINER_GID}
ENV TOR_PROXY=${TOR_PROXY}
ENV BITCOIN_NETWORK=${BITCOIN_NETWORK}
ENV BITCOIN_PRUNE=${BITCOIN_PRUNE}
ENV BITCOIN_USER=${BITCOIN_USER}
ENV BITCOIN_PASSWORD=${BITCOIN_PASSWORD}
ENV BITCOIN_PATH="/app/data/bitcoinData/bitcoin/src"
ENV PATH=${BITCOIN_PATH}:${PATH}
ENV MALLOC_ARENA_MAX=1

ADD ./volume/scripts/user_setup.sh /scripts/user_setup.sh
ADD ./volume/scripts/init.sh /scripts/init.sh

RUN /scripts/user_setup.sh "${CONTAINER_USER}" "${CONTAINER_UID}" "${CONTAINER_GID}"

ENTRYPOINT [ "/scripts/init.sh" ]
