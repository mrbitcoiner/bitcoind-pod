#!/usr/bin/env bash
####################
set -e
####################
readonly BITCOIND_CONTAINER='bitcoind'
readonly CONTAINERS=("${BITCOIND_CONTAINER}")
readonly NETWORK='bitcoin'
####################
create_dirs(){
  for i in in "${CONTAINERS[@]}"; do
    mkdir -p containers/bitcoind/volume/data
  done
}
get_env(){
  local FILE_PATH='.env'
  if [ -z "${1}" ]; then printf 'Expected key\n' 1>&2; return 1; fi
  local key="${1}"
  if ! [ -e "${FILE_PATH}" ]; then printf "File ${FILE_PATH} not found\n" 1>&2; return 1; fi
  if ! grep '^'${key}'=.*$' ${FILE_PATH} > /dev/null; then printf 'Key not found in file' 1>&2; return 1; fi
  printf "$(grep '^'${key}'=.*$' ${FILE_PATH})"
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
    --build-arg $(get_env BITCOIN_NETWORK) \
    --build-arg $(get_env TOR_PROXY) \
    --build-arg $(get_env HOST_UID) \
    --build-arg $(get_env HOST_GID) \
    --build-arg $(get_env CONTAINER_USER) \
    --build-arg $(get_env BITCOIN_USER) \
    --build-arg $(get_env BITCOIN_PASSWORD) \
    --build-arg $(get_env BITCOIN_NETWORK)
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
		mainnet) env_set "BITCOIN_NETWORK" ${1} ;;
    testnet) env_set "BITCOIN_NETWORK" ${1} ;; 
		regtest) env_set "BITCOIN_NETWORK" ${1} ;;
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
gracefully_shutdown(){
  for i in "${CONTAINERS[@]}"; do
    docker exec -it ${i} gracefully_shutdown shutdown
  done
}
still_running(){
  some_running=false
  for i in "${CONTAINERS[@]}"; do
    if docker ps -f name=${i} | grep '^.*   '${i}'$' > /dev/null; then
      some_running=true
      return 0
    fi
  done
  ${some_running}
}
teardown(){
  gracefully_shutdown || true
  local counter=0
  local max=60
  printf "\n"
  while [ "${counter}" -le "${max}" ]; do
    if still_running; then
      printf "\rWaiting gracefully_shutdown ${counter}/${max}s"
      counter=$((${counter} + 1))
      sleep 1
    else
      break
    fi
  done
  printf "\n"
  docker-compose down
}
clean(){
  printf 'Are you sure? (Y/n): '
  read input
  if ! echo "${input}" | grep '^Y$' > /dev/null; then
    printf "Abort!\n"; return 1
  fi
  for i in "${CONTAINERS[@]}"; do
    local data_path="./containers/${i}/volume/data"
    if [ -e ${data_path} ]; then
      rm -rfv ${data_path}
    fi
  done
	printf 'Cleaned\n'
}
cli_wrapper(){
  if [ -z "${1}" ]; then printf 'Expected: [ command ]\n' 1>&2; return 1; fi
  local command="${1}"
  local "$(get_env 'CONTAINER_USER')"
  docker exec -it ${BITCOIND_CONTAINER} su -c 'bitcoin-cli '"${command}"'' ${CONTAINER_USER}
} 
####################
case "${1}" in
	up) setup "${2}" "${3}" ;;
	down) teardown ;;
	clean) clean ;;
  cli_wrapper) cli_wrapper "${2}" ;;
  nop) ;;
	*) printf 'Usage: [ up | down | cli_wrapper | clean | help ]\n' ;;
esac	

