if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.profile"; fi

. "${HOME}/.homer/${HOMER_OS_TYPE}/bash_profile"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.profile"; fi
