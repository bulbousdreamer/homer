#!/usr/bin/bash

path="${1}"
old_file="${2}"
old_hex="${3}"
old_mode="${4}"
new_file="${5}"
new_hex="${6}"
new_mode="${7}"

vimdiff "${old_file}" "${new_file}"

exit 0

