if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.bash_aliases"; fi

. "${HOME}/.homer/${HOMER_OS_TYPE}/bash_aliases"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.bash_aliases"; fi
