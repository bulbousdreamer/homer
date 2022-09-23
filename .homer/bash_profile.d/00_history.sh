# History Options
#
# Don't put duplicate lines in the history and ignore commands beginning with space
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoreboth
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"
export HISTFILE="${HOME}/.homer/${HOMER_OS_TYPE}/history/${HOSTNAME}"

export HISTSIZE=5000

# Append history to HISTFILE when PROMPT displays
export PROMPT_COMMAND="history -an"

# Make bash append rather than overwrite the history on disk
shopt -s histappend
