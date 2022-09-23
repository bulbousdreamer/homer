# export HOMER_DEBUG=
if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Enter ${HOME}/.bash_logout"; fi

. "${HOME}/.homer/get_os_type.sh"

. "${HOME}/.homer/${HOMER_OS_TYPE}/bash_logout"

if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Exit ${HOME}/.bash_logout"; fi
