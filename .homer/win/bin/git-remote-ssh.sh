#!/usr/bin/bash

repos=()
while IFS= read -d '' -r; do
	repos+=("${REPLY}")
done < <(find "${HOME}/git" -mindepth 1 -maxdepth 1 -type d -print0)

for repo in "${repos[@]}"; do
	case "$(basename "${repo}")" in
	*)
		new_url="$(git -C "${repo}" config --get remote.origin.url | sed 's/https:/ssh:/')"
		git -C "${repo}" remote set-url origin "${new_url}"
		git -C "${repo}" submodule sync
	;;
	esac
done
