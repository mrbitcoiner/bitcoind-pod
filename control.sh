#!/usr/bin/env bash
####################
set -e
####################
readonly HELP_MSG='usage: < build | up | down | mk-systemd | rm-systemd | clean >'
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
	! [ -z "${CT_ZMQ_PORT}" ] || eprintln 'undefined env CT_ZMQ_PORT'
	! [ -z "${BITCOIN_NETWORK}" ] || eprintln 'undefined env BITCOIN_NETWORK'
	! [ -z "${BITCOIN_USER}" ] || eprintln 'undefined env BITCOIN_USER'
	! [ -z "${BITCOIN_PASSWORD}" ] || eprintln 'undefined env BITCOIN_PASSWORD'
	! [ -z "${BITCOIN_PRUNE}" ] || eprintln 'undefined env BITCOIN_PRUNE'
	! [ -z "${TXINDEX}" ] || eprintln 'undefined env TXINDEX'
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
	[ -e "${RELDIR}/containers/bitcoind/volume/data/bitcoinData/.bitcoin" ] \
	|| return 0
	printf "Detected older version, migrate data? (Y/n): "
	read input
	[ "${input}" == "Y" ] || eprintln "ABORT!"
	printf "This process must not be interrupted!\n"
	mv \
	${RELDIR}/containers/bitcoind/volume/data/bitcoinData/.bitcoin \
	${RELDIR}/data/
	rm -rf ${RELDIR}/containers
	printf "Migration done!\n"
	sleep 5
}
common(){
	check_env
	set_scripts_permissions
	mkdirs
}
build(){
	podman build \
		-f Containerfile \
		--tag="${IMG_NAME}" \
		${RELDIR}
}
mk_systemd() {
	! [ -e "/etc/systemd/system/${CT_NAME}.service" ] \
		|| eprintln "service ${CT_NAME} already exists"
	local user="${USER}"
	sudo bash -c "cat << EOF > /etc/systemd/system/${CT_NAME}.service
[Unit]
Description=Bitcoind Pod
After=network.target

[Service]
Environment=\"PATH=/usr/local/bin:/usr/bin:/bin:${PATH}\"
User=${user}
Type=forking
ExecStart=/bin/bash -c \"cd ${PWD}/${RELDIR}; ./control.sh up\"
ExecStop=/bin/bash -c \"cd ${PWD}/${RELDIR}; ./control.sh down\"
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
"
	sudo systemctl enable "${CT_NAME}".service
	printf "To start the service, run: sudo systemctl start "${CT_NAME}".service\n"
}
rm_systemd() {
	[ -e "/etc/systemd/system/${CT_NAME}.service" ] || return 0
	sudo systemctl stop "${CT_NAME}".service || true
	sudo systemctl disable "${CT_NAME}".service
	sudo rm /etc/systemd/system/"${CT_NAME}".service
}
up(){
	migrate_from_v0_2_0
	podman run --rm \
		-p=${CT_MAINNET_PORT}:8332 \
		-p=${CT_TESTNET_PORT}:18332 \
		-p=${CT_REGTEST_PORT}:18443 \
		-p=${CT_ZMQ_PORT}:28332 \
		--env-file="${RELDIR}/.env" \
		-v=${RELDIR}:/app \
		-v="${RELDIR}/data:/data" \
		-v="${BITCOIN_CHAINSTATE_DIR:-${RELDIR}/data/.bitcoin/chainstate}:/data/.bitcoin/chainstate" \
		--name="${CT_NAME}" \
		"localhost/${IMG_NAME}" &
}
down(){
	podman exec ${CT_NAME} /app/scripts/bitcoind/shutdown.sh || true
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
common
case ${1} in
	build) build ;;
	up) up ;;
	down) down ;;
	clean) clean ;;
	mk-systemd) mk_systemd ;;
	rm-systemd) rm_systemd ;;
	bitcoin-cli) bitcoin-cli "${2}" ;;
	*) eprintln "${HELP_MSG}" ;;
esac
