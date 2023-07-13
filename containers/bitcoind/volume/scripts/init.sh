#!/usr/bin/env bash
####################
set -e
####################
su -c '/app/scripts/bitcoind_build.sh' ${CONTAINER_USER}
/app/scripts/gracefully_shutdown.sh install
if echo "${TOR_PROXY}" | grep '^enabled$' > /dev/null; then
  printf 'Starting tor\n'
  sleep 1
  su -c 'tor > /dev/null &' ${CONTAINER_USER}
fi
su -c '/app/scripts/bitcoind_setup.sh' ${CONTAINER_USER}
su -c 'bitcoind' ${CONTAINER_USER}
