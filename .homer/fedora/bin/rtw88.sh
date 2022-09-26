#!/usr/bin/bash

# git clone git@github.com:lwfinger/rtw88.git
cd "${HOME}/git/rtw88"
git pull
make
sudo make install
