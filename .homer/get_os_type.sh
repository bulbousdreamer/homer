if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Enter ${HOME}/.homer/get_os_type.sh"; fi

if [ -z ${HOMER_OS_TYPE+x} ]; then
    export HOMER_OS_TYPE

    case $( uname -o ) in
    Cygwin)
    HOMER_OS_TYPE=cyg
    ;;
    *Linux)
    # https://unix.stackexchange.com/a/6348
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        HOMER_OS_TYPE="${ID}"
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        HOMER_OS_TYPE=$(lsb_release -si)
        ver=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        HOMER_OS_TYPE=$DISTRIB_ID
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        HOMER_OS_TYPE=Debian
    elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        HOMER_OS_TYPE=lin
    elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        HOMER_OS_TYPE=lin
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        HOMER_OS_TYPE=lin
    fi
    ;;
    Msys)
        HOMER_OS_TYPE=win
    ;;
    *)
        HOMER_OS_TYPE=unk
    ;;
    esac
fi

if [ ! -z ${HOMER_DEBUG+x} ]; then echo "Exit ${HOME}/.homer/get_os_type.sh"; fi
