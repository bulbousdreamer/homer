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

for afile in "${@}"; do
  "$(cygpath --unix --absolute "${exe}")" \
    "$(cygpath --mixed --absolute "${afile}")" &
done
