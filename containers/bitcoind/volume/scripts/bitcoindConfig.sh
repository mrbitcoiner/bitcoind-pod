#!/usr/bin/env bash
#################################################
# Bitcoind configSet script
#
# By Mr. Bitcoiner
#################################################
set -e
#################################################
source /app/config/bitcoinConfig
#################################################

mkdir -p ~/.bitcoin

printf "
# rpcallowip=${BITCOIN_RPCALLOWIP}
# onlynet=${BITCOIN_ONLYNET}
# proxy=${BITCOIN_PROXY}
# regtest=${BITCOIN_REGTEST}
# regtest.rpcport=${BITCOIN_REGTEST_RPCPORT}

main=${BITCOIN_MAIN}
daemon=${BITCOIN_DAEMON}
server=${BITCOIN_SERVER}
prune=${BITCOIN_PRUNE}
dbcache=${BITCOIN_DBCACHE}
maxmempool=${BITCOIN_MAXMEMPOOL}
maxconnections=${BITCOIN_MAXCONNECTIONS}
datadir=${BITCOIN_DATADIR}
rpcuser=${BITCOIN_RPCUSER}
rpcpassword=${BITCOIN_RPCPASSWORD}
bind=${BITCOIN_BIND}
rpcbind=${BITCOIN_RPCBIND}
rpcport=${BITCOIN_RPCPORT}
" > ~/.bitcoin/bitcoin.conf