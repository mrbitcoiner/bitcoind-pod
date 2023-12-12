#!/usr/bin/env bash
####################
set -e
####################
####################
setup_tor(){
	[ "${TOR_PROXY}" == "enabled" ] && tor 1>/dev/null || true & 
	echo "setup_tor"
}
setup_bitcoind(){
	/static/scripts/bitcoind/setup-bitcoind.sh
	bitcoind
}
run() {
	setup_tor
	setup_bitcoind
}
####################
run
