export HOMER_GIT_DIR="${HOME}/git/homer/.bare"
export HOMER_OS_TYPE=

case $( uname -o ) in
Cygwin)
  HOMER_OS_TYPE=cyg
  ;;
*Linux)
  HOMER_OS_TYPE=lin
  ;;
Msys)
  HOMER_OS_TYPE=win
  ;;
*)
  echo "Unknown OS detected in ${HOME}/.profile"
  HOMER_OS_TYPE=unk
  ;;
esac

. "${HOME}/.homer/${HOMER_OS_TYPE}/.profile"


