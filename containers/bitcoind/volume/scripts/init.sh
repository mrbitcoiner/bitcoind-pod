#!/usr/bin/env bash
#################################################
# Init script
#
# By Mr. Bitcoiner
#################################################
set -e
#################################################
# Functions
bitcoinConfCheck(){
    if [ ! -e /app/config/bitcoinConfig ]; then
        printf 'bitcoinConfig file not found.\nRun "./control.sh bitcoinconfigcp" to fix.\n'
        exit 1
    fi
}
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
    /app/scripts/bitcoindSetup.sh
}
startServices(){
    systemctl start tor
}
# Init
printf "Bitcoind container running\n"
printf "Current architeture: $(arch)\n"

startServices
bitcoinConfCheck
archCheck
bitcoindSetup

tail -f /dev/null