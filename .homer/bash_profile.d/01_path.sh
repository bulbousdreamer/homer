# OS-specific script will be found before the generic script
# This way OS's can use the generic script until customization
# is necessary. Just create a script in their bin.
echo "Doing the path"
export PATH="${HOME}/.homer/${HOMER_OS_TYPE}/bin${PATH:+:${PATH}}"
export PATH="${HOME}/.homer/bin${PATH:+:${PATH}}"
