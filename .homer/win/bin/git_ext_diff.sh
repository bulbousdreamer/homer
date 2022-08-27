#!/usr/bin/bash

path="${1}"
old_file="${2}"
old_hex="${3}"
old_mode="${4}"
new_file="${5}"
new_hex="${6}"
new_mode="${7}"

"$(cygpath --unix --absolute "C:/Program Files/Beyond Compare 4/BComp.exe")" \
    "$(cygpath --mixed --absolute "${old_file}")" \
    "$(cygpath --mixed --absolute "${new_file}")"

return_status=$?

if [ ${return_status} -lt 100 ]; then
    exit 0
# 100 is an Unknown Error code, but it only seems to appear when a /dev/null is passed in
# Hint: see `git help git` and `export GIT_TRACE=1`` to see the inputs to this script when calling `git diff`
elif [ ${return_status} -eq 100 ] && { [ "${old_file}" == "/dev/null" ] || [ "${new_file}" == "/dev/null" ]; }; then
    exit 0
else
    exit 1
fi
