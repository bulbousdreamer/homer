export HOMER_DEBUG=
if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Enter ${HOME}/.bash_profile"; fi

. "${HOME}/.homer/get_os_type.sh"

# https://github.com/detro/.bashrc.d
# Source common settings for all OS's
bash_profiles=()
while IFS= read -d '' -r; do
	bash_profiles+=("${REPLY}")
done < <(find "${HOME}/.homer/bash_profile.d" -mindepth 1 -maxdepth 1 -type f -name *.sh -print0)

for bash_profile in "${bash_profiles[@]}"; do
  . "${bash_profile}"
done

. "${HOME}/.homer/${HOMER_OS_TYPE}/bash_profile"

. "${HOME}/.bashrc"

if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Exit ${HOME}/.profile"; fi
