#!/usr/bin/env bash
#################################################
# Init script
#
# By Mr. Bitcoiner
#################################################
# Functions
archSet(){
    printf "$(arch)" > /app/data/verifications/arch
}
bitcoindSetup(){

}
# Init
printf "Bitcoind container running\n"
printf "Current architeture: $(arch)\n"

archSet

bitcoindSetup

tail -f /dev/null