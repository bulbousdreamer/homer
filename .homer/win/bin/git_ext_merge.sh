#!/usr/bin/bash

local_file="${1}"
remote_file="${2}"
base_file="${3}"
merged_file="${4}"

"$(cygpath --unix --absolute "C:/Program Files/Beyond Compare 4/BComp.exe")" \
  "$(cygpath --mixed --absolute "${local_file}")" \
  "$(cygpath --mixed --absolute "${remote_file}")" \
  "$(cygpath --mixed --absolute "${base_file}")" \
  /mergeoutput="$(cygpath --mixed --absolute "${merged_file}")"

return_status=$?

if [ ${return_status} -lt 100 ]; then
    exit 0
else
    exit 1
fi
