#!/usr/bin/env bash
####################
set -e
####################
readonly CFG_DIR="${HOME}/.bitcoin"
readonly CFG_FILE="${CFG_DIR}/bitcoin.conf"
readonly BITCOIN_DATA_PATH='/data/.bitcoin'
####################
eprintln(){
	! [ -z "${1}" ] || eprintln 'eprintln err: undefined message'
	printf "${1}\n" 1>&2
	return 1
}
mkdirs(){
	mkdir -p ${CFG_DIR} ${BITCOIN_DATA_PATH}
}
check_env(){
	! [ -z "${TOR_PROXY}" ] || eprintln 'undefined env TOR_PROXY'
	! [ -z "${BITCOIN_PRUNE}" ] || eprintln 'undefined env BITCOIN_PRUNE'
	! [ -z "${BITCOIN_USER}" ] || eprintln 'undefined env BITCOIN_USER'
	! [ -z "${BITCOIN_PASSWORD}" ] || eprintln 'undefined env BITCOIN_PASSWORD'
}
mainnet_cfg(){
	cat << EOF > ${CFG_FILE} 
main=1
daemon=0
server=1
dbcache=100
maxmempool=300
maxconnections=20
datadir=${BITCOIN_DATA_PATH}
rpcuser=${BITCOIN_USER}
rpcpassword=${BITCOIN_PASSWORD}
rpcallowip=0.0.0.0/0
bind=0.0.0.0
rpcbind=0.0.0.0:8332
deprecatedrpc=create_bdb
EOF
}
testnet_cfg(){
	cat << EOF > ${CFG_FILE} 
testnet=1
daemon=0
server=1
dbcache=100
maxmempool=300
maxconnections=20
datadir=${BITCOIN_DATA_PATH}
rpcuser=${BITCOIN_USER}
rpcpassword=${BITCOIN_PASSWORD}
test.rpcallowip=0.0.0.0/0
test.rpcbind=0.0.0.0
test.rpcport=18332
deprecatedrpc=create_bdb
EOF
}
regtest_cfg(){
	cat << EOF > ${CFG_FILE} 
regtest=1
regtest.rpcport=18443
regtest.rpcbind=0.0.0.0
regtest.rpcallowip=0.0.0.0/0
daemon=0
server=1
dbcache=100
maxmempool=300
maxconnections=20
datadir=${BITCOIN_DATA_PATH}
rpcuser=${BITCOIN_USER}
rpcpassword=${BITCOIN_PASSWORD}
deprecatedrpc=create_bdb
EOF
}
set_prune(){
	[ "${BITCOIN_PRUNE}" -gt "0" ] && \
	cat << EOF >> ${CFG_FILE} || true
prune=${BITCOIN_PRUNE}
EOF
}
set_tor(){
	[ "${TOR_PROXY}" == "enabled" ] && \
	cat << EOF >> ${CFG_FILE} || true
onlynet=onion
proxy=127.0.0.1:9050
EOF
}
set_config(){
	case ${BITCOIN_NETWORK} in
	mainnet) mainnet_cfg ;;
	testnet) testnet_cfg ;;
	regtest) regtest_cfg ;;
	*) eprintln 'valid networks: < mainnet | testnet | regtest >';;
	esac
}
setup(){
	mkdirs
	check_env
	set_config
	set_prune
	set_tor
}
####################
setup
