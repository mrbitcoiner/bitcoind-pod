#!/usr/bin/env bash
####################
set -e
####################
shutdown_bitcoind(){
  su -c 'bitcoin-cli stop' ${CONTAINER_USER}
}
install(){
  ln -sf /app/scripts/gracefully_shutdown.sh /usr/bin/gracefully_shutdown
}
####################
case ${1} in
  install) install ;;
  shutdown) shutdown_bitcoind ;;
  *) printf 'Expected: [ install | shutdown ]\n' 1>&2; exit 1;
esac
