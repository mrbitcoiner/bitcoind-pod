#!/usr/bin/env bash
####################
set -e
####################
readonly CONTAINERS=("bitcoind")
readonly NETWORK="bitcoin"
####################
create_dirs(){
  for i in in "${CONTAINERS[@]}"; do
    mkdir -p containers/bitcoind/volume/data
  done
}
set_scripts_permissions(){
  for i in in "${CONTAINERS[@]}"; do
    local scripts_path="./containers/${i}/volume/scripts"
    if [ -e ${scripts_path}/init.sh ]; then
	    chmod +x containers/${i}/volume/scripts/*.sh
    fi
  done
}
create_network(){
	if ! docker network ls | grep "${NETWORK}" > /dev/null; then
	    docker network create -d bridge ${NETWORK}
	fi
}
build_images(){
  docker-compose build \
    --build-arg $(grep '^BITCOIN_NETWORK=.*$' .env) \
    --build-arg $(grep '^TOR_PROXY=.*$' .env) \
    --build-arg $(grep '^HOST_UID=.*$' .env) \
    --build-arg $(grep '^HOST_GID=.*$' .env) \
    --build-arg $(grep '^CONTAINER_USER=.*$' .env) \
    --build-arg $(grep '^BITCOIN_USER=.*$' .env) \
    --build-arg $(grep '^BITCOIN_PASSWORD=.*$' .env)
}
start_containers(){
	docker-compose up \
    --remove-orphans &
}
copy_dotenv(){
  if ! [ -e .env ]; then
    cp .env.example .env
  fi
}
env_set(){
  if [ -z ${1} ] || [ -z ${2} ]; then
    printf "Expected: [key] [value]\n" 1>&2; return 1
  fi
  local key="${1}"
  local value="${2}"
  if ! grep '^'${key}'=.*$' .env > /dev/null; then
    echo "${key}=${value}" >> .env
  else
    sed -i'.old' -e 's/^'${key}'=.*$/'${key}=${value}'/g' .env
  fi
}
set_bitcoin_network(){
	case "${1}" in
		mainnet) env_set "BITCOIN_NETWORK" "mainnet" ;;
    testnet) env_set "BITCOIN_NETWORK" "testnet" ;; 
		regtest) env_set "BITCOIN_NETWORK" "regtest" ;;
		*) printf 'Expected network: [ mainnet | testnet | regtest ]\n' 1>&2; return 1 ;;
	esac
}
set_tor_proxy(){
  local tor="${1}"
  case ${tor} in
    enabled) env_set "TOR_PROXY" "enabled" ;;
    disabled) env_set "TOR_PROXY" "disabled" ;;
    *) printf 'Expected tor proxy: [ enabled | disabled ]\n' 1>&2; return 1 ;;
  esac
}
set_uid_gid(){
  env_set "HOST_UID" "$(id -u)"
  env_set "HOST_GID" "$(id -g)"
}
####################
setup(){
  local environment=${1}
  local tor_proxy=${2}
  copy_dotenv
  set_bitcoin_network "${environment}"
  set_tor_proxy "${tor_proxy}"
  set_uid_gid
  create_network
	create_dirs
	set_scripts_permissions
  build_images
  start_containers
}
teardown(){
  for i in "${CONTAINERS[@]}"; do
    docker exec -it ${i} gracefully_shutdown shutdown
  done
  docker-compose down
}
clean(){
  printf 'Are you sure? (Y/any): '
  read input
  if ! echo "${input}" | grep '^Y$' > /dev/null; then
    printf "Aborted!\n"; return 1
  fi
  for i in "${CONTAINERS[@]}"; do
    local data_path="./containers/${i}/volume/data"
    if [ -e ${data_path} ]; then
      rm -rfv ${data_path}
    fi
  done
	printf 'Cleaned\n'
}
####################
case "${1}" in
	up) setup "${2}" "${3}" ;;
	down) teardown ;;
	clean) clean ;;
	*) printf 'Usage: [ up | down | clean | help ]\n' ;;
esac	

