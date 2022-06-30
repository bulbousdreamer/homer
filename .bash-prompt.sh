if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.bash_prompt.sh"; fi

. "${HOME}/.homer/${HOMER_OS_TYPE}/bash_prompt.sh"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.bash_prompt.sh"; fi
