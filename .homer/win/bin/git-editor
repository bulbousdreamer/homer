#!/usr/bin/bash

exe=

if [ -f "C:/Program Files/Notepad++/notepad++.exe" ]; then
  exe="C:/Program Files/Notepad++/notepad++.exe"
elif [ -f "C:/Program Files (x86)/Notepad++/notepad++.exe" ]; then
  exe="C:/Program Files (x86)/Notepad++/notepad++.exe"
else
  printf 'ERROR: Cannot find Notepad++. Exiting.\n'
  exit 1
fi

"$(cygpath --unix --absolute "${exe}")" \
  -multiInst \
  -notabbar \
  -nosession \
  -noPlugin \
  "$(cygpath --mixed --absolute "${1}")"
