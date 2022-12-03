#!/usr/bin/env bash
#################################################
# Init script
#
# By Mr. Bitcoiner
#################################################
set -e
#################################################
# Functions
archCheck(){
    if [ ! -e /app/data/verifications/arch ]; then 
        printf "$(arch)" > /app/data/verifications/arch
        return 0
    elif [ $(arch) != $(cat /app/data/verifications/arch) ]; then 
        printf "Architecture set before: $(cat /app/data/verifications/arch)\n"
        sleep 5
        printf "$(arch)" > /app/data/verifications/arch
        if [ -e /app/data/bitcoinData/bitcoin ]; then rm -r /app/data/bitcoinData/bitcoin; fi
    else 
        return 0
    fi
}
bitcoindSetup(){
    if ! /app/scripts/bitcoindSetup.sh; then 
	printf "Error setting up Bitcoin Core. Killing Container!\n"; exit 1; 
    fi
}
startTorService(){
    systemctl start tor
    tor &
}
# Init
printf "Bitcoind container running\n"
printf "Current architeture: $(arch)\n"

startTorService
archCheck
bitcoindSetup
