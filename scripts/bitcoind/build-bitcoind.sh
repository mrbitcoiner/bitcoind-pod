#!/usr/bin/env bash
####################
set -e
####################
readonly BITCOIN_REPOSITORY_URL='https://github.com/bitcoin/bitcoin'
readonly BITCOIN_COMMIT_VERSION='fcf6c8f4eb217763545ede1766831a6b93f583bd'
####################
clone(){
	git clone ${BITCOIN_REPOSITORY_URL} /bitcoin
	cd /bitcoin
	git checkout ${BITCOIN_COMMIT_VERSION}
}
build_bdb(){
  ./contrib/install_db4.sh ${PWD}
}
build_bitcoind(){
  export BDB_PREFIX="/bitcoin/db4";
  ./autogen.sh
  ./configure \
  BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" \
  BDB_CFLAGS="-I${BDB_PREFIX}/include"
  printf '\nStarting bitcoin build, time to drink a coffee!\n'
  sleep 5
  time make
  printf 'Build finished successfully!\n'
  sleep 5
}
build(){
	clone
	build_bdb
	build_bitcoind
}
####################
build
