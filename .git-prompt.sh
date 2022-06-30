if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.git-prompt.sh"; fi

. "${HOME}/.homer/${HOMER_OS_TYPE}/git-prompt.sh"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.git-prompt.sh"; fi
