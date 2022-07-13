#!/usr/bin/bash

# https://mywiki.wooledge.org/BashFAQ/035
# https://mywiki.wooledge.org/ComplexOptionParsing
# https://mywiki.wooledge.org/Arguments

branches=()
remote=origin
repo=
url=

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

show_help() {
    printf 'Configure remote url and other settings. Useful for a shared repository of personal branches like homer.\n'
    printf 'fix-remote.sh --repo=<path to git directory> --remote=<name of remote, usually "origin"> --url=<URL of remote repository> --branches=<comma separated list of branches to track>'
}

while :; do
    case ${1} in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        --branches=?*)
            # Delete everything up to "=" and split the remainder.
            IFS=, read -ra branches <<< "${1#*=},"
            ;;
        --branches=)         # Handle the case of an empty --file=
            die 'ERROR: "--branches=" requires a non-empty option argument.'
            ;;
        --remote=?*)
            remote=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --remote=)         # Handle the case of an empty --file=
            die 'ERROR: "--remote" requires a non-empty option argument.'
            ;;
        --repo=?*)
            repo=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --repo=)         # Handle the case of an empty --file=
            die 'ERROR: "--repo" requires a non-empty option argument.'
            ;;
        --url=?*)
            url=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --url=)         # Handle the case of an empty --file=
            die 'ERROR: "--url" requires a non-empty option argument.'
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'ERROR: Unknown option: %s\n' "$1" >&2
            exit 1
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

[ -d "${repo}" ] || die 'ERROR: --repo ${repo} does not exist'
[[ -z "${url}" ]] && die 'ERROR: --url is empty'
[[ -z "${remote}" ]] && die 'ERROR: --remote is empty'
[[ -z "${branches[0]}" ]] && die 'ERROR: --branches is empty'

git -C "${repo}" remote set-url "${remote}" "${url}"
git -C "${repo}" remote set-branches "${remote}" "${branches[0]}"
unset ${branches[0]}

for ref in "${refs[@]}"; do
    git -C "${repo}" remote set-branches --add "${remote}" "${branch}"
done
