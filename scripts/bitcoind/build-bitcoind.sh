#!/usr/bin/env bash
####################
set -e
####################
readonly BITCOIN_REPOSITORY_URL='https://github.com/bitcoin/bitcoin'
readonly BITCOIN_COMMIT_VERSION='44d8b13c81e5276eb610c99f227a4d090cc532f6'
####################
clone(){
	git clone ${BITCOIN_REPOSITORY_URL} /bitcoin
	cd /bitcoin
	git checkout ${BITCOIN_COMMIT_VERSION}
}
build_bdb(){
	make -C depends \
	NO_BOOST=1 NO_LIBEVENT=1 NO_QT=1 NO_SQLITE=1 \
	NO_NATPMP=1 NO_UPNP=1 NO_ZMQ=1 NO_USDT=1
}
build_bitcoind(){
	case "$(arch)" in
	aarch64) export BDB_PREFIX="/bitcoin/depends/aarch64-unknown-linux-gnu" ;;
	x86_64) export BDB_PREFIX="/bitcoin/depends/x86_64-pc-linux-gnu" ;;
	*) printf 'Unsupported architecture\n' 1>&2; return 1 ;;
	esac
  ./autogen.sh
  ./configure \
	--disable-tests \
	--disable-bench \
	--with-zmq \
  BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" \
  BDB_CFLAGS="-I${BDB_PREFIX}/include"
  printf '\nStarting bitcoin build, time to drink a coffee!\n'
  sleep 5
  time make -j 4
  printf 'Build finished successfully!\n'
  sleep 5
}
finish() {
	mv /bitcoin /bitcoin.old
	mkdir -p /bitcoin/bin
	mv \
		/bitcoin.old/src/bitcoin-cli \
		/bitcoin.old/src/bitcoind \
		/bitcoin.old/src/bitcoin-tx \
		/bitcoin.old/src/bitcoin-util \
		/bitcoin.old/src/bitcoin-wallet \
		/bitcoin/bin/
	rm -rf /bitcoin.old
}
build(){
	clone
	build_bdb
	build_bitcoind
	finish
}
####################
build
