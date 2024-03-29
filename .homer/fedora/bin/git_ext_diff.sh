#!/usr/bin/bash -u
if [ ! -z ${HOMER_DEBUG+x} ]; then set -x; fi

path="${1}"
old_file="${2}"
old_hex="${3}"
old_mode="${4}"
new_file="${5}"
new_hex="${6}"
new_mode="${7}"

# If the files are the same, do not open them in the bc4 GUI
# TODO test filemode too or know that this is for content-only diffs?
if cmp --silent "${old_file}" "${new_file}"; then
    exit 0
fi

bcompare  "${old_file}" "${new_file}"

return_status=$?

if [ ${return_status} -lt 100 ]; then
    exit 0
else
    exit 1
fi
