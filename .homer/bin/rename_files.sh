#!/usr/bin/bash

things=()
while IFS= read -d '' -r; do
	things+=("${REPLY}")
done < <(git ls-files --full-name -z -- **/bin/**)

for thing in "${things[@]}"; do
	[[ "$thing" = *-* ]] && mv --no-clobber --verbose -- "$thing" "${thing//-/_}"
done
