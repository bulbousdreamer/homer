if [ ! -z ${homer_debug+x} ]; then echo "Enter .profile"; fi

. "${HOME}/.bash_profile"

if [ ! -z ${homer_debug+x} ]; then echo "Exit .profile"; fi
