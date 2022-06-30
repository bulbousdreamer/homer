if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.bash_completion.bash"; fi

. "${HOME}/.homer/${HOMER_OS_TYPE}/bash_completion.bash"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.bash_completion.bash"; fi
