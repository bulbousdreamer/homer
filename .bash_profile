# homer_debug=

if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.bash_profile"; fi

export HOMER_GIT_DIR="${HOME}/git/homer/.bare"
export HOMER_OS_TYPE=

case $( uname -o ) in
Cygwin)
  HOMER_OS_TYPE=cyg
  ;;
Msys)
  HOMER_OS_TYPE=win
  ;;
*)
  echo "Unknown OS detected in ${HOME}/.bash_profile"
  exit 1
  ;;
esac

. "${HOME}/.homer/${HOMER_OS_TYPE}/bash_profile"

if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.bash_profile"; fi
