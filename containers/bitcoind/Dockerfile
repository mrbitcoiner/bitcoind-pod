FROM debian:bullseye-slim

RUN apt update -y

RUN apt install -y \
        git sqlite3 \
        build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 \
        libevent-dev libboost-dev libsqlite3-dev tor wget

ARG CONTAINER_USER
ARG HOST_UID
ARG HOST_GID
ARG BITCOIN_NETWORK
ARG BITCOIN_USER
ARG BITCOIN_PASSWORD
ARG TOR_PROXY

ENV CONTAINER_USER=${CONTAINER_USER}
ENV TOR_PROXY=${TOR_PROXY}
ENV BITCOIN_NETWORK=${BITCOIN_NETWORK}
ENV BITCOIN_USER=${BITCOIN_USER}
ENV BITCOIN_PASSWORD=${BITCOIN_PASSWORD}
ENV BITCOIN_PATH="/app/data/bitcoinData/bitcoin/src"
ENV PATH=${BITCOIN_PATH}:${PATH}
ENV MALLOC_ARENA_MAX=1

COPY ./volume/scripts /scripts

RUN /scripts/user_setup.sh "${CONTAINER_USER}" "${HOST_UID}" "${HOST_GID}"


ENTRYPOINT [ "/scripts/init.sh" ]
