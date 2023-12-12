#!/usr/bin/env bash
####################
set -e
####################
loop_till_shutdown(){
	local counter=0
	while bitcoin-cli echo test 1>/dev/null 2>&1 \
	&& [ "${counter}" -le "60" ]; do
		sleep 1
		counter="$(( $counter + 1 ))"
		printf "\rwaiting for bitcoind shutdown"
	done
	printf "\n"
}
shutdown(){
	bitcoin-cli stop || true
	loop_till_shutdown
}
####################
shutdown
