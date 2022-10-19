#!/usr/bin/env bash
#################################################
# Bitcoind Setup script
#
# By Mr. Bitcoiner
#################################################
set -e
#################################################
# Sources
source /app/config/bitcoinConfig
#################################################
# Functions
bitcoindBuild(){
    if [ -e /app/data/bitcoinData/bitcoin/src/bitcoind ]; then return 0; fi
    cd /app/data/bitcoinData
    git clone ${BITCOIN_REPOSITORY_URL} bitcoin
    cd bitcoin
    git checkout ${BITCOIN_COMMIT_VERSION}
    ./autogen.sh
    ./configure
    printf 'Starting bitcoin build, time to drink a cofee!\n'
    sleep 5
    time make
    printf 'Congrats, build finished!\n'
    sleep 5
}
setBitcoindDataOwnership(){
    if [ -e /app/data/bitcoinData/.bitcoin ]; then
        chown -R ${USER}:${USER} /app/data/bitcoinData/.bitcoin
    else   
        mkdir -p /app/data/bitcoinData/.bitcoin
    fi
}
setBitcoindConfig(){
    /app/scripts/bitcoindConfig.sh
}
startBitcoind(){
    export MALLOC_ARENA_MAX=1
    bitcoind &
}
#################################################

bitcoindBuild
setBitcoindDataOwnership
setBitcoindConfig
startBitcoind