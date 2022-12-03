#!/usr/bin/env bash
#################################################
# Bitcoind configSet script
#
# By Mr. Bitcoiner
#################################################
set -e
#################################################
source /app/config/.env
#################################################

mkdir -p ~/.bitcoin

case "${ENVIRONMENT}" in
	main) cat /app/config/main > ~/.bitcoin/bitcoin.conf ;;
	regtest) cat /app/config/regtest > ~/.bitcoin/bitcoin.conf ;;
	*) printf "ENVIRONMENT NOT SET.\n"; return 1 ;;
esac

