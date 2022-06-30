if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.bash_functions"; fi

. "${HOME}/.homer/${HOMER_OS_TYPE}/bash_functions"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.bash_functions"; fi
