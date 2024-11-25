FROM docker.io/library/debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

ADD /scripts/bitcoind/build-bitcoind.sh /static/scripts/build-bitcoind.sh

RUN \
	set -e; \
	apt update; \
	apt install --no-install-recommends -y \
	git sqlite3 build-essential libtool autotools-dev automake pkg-config \
	bsdmainutils python3 libevent-dev libboost-dev libsqlite3-dev tor wget \
	curl ca-certificates libzmq3-dev; \
	/static/scripts/build-bitcoind.sh

FROM docker.io/library/debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=0 /bitcoin /bitcoin

ENV PATH=/bitcoin/bin:${PATH}

RUN \
	set -e; \
	apt update; \
	apt install --no-install-recommends -y \
	libevent-dev libsqlite3-dev tor libzmq3-dev \
	ca-certificates

ENTRYPOINT ["/app/scripts/bitcoind/init.sh"]
