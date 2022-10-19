FROM ubuntu:22.04

RUN printf 'v0.1.0' > /version

RUN apt update && apt upgrade -y

RUN apt install -y \
        git sqlite3 \
        build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 \
        libevent-dev libboost-dev libsqlite3-dev tor systemctl

ENV BITCOIN_PATH='/app/data/bitcoinData/bitcoin/src'
ENV PATH=${BITCOIN_PATH}:${PATH}

COPY ./volume/scripts/init.sh /init.sh

ENTRYPOINT [ "/init.sh" ]
