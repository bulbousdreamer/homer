#!/usr/bin/bash

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

# If one of the files is /dev/null, use an empty file so bc4 does not error
# TODO: Should there be more if statements to check filemode?
if [ "${old_file}" == "/dev/null" ]; then
    "${old_file}" = "${HOMER}/.homer/${HOMER_OS_TYPE}/null_file"
fi

if [ "${new_file}" == "/dev/null" ]; then
    "${new_file}" = "${HOMER}/.homer/${HOMER_OS_TYPE}/null_file"
fi

# Open the GUI
"$(cygpath --unix --absolute "C:/Program Files/Beyond Compare 4/BComp.exe")" \
    /silent \
    /solo \
    "$(cygpath --mixed --absolute "${old_file}")" \
    "$(cygpath --mixed --absolute "${new_file}")"

return_status=$?

if [ ${return_status} -lt 100 ]; then
    exit 0
else
    exit 1
fi
