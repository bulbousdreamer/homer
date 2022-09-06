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
vimdiff "${old_file}" "${new_file}"