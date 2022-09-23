# export HOMER_DEBUG=
if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Enter ${HOME}/.profile"; fi

. "${HOME}/.homer/get_os_type.sh"

. "${HOME}/.homer/${HOMER_OS_TYPE}/profile"
. "${HOME}/.bash_profile"

if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Exit ${HOME}/.profile"; fi
