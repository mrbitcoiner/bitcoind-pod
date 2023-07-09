#!/usr/bin/env bash
####################
set -e
####################
readonly BITCOIN_REPOSITORY_URL='https://github.com/bitcoin/bitcoin'
readonly BITCOIN_COMMIT_VERSION='fcf6c8f4eb217763545ede1766831a6b93f583bd'
readonly BITCOIN_PATH="/app/data/bitcoinData"
####################
create_directories(){
  mkdir -p ${BITCOIN_PATH}
}
clone(){
  if [ -e ${BITCOIN_PATH}/bitcoin/src/bitcoind ]; then exit 0;
  else
    printf 'Cloning bitcoin repository\n'
    git clone ${BITCOIN_REPOSITORY_URL} ${BITCOIN_PATH}/bitcoin
    cd ${BITCOIN_PATH}/bitcoin
    git checkout ${BITCOIN_COMMIT_VERSION}
  fi
}
build_bdb(){
  ./contrib/install_db4.sh ${PWD}
}
build_bitcoind(){
  export BDB_PREFIX="${BITCOIN_PATH}/bitcoin/db4";
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
####################
clone
build_bdb
build_bitcoind

