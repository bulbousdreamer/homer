# homer_debug=
if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.bashrc"; fi

. "${HOME}/.homer/get_os_type.sh"

. "${HOME}/.homer/${HOMER_OS_TYPE}/bashrc"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.bashrc"; fi