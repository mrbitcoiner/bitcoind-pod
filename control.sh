#!/usr/bin/env bash
#################################################
# Bitcoin Control Script
#
# By Mr. Bitcoiner
#################################################
set -e
#################################################
# Functions
depsVerify(){
    if ! which which > /dev/null; then printf 'Please install or set \"which\" $PATH\n'; fi
    if ! which grep > /dev/null; then printf 'Please install or set \"grep\" $PATH\n'; fi
    if ! which docker > /dev/null; then printf 'Please install or set \"docker\" $PATH\n'; fi
    if ! which docker-compose > /dev/null; then printf 'Please install or set \"docker-compose\" $PATH\n'; fi
}
makeDirs(){
    mkdir -p containers
    mkdir -p containers/bitcoind
    mkdir -p containers/bitcoind/volume
    mkdir -p containers/bitcoind/volume/scripts
    mkdir -p containers/bitcoind/volume/config
    mkdir -p containers/bitcoind/volume/data
    mkdir -p containers/bitcoind/volume/data/bitcoinData
    mkdir -p containers/bitcoind/volume/data/verifications
}
setScriptsPermissions(){
    chmod +x containers/bitcoind/volume/scripts/*.sh
}
clean(){
    if [ -e containers/bitcoind/volume/data ]; then rm -r containers/bitcoind/volume/data; fi
    if [ -e containers/bitcoind/volume/config/bitcoinConfig ]; then rm -r containers/bitcoind/volume/config/bitcoinConfig; fi
    printf 'Data purged\n'
}
startContainers(){
    if ! docker network ls | grep "bitcoin" > /dev/null; then
        docker network create -d bridge bitcoin
    fi
    docker-compose up --build &
}
stopContainers(){
    docker-compose down
}
bitcoinConfigCp(){
    cp containers/bitcoind/volume/config/bitcoinConfig.example containers/bitcoind/volume/config/bitcoinConfig
}
#################################################
# Menu
case $1 in
    up)
        depsVerify
        makeDirs
        setScriptsPermissions
        startContainers
    ;;
    down)
        stopContainers
    ;;
    bitcoinconfigcp)
        bitcoinConfigCp
    ;;
    clean)
        clean
    ;;
    *)
        printf 'Usage: [up|down|bitcoinconfigcp|clean|help]\n'
    ;;
esac