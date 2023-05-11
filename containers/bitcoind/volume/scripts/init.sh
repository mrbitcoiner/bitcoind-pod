#!/usr/bin/env bash
####################
set -e
####################

chown -R ${CONTAINER_USER} /app

su -c '/scripts/bitcoind_build.sh' ${CONTAINER_USER}

if echo "${TOR_PROXY}" | grep '^enabled$' > /dev/null; then
  su -c 'tor &' ${CONTAINER_USER}
fi

su -c '/app/scripts/bitcoind_setup.sh' ${CONTAINER_USER}

su -c 'bitcoind' ${CONTAINER_USER}
