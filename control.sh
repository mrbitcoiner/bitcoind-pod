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
	if ! which which > /dev/null; then printf 'Please install or set \"which\" $PATH\n'; exit 1; fi
	if ! which grep > /dev/null; then printf 'Please install or set \"grep\" $PATH\n'; exit 1; fi
	if ! which docker > /dev/null; then printf 'Please install or set \"docker\" $PATH\n'; exit 1; fi
	if ! which docker-compose > /dev/null; then printf 'Please install or set \"docker-compose\" $PATH\n'; exit 1; fi
}
makeDirs(){
	mkdir -p containers/bitcoind/volume/scripts
	mkdir -p containers/bitcoind/volume/config/examples
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
bitcoinEnvCp(){
	if [ ! -e containers/bitcoind/volume/config/.env ]; then
		cp containers/bitcoind/volume/config/examples/.env containers/bitcoind/volume/config/.env
	fi
	if [ ! -e containers/bitcoind/volume/config/main ]; then
		cp containers/bitcoind/volume/config/examples/main containers/bitcoind/volume/config/main
	fi
	if [ ! -e containers/bitcoind/volume/config/regtest ]; then
		cp containers/bitcoind/volume/config/examples/regtest containers/bitcoind/volume/config/regtest
	fi
}
environmentSubstitute(){
	if [ -z "${1}" ]; then printf "Need new environment name\n"; return 1; fi
	local environment="${1}"
	if [ -e containers/bitcoind/volume/config/.env ]; then 
		sed -i".old" -e "s/ENVIRONMENT=.*/ENVIRONMENT=\""${environment}"\"/g" containers/bitcoind/volume/config/.env
	else printf ".env file not found\n"; exit 1; fi;
}
setEnvironment(){
	case "${1}" in
		main) environmentSubstitute ${1} ;;
		regtest) environmentSubstitute ${1} ;;
		*) printf "Expected environment: [ main | regtest ]\n"; return 1 ;;
	esac
}
#################################################
# Menu
case "${1}" in
	up)
		depsVerify
		makeDirs
		setScriptsPermissions
		bitcoinEnvCp
		setEnvironment "${2}"
		startContainers
	;;
	down)
		stopContainers
	;;
	clean)
		clean
	;;
	*)
		printf 'Usage: [ up | down | envcp | clean | help ]\n'
	;;
esac	
