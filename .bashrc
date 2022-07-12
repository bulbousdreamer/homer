# homer_debug=

if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.bashrc"; fi

. "${HOME}/.homer/${HOMER_OS_TYPE}/bashrc"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.bashrc"; fi
