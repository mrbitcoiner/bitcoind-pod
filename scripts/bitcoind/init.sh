#!/usr/bin/env bash
####################
set -e
####################
####################
setup_tor(){
	[ "${TOR_PROXY}" == "enabled" ] && tor 1>/dev/null || return 0 & 
}
setup_bitcoind(){
	[ -e "/data/bitcoin-cli" ] || cp -a /bitcoin/bin/bitcoin-cli /data/bitcoin-cli
	/app/scripts/bitcoind/setup-bitcoind.sh
	bitcoind
}
run() {
	setup_tor
	setup_bitcoind
}
####################
run
