#!/usr/bin/env bash
####################
set -e
####################
readonly CFG_DIR="${HOME}/.bitcoin"
readonly CFG_FILE="${CFG_DIR}/bitcoin.conf"
readonly BASE_CFG_DIR='/app/config'
readonly CFG_SAMP_DIR='/app/config/examples'
readonly BITCOIN_DATA_PATH='/app/data/bitcoinData/.bitcoin'
####################
create_directories(){
  mkdir -p ${CFG_DIR}
  mkdir -p ${BITCOIN_DATA_PATH}
}
copy_base_cfg(){
  if [ -e "${BASE_CFG_DIR}/${BITCOIN_NETWORK}.conf" ]; then return 0; fi
  case ${BITCOIN_NETWORK} in
    mainnet) cat ${CFG_SAMP_DIR}/mainnet > ${BASE_CFG_DIR}/mainnet.conf ;;
    testnet) cat ${CFG_SAMP_DIR}/testnet > ${BASE_CFG_DIR}/testnet.conf ;;
    regtest) cat ${CFG_SAMP_DIR}/regtest > ${BASE_CFG_DIR}/regtest.conf ;;
    *) printf 'Unknown bitcoin network\n' 1>&2; return 1 ;;
  esac
}
copy_cfg(){
  case ${BITCOIN_NETWORK} in
    mainnet) cat /app/config/mainnet.conf > ${CFG_FILE} ;;
    testnet) cat /app/config/testnet.conf > ${CFG_FILE} ;;
    regtest) cat /app/config/regtest.conf > ${CFG_FILE} ;;
    *) printf 'Unknown bitcoin network\n' 1>&2; return 1 ;;
  esac
}
set_config(){
  if [ -z ${1} ] || [ -z ${2} ]; then
    printf "Expected: [key] [value]\n" 1>&2; return 1
  fi
  local key="${1}"
  local value="${2}"
  if ! grep '^'${key}'=.*$' ${CFG_FILE} > /dev/null; then
    echo "${key}=${value}" >> ${CFG_FILE}
  else
    sed -i'.old' -e 's/^'${key}'=.*$/'${key}=${value}'/g' ${CFG_FILE}
  fi
}
set_tor(){
  if echo "${TOR_PROXY}" | grep '^enabled$' > /dev/null; then
    set_config "onlynet" "onion"
    set_config "proxy" "127.0.0.1:9050"
  fi
}
set_auth(){
  set_config "rpcuser" "${BITCOIN_USER}"
  set_config "rpcpassword" "${BITCOIN_PASSWORD}"
}
####################
create_directories
copy_base_cfg
copy_cfg
set_tor
set_auth


