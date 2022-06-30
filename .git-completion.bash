if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.git_completion.bash"; fi

. "${HOME}/.homer/${HOMER_OS_TYPE}/git_completion.bash"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.git_completion.bash"; fi
