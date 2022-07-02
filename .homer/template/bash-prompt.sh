# homer_debug=

if [ ! -z ${homer_debug+x} ]; then echo "Enter ${HOME}/.bashrc"; fi

case $( uname -o ) in
Cygwin)
  . "${HOME}/.homer/${HOMER_OS_TYPE}/bashrc"
  ;;
Linux)
  . "${HOME}/.homer/lin/bashrc"
  ;;
Msys)
  . "${HOME}/.homer/win/bashrc"
  ;;
*)
  echo "Unknown OS detected in ${HOME}/.bashrc"
  ;;
esac

. "${HOME}/.bash_aliases"
. "${HOME}/.bash_functions"


if [ ! -z ${homer_debug+x} ]; then echo "Exit ${HOME}/.bashrc"; fi
