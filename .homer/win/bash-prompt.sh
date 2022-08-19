case $( uname -o ) in
Cygwin)
  . "${HOME}/.homer/cyg/bashrc"
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

