# homer_debug=
if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.profile"; fi

export HOMER_OS_TYPE=

. "${HOME}/.homer/get_os_type.sh"

. "${HOME}/.homer/${HOMER_OS_TYPE}/profile"
. "${HOME}/.bash_profile"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.profile"; fi