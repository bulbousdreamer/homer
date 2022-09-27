# export HOMER_DEBUG=
if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Enter ${HOME}/.homer/bash_profile.d/01_path.sh"; fi

# OS-specific script will be found before the generic script
# This way OS's can use the generic script until customization
# is necessary. Just create a script in their bin.
export PATH="${HOME}/.homer/bin${PATH:+:${PATH}}"
export PATH="${HOME}/.homer/${HOMER_OS_TYPE}/bin${PATH:+:${PATH}}"

if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Exit ${HOME}/.homer/bash_profile.d/01_path.sh"; fi