#!/usr/bin/env bash
####################
set -e
####################
readonly BITCOIN_REPOSITORY_URL='https://github.com/bitcoin/bitcoin'
readonly BITCOIN_COMMIT_VERSION='d0f6d9953a15d7c7111d46dcb76ab2bb18e5dee3'
####################
clone(){
	[ -e "/bitcoin" ] && return 0 || true
	git clone ${BITCOIN_REPOSITORY_URL} /bitcoin
	cd /bitcoin
	git checkout ${BITCOIN_COMMIT_VERSION}
}
build_bitcoind(){
	cd /bitcoin
	printf '\nStarting bitcoin build, time to drink a coffee!\n'
	sleep 5
	cmake -B build -DBUILD_TESTS=OFF -DWITH_ZMQ=ON
	cd build
	make -j 4 2>&1
	printf 'Build finished successfully!\n'
}
finish() {
	mv /bitcoin /bitcoin.old
	mkdir -p /bitcoin/bin
	mv \
		/bitcoin.old/build/bin/bitcoin \
		/bitcoin.old/build/bin/bitcoin-cli \
		/bitcoin.old/build/bin/bitcoin-node \
		/bitcoin.old/build/bin/bitcoind \
		/bitcoin/bin/
	rm -rf /bitcoin.old
}
build(){
	clone
	build_bitcoind
	finish
}
####################
build
