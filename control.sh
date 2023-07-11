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
  chmod +x ./scripts/*.sh
}
create_network(){
	if ! docker network ls | awk '{print $2}' | grep "^${NETWORK}$" > /dev/null; then
	  docker network create -d bridge ${NETWORK}
	fi
}
build_images(){
  docker-compose build \
    --build-arg CONTAINER_USER=${USER} \
    --build-arg CONTAINER_UID=$(id -u) \
    --build-arg CONTAINER_GID=$(id -g) \
    --build-arg $(get_env BITCOIN_NETWORK) \
    --build-arg $(get_env BITCOIN_PRUNE) \
    --build-arg $(get_env TOR_PROXY) \
    --build-arg $(get_env BITCOIN_USER) \
    --build-arg $(get_env BITCOIN_PASSWORD)
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
  ./scripts/set_dotenv.sh '.env' ${1} ${2}
}
####################
setup(){
	set_scripts_permissions
  copy_dotenv
  create_network
	create_dirs
  build_images
  start_containers
}
gracefully_shutdown(){
  for i in "${CONTAINERS[@]}"; do
    docker exec ${i} gracefully_shutdown shutdown
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
  docker exec -it ${BITCOIND_CONTAINER} su -c 'bitcoin-cli '"${command}"'' ${USER}
} 
####################
case "${1}" in
	up) setup ;;
	down) teardown ;;
	clean) clean ;;
  cli_wrapper) cli_wrapper "${2}" ;;
  nop) ;;
	*) printf 'Usage: [ up | down | cli_wrapper | clean | help ]\n' ;;
esac	

