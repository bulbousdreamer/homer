# export HOMER_DEBUG=
if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Enter ${HOME}/.homer/bash_profile.d/02_shopt.sh"; fi

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# Help with line wrapping hopefully
shopt -s checkwinsize

if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Exit ${HOME}/.homer/bash_profile.d/02_shopt.sh"; fi