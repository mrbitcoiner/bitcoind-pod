#!/usr/bin/env bash
####################
set -e
####################
readonly HELP_MSG='usage: < build | up | down | clean >'
readonly RELDIR="$(dirname ${0})"
####################
source "${RELDIR}/.env"
####################
eprintln(){
	! [ -z "${1}" ] || eprintln 'eprintln err: undefined message'
	printf "${1}\n" 1>&2
	return 1
}
check_env(){
	! [ -z "${IMG_NAME}" ] || eprintln 'undefined env IMG_NAME'
	! [ -z "${CT_NAME}" ] || eprintln 'undefined env CT_NAME'
	! [ -z "${CT_MAINNET_PORT}" ] || eprintln 'undefined env CT_MAINNET_PORT'
	! [ -z "${CT_TESTNET_PORT}" ] || eprintln 'undefined env CT_TESTNET_PORT'
	! [ -z "${CT_REGTEST_PORT}" ] || eprintln 'undefined env CT_REGTEST_PORT'
	! [ -z "${BITCOIN_NETWORK}" ] || eprintln 'undefined env BITCOIN_NETWORK'
	! [ -z "${BITCOIN_USER}" ] || eprintln 'undefined env BITCOIN_USER'
	! [ -z "${BITCOIN_PASSWORD}" ] || eprintln 'undefined env BITCOIN_PASSWORD'
	! [ -z "${BITCOIN_PRUNE}" ] || eprintln 'undefined env BITCOIN_PRUNE'
	! [ -z "${TOR_PROXY}" ] || eprintln 'undefined env TOR_PROXY'
}
set_scripts_permissions(){
	chmod +x scripts/*.sh 1>/dev/null 2>&1 || true
	chmod +x scripts/bitcoind/*.sh 1>/dev/null 2>&1 || true
}
mkdirs(){
	mkdir -p ${RELDIR}/data
}
migrate_from_v0_2_0(){
	[ -e "${RELDIR}/containers/bitcoind/volume/data/bitcoinData/.bitcoin" ] && \
	printf "detected older version, moving data to new directory\n" && \
	mv "${RELDIR}/containers/bitcoind/volume/data/bitcoinData/.bitcoin" \
	${RELDIR}/data/ || true
}
common(){
	check_env
	set_scripts_permissions
	mkdirs
}
build(){
	common
	podman build \
		-f Dockerfile-bitcoind \
		--tag="${IMG_NAME}" \
		${RELDIR}
}
up(){
	common
	migrate_from_v0_2_0
	podman run --rm \
		-p=${CT_MAINNET_PORT}:8332 \
		-p=${CT_TESTNET_PORT}:18332 \
		-p=${CT_REGTEST_PORT}:18443 \
		--env-file="${RELDIR}/.env" \
		-v="${RELDIR}/data:/data" \
		--name="${CT_NAME}" \
		"localhost/${IMG_NAME}" &
}
down(){
	podman exec ${CT_NAME} /static/scripts/bitcoind/shutdown.sh || true
	podman stop ${CT_NAME} 1>/dev/null 2>&1 || true
}
clean(){
	printf 'Are you sure? This will delete all container volume data (Y/n): '
	read input
	[ "${input}" == "Y" ] || eprintln 'ABORT!'
	rm -rf ${RELDIR}/data || true
}
bitcoin-cli(){
	! [ -z "${1}" ] || eprintln 'expected: <command>'
	podman exec -it ${CT_NAME} bitcoin-cli ${1}
}
####################
case ${1} in
	build) build ;;
	up) up ;;
	down) down ;;
	clean) clean ;;
	bitcoin-cli) bitcoin-cli "${2}" ;;
	*) eprintln "${HELP_MSG}" ;;
esac
