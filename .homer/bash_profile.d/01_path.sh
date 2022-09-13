# OS-specific script will be found before the generic script
# This way OS's can use the generic script until customization
# is necessary. Just create a script in their bin.
PATH="${HOME}/.homer/${HOMER_OS_TYPE}/bin${PATH:+:${PATH}}"
PATH="${HOME}/.homer/bin${PATH:+:${PATH}}"
export PATH