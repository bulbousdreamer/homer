#!/usr/bin/bash -x
set -u

# https://mywiki.wooledge.org/BashGuide/Arrays

# Set name and email in each repo
# This is at least convenient while developing the homer repo
# Sick of rebasing
# TODO: Account for submodules

repos=()
while IFS= read -d '' -r; do
	repos+=("${REPLY}")
done < <(find "${HOME}/git" -mindepth 1 -maxdepth 1 -type d -print0)

for repo in "${repos[@]}"; do
	git -C "${repo}" config --local user.name "${1}"
	git -C "${repo}" config --local user.email "${2}"

	git -C "${repo}" submodule foreach "git config --local user.name \"${1}\""
	git -C "${repo}" submodule foreach "git config --local user.email \"${2}\""
done
