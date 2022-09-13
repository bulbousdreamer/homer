if [ "${HOMER_OS_TYPE}" == "unk" ]; then
  echo "Unknown OS detected in ${HOME}/.bashrc"
else
  . "${HOME}/.homer/${HOMER_OS_TYPE}/bashrc"
fi
