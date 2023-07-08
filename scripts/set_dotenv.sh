#!/usr/bin/env bash
####################
set -e
####################
readonly FILE_PATH="${1}"
readonly KEY="${2}"
readonly VALUE="${3}"
####################
check_input(){
  if [ -z "${FILE_PATH}" ] || [ -z "${KEY}" ] || [ -z "${VALUE}" ]; then printf 'Expected: [FILE_PATH] [KEY] [VALUE]\n' 1>&2; return 1; fi
}
key_exists(){
  if ! [ -e ${FILE_PATH} ]; then printf "File ${FILE_PATH} does not exist\n" 1>&2; return 1; fi
  grep '^'${KEY}'=.*$' ${FILE_PATH} > /dev/null
}
append_key_value(){
  cat << EOF >> ${FILE_PATH}
${KEY}=${VALUE}
EOF
}
replace_value(){
  sed -i'.old' -e 's/^'${KEY}'=.*$/'${KEY}'='${VALUE}'/' ${FILE_PATH}
}
set(){
  if ! key_exists; then
    append_key_value
  else
    replace_value
  fi
}
####################
check_input
set
