#                                                          -*- shell-script -*-
#
#   bash_completion - programmable completion functions for bash 4.2+
#
#   Copyright © 2006-2008, Ian Macdonald <ian@caliban.org>
#             © 2009-2020, Bash Completion Maintainers
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2, or (at your option)
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#   The latest version of this software can be obtained here:
#
#   https://github.com/scop/bash-completion

BASH_COMPLETION_VERSINFO=(2 11 0)

if [[ $- == *v* ]]; then
    _comp__init_original_set_v="-v"
else
    _comp__init_original_set_v="+v"
fi

if [[ ${BASH_COMPLETION_DEBUG-} ]]; then
    set -v
else
    set +v
fi

# Turn on extended globbing and programmable completion
shopt -s extglob progcomp

# Declare a compatibility function name
# @param $1 Old function name
# @param $2 New function name
_comp_deprecate_func()
{
    if [[ $1 != [a-zA-Z_]*([a-zA-Z_0-9]) ]]; then
        printf 'bash_completion: %s: %s\n' "$FUNCNAME" "\$1: invalid function name '$1'" >&2
        return 2
    elif [[ $2 != [a-zA-Z_]*([a-zA-Z_0-9]) ]]; then
        printf 'bash_completion: %s: %s\n' "$FUNCNAME" "\$2: invalid function name '$2'" >&2
        return 2
    fi
    eval -- "$1() { $2 \"\$@\"; }"
}

# A lot of the following one-liners were taken directly from the
# completion examples provided with the bash 2.04 source distribution

# start of section containing compspecs that can be handled within bash

# user commands see only users
complete -u groups slay w sux

# bg completes with stopped jobs
complete -A stopped -P '"%' -S '"' bg

# other job commands
complete -j -P '"%' -S '"' fg jobs disown

# readonly and unset complete with shell variables
complete -v readonly unset

# set completes with set options
complete -A setopt set

# shopt completes with shopt options
complete -A shopt shopt

# helptopics
complete -A helptopic help

# unalias completes with aliases
complete -a unalias

# type and which complete on commands
complete -c command type which

# builtin completes on builtins
complete -b builtin

# start of section containing completion functions called by other functions

# Check if we're running on the given userland
# @param $1 userland to check for
_comp_userland()
{
    local userland=$(uname -s)
    [[ $userland == @(Linux|GNU/*) ]] && userland=GNU
    [[ $userland == "$1" ]]
}

_comp_deprecate_func _userland _comp_userland

# This function sets correct SysV init directories
#
_comp_sysvdirs()
{
    sysvdirs=()
    [[ -d /etc/rc.d/init.d ]] && sysvdirs+=(/etc/rc.d/init.d)
    [[ -d /etc/init.d ]] && sysvdirs+=(/etc/init.d)
    # Slackware uses /etc/rc.d
    [[ -f /etc/slackware-version ]] && sysvdirs=(/etc/rc.d)
    return 0
}

_comp_deprecate_func _sysvdirs _comp_sysvdirs

# This function checks whether we have a given program on the system.
#
_comp_have_command()
{
    # Completions for system administrator commands are installed as well in
    # case completion is attempted via `sudo command ...'.
    PATH=$PATH:/usr/sbin:/sbin:/usr/local/sbin type $1 &>/dev/null
}

_comp_deprecate_func _have _comp_have_command

# Backwards compatibility for compat completions that use have().
# @deprecated should no longer be used; generally not needed with dynamically
#             loaded completions, and _comp_have_command is suitable for runtime use.
have()
{
    unset -v have
    _comp_have_command $1 && have=yes
}

# This function checks whether a given readline variable
# is `on'.
#
_comp_readline_variable_on()
{
    [[ $(bind -v) == *$1+([[:space:]])on* ]]
}

_comp_deprecate_func _rl_enabled _comp_readline_variable_on

# This function shell-quotes the argument
# @param    $1  String to be quoted
# @var[out] ret Resulting string
_comp_quote()
{
    ret=\'${1//\'/\'\\\'\'}\'
}

# This function shell-quotes the argument
# @deprecated Use `_comp_quote` instead.  Note that `_comp_quote` stores
#   the results in the variable `ret` instead of writing them to stdout.
quote()
{
    local quoted=${1//\'/\'\\\'\'}
    printf "'%s'" "$quoted"
}

# @see _quote_readline_by_ref()
quote_readline()
{
    local ret
    _quote_readline_by_ref "$1" ret
    printf %s "$ret"
} # quote_readline()

# shellcheck disable=SC1003
_comp_dequote__initialize()
{
    unset -f "$FUNCNAME"
    local regex_param='\$([_a-zA-Z][_a-zA-Z0-9]*|[-*@#?$!0-9_])|\$\{[!#]?([_a-zA-Z][_a-zA-Z0-9]*(\[([0-9]+|[*@])\])?|[-*@#?$!0-9_])\}'
    local regex_quoted='\\.|'\''[^'\'']*'\''|\$?"([^\"$`!]|'$regex_param'|\\.)*"|\$'\''([^\'\'']|\\.)*'\'''
    _comp_dequote__regex_safe_word='^([^\'\''"$`;&|<>()!]|'$regex_quoted'|'$regex_param')*$'
}
_comp_dequote__initialize

# This function expands a word using `eval` in a safe way.  This function can
# be typically used to get the expanded value of `${word[i]}` as
# `_comp_dequote "${word[i]}"`.  When the word contains unquoted shell special
# characters, command substitutions, and other unsafe strings, the function
# call fails before applying `eval`.  Otherwise, `eval` is applied to the
# string to generate the result.
#
# @param    $1  String to be expanded.  A safe word consists of the following
#               sequence of substrings:
#
#               - Shell non-special characters: [^\'"$`;&|<>()!].
#               - Parameter expansions of the forms $PARAM, ${!PARAM},
#                 ${#PARAM}, ${NAME[INDEX]}, ${!NAME[INDEX]}, ${#NAME[INDEX]}
#                 where INDEX is an integer, `*` or `@`, NAME is a valid
#                 variable name [_a-zA-Z][_a-zA-Z0-9]*, and PARAM is NAME or a
#                 parameter [-*@#?$!0-9_].
#               - Quotes \?, '...', "...", $'...', and $"...".  In the double
#                 quotations, parameter expansions are allowed.
#
# @var[out] ret Array that contains the expanded results.  Multiple words or no
#               words may be generated through pathname expansions.
#
# Note: This function allows parameter expansions as safe strings, which might
# cause unexpected results:
#
# * This allows execution of arbitrary commands through extra expansions of
#   array subscripts in name references. For example,
#
#     declare -n v='dummy[$(echo xxx >/dev/tty)]'
#     echo "$v"            # This line executes the command 'echo xxx'.
#     _comp_dequote '"$v"' # This line also executes it.
#
# * This may change the internal state of the variable that has side effects.
#   For example, the state of the random number generator of RANDOM can change:
#
#     RANDOM=1234               # Set seed
#     echo "$RANDOM"            # This produces 30658.
#     RANDOM=1234               # Reset seed
#     _comp_dequote '"$RANDOM"' # This line changes the internal state.
#     echo "$RANDOM"            # This fails to reproduce 30658.
#
# We allow these parameter expansions as a part of safe strings assuming the
# referential transparency of the simple parameter expansions and the sane
# setup of the variables by the user or other frameworks that the user loads.
_comp_dequote()
{
    ret=() # fallback value for unsafe word and failglob
    [[ $1 =~ $_comp_dequote__regex_safe_word ]] || return 1
    eval "ret=($1)" 2>/dev/null # may produce failglob
}

# This function shell-dequotes the argument
# @deprecated Use `_comp_dequote' instead.  Note that `_comp_dequote` stores
#   the results in the array `ret` instead of writing them to stdout.
dequote()
{
    local ret
    _comp_dequote "$1"
    local rc=$?
    printf %s "$ret"
    return $rc
}

# Unset the given variables across a scope boundary. Useful for unshadowing
# global scoped variables. Note that simply calling unset on a local variable
# will not unshadow the global variable. Rather, the result will be a local
# variable in an unset state.
# Usage: local IFS='|'; _comp_unlocal IFS
# @param $* Variable names to be unset
_comp_unlocal()
{
    if ((BASH_VERSINFO[0] >= 5)) && shopt -q localvar_unset; then
        shopt -u localvar_unset
        unset -v "$@"
        shopt -s localvar_unset
    else
        unset -v "$@"
    fi
}

# Assign variable one scope above the caller
# Usage: local "$1" && _upvar $1 "value(s)"
# @param $1  Variable name to assign value to
# @param $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use '_upvars'.  Do NOT
#       use multiple '_upvar' calls, since one '_upvar' call might
#       reassign a variable to be used by another '_upvar' call.
# @see https://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvar()
{
    echo "bash_completion: $FUNCNAME: deprecated function," \
        "use _upvars instead" >&2
    if unset -v "$1"; then # Unset & validate varname
        if (($# == 2)); then
            eval $1=\"\$2\" # Return single value
        else
            eval $1=\(\"\$"{@:2}"\"\) # Return array
        fi
    fi
}

# Assign variables one scope above the caller
# Usage: local varname [varname ...] &&
#        _upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
# @return  1 if error occurs
# @see https://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvars()
{
    if ! (($#)); then
        echo "bash_completion: $FUNCNAME: usage: $FUNCNAME" \
            "[-v varname value] | [-aN varname [value ...]] ..." >&2
        return 2
    fi
    while (($#)); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || {
                    echo "bash_completion: $FUNCNAME:" \
                        "\`$1': missing number specifier" >&2
                    return 1
                }
                printf %d "${1#-a}" &>/dev/null || {
                    echo bash_completion: \
                        "$FUNCNAME: \`$1': invalid number specifier" >&2
                    return 1
                }
                # Assign array of -aN elements
                # shellcheck disable=SC2015  # TODO
                [[ $2 ]] && unset -v "$2" && eval $2=\(\"\$"{@:3:${1#-a}}"\"\) &&
                    shift $((${1#-a} + 2)) || {
                    echo bash_completion: \
                        "$FUNCNAME: \`$1${2+ }$2': missing argument(s)" \
                        >&2
                    return 1
                }
                ;;
            -v)
                # Assign single value
                # shellcheck disable=SC2015  # TODO
                [[ $2 ]] && unset -v "$2" && eval $2=\"\$3\" &&
                    shift 3 || {
                    echo "bash_completion: $FUNCNAME: $1:" \
                        "missing argument(s)" >&2
                    return 1
                }
                ;;
            *)
                echo "bash_completion: $FUNCNAME: $1: invalid option" >&2
                return 1
                ;;
        esac
    done
}

# Get the list of filenames that match with the specified glob pattern.
# This function does the globbing in a controlled environment, avoiding
# interference from user's shell options/settings or environment variables.
# @param $1 array_name  Array name
#   The array name should not start with the double underscores "__".  The
#   array name should not be "GLOBIGNORE".
# @param $2 pattern     Pattern string to be evaluated.
#   This pattern string will be evaluated using "eval", so brace expansions,
#   parameter expansions, command substitutions, and other expansions will be
#   processed.  The user-provided strings should not be directly specified to
#   this argument.
_comp_expand_glob()
{
    if (($# != 2)); then
        printf 'bash-completion: %s: unexpected number of arguments\n' "$FUNCNAME" >&2
        printf 'usage: %s ARRAY_NAME PATTERN\n' "$FUNCNAME" >&2
        return 2
    elif [[ $1 == @(GLOBIGNORE|__*|*[^_a-zA-Z0-9]*|[0-9]*|'') ]]; then
        printf 'bash-completion: %s: invalid array name "%s"\n' "$FUNCNAME" "$1" >&2
        return 2
    fi

    # Save and adjust the settings.
    local __original_opts=$SHELLOPTS:$BASHOPTS
    set +o noglob
    shopt -s nullglob
    shopt -u failglob dotglob

    # Also the user's GLOBIGNORE may affect the result of pathname expansions.
    local GLOBIGNORE=

    eval -- "$1=()" # a fallback in case that the next line fails.
    eval -- "$1=($2)"

    # Restore the settings.  Note: Changing GLOBIGNORE affects the state of
    # "shopt -q dotglob", so we need to explicitly restore the original state
    # of "shopt -q dotglob".
    _comp_unlocal GLOBIGNORE
    if [[ :$__original_opts: == *:dotglob:* ]]; then
        shopt -s dotglob
    else
        shopt -u dotglob
    fi
    [[ :$__original_opts: == *:nullglob:* ]] || shopt -u nullglob
    [[ :$__original_opts: == *:failglob:* ]] && shopt -s failglob
    [[ :$__original_opts: == *:noglob:* ]] && set -o noglob
    return 0
}

# Reassemble command line words, excluding specified characters from the
# list of word completion separators (COMP_WORDBREAKS).
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 here.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
#
__reassemble_comp_words_by_ref()
{
    local exclude i j line ref
    # Exclude word separator characters?
    if [[ $1 ]]; then
        # Yes, exclude word separator characters;
        # Exclude only those characters, which were really included
        exclude="[${1//[^$COMP_WORDBREAKS]/}]"
    fi

    # Default to cword unchanged
    printf -v "$3" %s "$COMP_CWORD"
    # Are characters excluded which were former included?
    if [[ -v exclude ]]; then
        # Yes, list of word completion separators has shrunk;
        line=$COMP_LINE
        # Re-assemble words to complete
        for ((i = 0, j = 0; i < ${#COMP_WORDS[@]}; i++, j++)); do
            # Is current word not word 0 (the command itself) and is word not
            # empty and is word made up of just word separator characters to
            # be excluded and is current word not preceded by whitespace in
            # original line?
            while [[ $i -gt 0 && ${COMP_WORDS[i]} == +($exclude) ]]; do
                # Is word separator not preceded by whitespace in original line
                # and are we not going to append to word 0 (the command
                # itself), then append to current word.
                [[ $line != [[:blank:]]* ]] && ((j >= 2)) && ((j--))
                # Append word separator to current or new word
                ref="$2[$j]"
                printf -v "$ref" %s "${!ref-}${COMP_WORDS[i]}"
                # Indicate new cword
                ((i == COMP_CWORD)) && printf -v "$3" %s "$j"
                # Remove optional whitespace + word separator from line copy
                line=${line#*"${COMP_WORDS[i]}"}
                # Indicate next word if available, else end *both* while and
                # for loop
                if ((i < ${#COMP_WORDS[@]} - 1)); then
                    ((i++))
                else
                    break 2
                fi
                # Start new word if word separator in original line is
                # followed by whitespace.
                [[ $line == [[:blank:]]* ]] && ((j++))
            done
            # Append word to current word
            ref="$2[$j]"
            printf -v "$ref" %s "${!ref-}${COMP_WORDS[i]}"
            # Remove optional whitespace + word from line copy
            line=${line#*"${COMP_WORDS[i]}"}
            # Indicate new cword
            ((i == COMP_CWORD)) && printf -v "$3" %s "$j"
        done
        ((i == COMP_CWORD)) && printf -v "$3" %s "$j"
    else
        # No, list of word completions separators hasn't changed;
        for i in "${!COMP_WORDS[@]}"; do
            printf -v "$2[i]" %s "${COMP_WORDS[i]}"
        done
    fi
} # __reassemble_comp_words_by_ref()

# @param $1 exclude  Characters out of $COMP_WORDBREAKS which should NOT be
#     considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 in this case.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
# @param $4 cur  Name of variable to return current word to complete to
# @see __reassemble_comp_words_by_ref()
__get_cword_at_cursor_by_ref()
{
    local cword words=()
    __reassemble_comp_words_by_ref "$1" words cword

    local i cur="" index=$COMP_POINT lead=${COMP_LINE:0:COMP_POINT}
    # Cursor not at position 0 and not led by just space(s)?
    if [[ $index -gt 0 && ($lead && ${lead//[[:space:]]/}) ]]; then
        cur=$COMP_LINE
        for ((i = 0; i <= cword; ++i)); do
            # Current word fits in $cur, and $cur doesn't match cword?
            while [[ ${#cur} -ge ${#words[i]} &&
                ${cur:0:${#words[i]}} != "${words[i]-}" ]]; do
                # Strip first character
                cur=${cur:1}
                # Decrease cursor position, staying >= 0
                ((index > 0)) && ((index--))
            done

            # Does found word match cword?
            if ((i < cword)); then
                # No, cword lies further;
                local old_size=${#cur}
                cur=${cur#"${words[i]}"}
                local new_size=${#cur}
                ((index -= old_size - new_size))
            fi
        done
        # Clear $cur if just space(s)
        [[ $cur && ! ${cur//[[:space:]]/} ]] && cur=
        # Zero $index if negative
        ((index < 0)) && index=0
    fi

    local "$2" "$3" "$4" && _upvars -a${#words[@]} $2 ${words+"${words[@]}"} \
        -v $3 "$cword" -v $4 "${cur:0:index}"
}

# Get the word to complete and optional previous words.
# This is nicer than ${COMP_WORDS[COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# Also one is able to cross over possible wordbreak characters.
# Usage: _get_comp_words_by_ref [OPTIONS] [VARNAMES]
# Available VARNAMES:
#     cur         Return cur via $cur
#     prev        Return prev via $prev
#     words       Return words via $words
#     cword       Return cword via $cword
#
# Available OPTIONS:
#     -n EXCLUDE  Characters out of $COMP_WORDBREAKS which should NOT be
#                 considered word breaks. This is useful for things like scp
#                 where we want to return host:path and not only path, so we
#                 would pass the colon (:) as -n option in this case.
#     -c VARNAME  Return cur via $VARNAME
#     -p VARNAME  Return prev via $VARNAME
#     -w VARNAME  Return words via $VARNAME
#     -i VARNAME  Return cword via $VARNAME
#
# Example usage:
#
#    $ _get_comp_words_by_ref -n : cur prev
#
_get_comp_words_by_ref()
{
    local exclude flag i OPTIND=1
    local cur cword words=()
    local upargs=() upvars=() vcur vcword vprev vwords

    while getopts "c:i:n:p:w:" flag "$@"; do
        case $flag in
            c) vcur=$OPTARG ;;
            i) vcword=$OPTARG ;;
            n) exclude=$OPTARG ;;
            p) vprev=$OPTARG ;;
            w) vwords=$OPTARG ;;
            *)
                echo "bash_completion: $FUNCNAME: usage error" >&2
                return 1
                ;;
        esac
    done
    while [[ $# -ge $OPTIND ]]; do
        case ${!OPTIND} in
            cur) vcur=cur ;;
            prev) vprev=prev ;;
            cword) vcword=cword ;;
            words) vwords=words ;;
            *)
                echo "bash_completion: $FUNCNAME: \`${!OPTIND}':" \
                    "unknown argument" >&2
                return 1
                ;;
        esac
        ((OPTIND += 1))
    done

    __get_cword_at_cursor_by_ref "${exclude-}" words cword cur

    [[ -v vcur ]] && {
        upvars+=("$vcur")
        upargs+=(-v $vcur "$cur")
    }
    [[ -v vcword ]] && {
        upvars+=("$vcword")
        upargs+=(-v $vcword "$cword")
    }
    [[ -v vprev && $cword -ge 1 ]] && {
        upvars+=("$vprev")
        upargs+=(-v $vprev "${words[cword - 1]}")
    }
    [[ -v vwords ]] && {
        upvars+=("$vwords")
        upargs+=(-a${#words[@]} $vwords ${words+"${words[@]}"})
    }

    ((${#upvars[@]})) && local "${upvars[@]}" && _upvars "${upargs[@]}"
}

# Get the word to complete.
# This is nicer than ${COMP_WORDS[COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# @param $1 string  Characters out of $COMP_WORDBREAKS which should NOT be
#     considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 in this case.
# @param $2 integer  Index number of word to return, negatively offset to the
#     current word (default is 0, previous is 1), respecting the exclusions
#     given at $1.  For example, `_get_cword "=:" 1' returns the word left of
#     the current word, respecting the exclusions "=:".
# @deprecated  Use `_get_comp_words_by_ref cur' instead
# @see _get_comp_words_by_ref()
_get_cword()
{
    local LC_CTYPE=C
    local cword words
    __reassemble_comp_words_by_ref "${1-}" words cword

    # return previous word offset by $2
    if [[ ${2-} && ${2//[^0-9]/} ]]; then
        printf "%s" "${words[cword - $2]}"
    elif ((${#words[cword]} == 0 && COMP_POINT == ${#COMP_LINE})); then
        : # nothing
    else
        local i
        local cur=$COMP_LINE
        local index=$COMP_POINT
        for ((i = 0; i <= cword; ++i)); do
            # Current word fits in $cur, and $cur doesn't match cword?
            while [[ ${#cur} -ge ${#words[i]} &&
                ${cur:0:${#words[i]}} != "${words[i]}" ]]; do
                # Strip first character
                cur=${cur:1}
                # Decrease cursor position, staying >= 0
                ((index > 0)) && ((index--))
            done

            # Does found word match cword?
            if ((i < cword)); then
                # No, cword lies further;
                local old_size=${#cur}
                cur=${cur#"${words[i]}"}
                local new_size=${#cur}
                ((index -= old_size - new_size))
            fi
        done

        if [[ ${words[cword]:0:${#cur}} != "$cur" ]]; then
            # We messed up! At least return the whole word so things
            # keep working
            printf "%s" "${words[cword]}"
        else
            printf "%s" "${cur:0:index}"
        fi
    fi
} # _get_cword()

# Get word previous to the current word.
# This is a good alternative to `prev=${COMP_WORDS[COMP_CWORD-1]}' because bash4
# will properly return the previous word with respect to any given exclusions to
# COMP_WORDBREAKS.
# @deprecated  Use `_get_comp_words_by_ref cur prev' instead
# @see _get_comp_words_by_ref()
#
_get_pword()
{
    if ((COMP_CWORD >= 1)); then
        _get_cword "${@:-}" 1
    fi
}

# If the word-to-complete contains a colon (:), left-trim COMPREPLY items with
# word-to-complete.
# With a colon in COMP_WORDBREAKS, words containing
# colons are always completed as entire words if the word to complete contains
# a colon.  This function fixes this, by removing the colon-containing-prefix
# from COMPREPLY items.
# The preferred solution is to remove the colon (:) from COMP_WORDBREAKS in
# your .bashrc:
#
#    # Remove colon (:) from list of word completion separators
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
# See also: Bash FAQ - E13) Why does filename completion misbehave if a colon
# appears in the filename? - https://tiswww.case.edu/php/chet/bash/FAQ
# @param $1 current word to complete (cur)
# @modifies global array $COMPREPLY
#
__ltrim_colon_completions()
{
    local i=${#COMPREPLY[*]}
    ((i == 0)) && return 0
    if [[ $1 == *:* && $COMP_WORDBREAKS == *:* ]]; then
        # Remove colon-word prefix from COMPREPLY items
        local colon_word=${1%"${1##*:}"}
        COMPREPLY=("${COMPREPLY[@]}")
        while ((i-- > 0)); do
            COMPREPLY[i]=${COMPREPLY[i]#"$colon_word"}
        done
    fi
} # __ltrim_colon_completions()

# This function quotes the argument in a way so that readline dequoting
# results in the original argument.  This is necessary for at least
# `compgen' which requires its arguments quoted/escaped:
#
#     $ ls "a'b/"
#     c
#     $ compgen -f "a'b/"       # Wrong, doesn't return output
#     $ compgen -f "a\'b/"      # Good
#     a\'b/c
#
# See also:
# - https://lists.gnu.org/archive/html/bug-bash/2009-03/msg00155.html
# - https://www.mail-archive.com/bash-completion-devel@lists.alioth.debian.org/msg01944.html
# @param $1  Argument to quote
# @param $2  Name of variable to return result to
_quote_readline_by_ref()
{
    if [[ $1 == \'* ]]; then
        # Leave out first character
        printf -v $2 %s "${1:1}"
    else
        printf -v $2 %q "$1"

        # If result becomes quoted like this: $'string', re-evaluate in order
        # to drop the additional quoting.  See also:
        # https://www.mail-archive.com/bash-completion-devel@lists.alioth.debian.org/msg01942.html
        if [[ ${!2} == \$\'*\' ]]; then
            local value=${!2:2:-1} # Strip beginning $' and ending '.
            value=${value//'%'/%%} # Escape % for printf format.
            # shellcheck disable=SC2059
            printf -v value "$value" # Decode escape sequences of \....
            local "$2" && _upvars -v "$2" "$value"
        fi
    fi
} # _quote_readline_by_ref()

# This function performs file and directory completion. It's better than
# simply using 'compgen -f', because it honours spaces in filenames.
# @param $1  If `-d', complete only on directories.  Otherwise filter/pick only
#            completions with `.$1' and the uppercase version of it as file
#            extension.
#
_filedir()
{
    local IFS=$'\n'

    _tilde "${cur-}" || return

    local -a toks
    local reset arg=${1-}

    if [[ $arg == -d ]]; then
        reset=$(shopt -po noglob)
        set -o noglob
        toks=($(compgen -d -- "${cur-}"))
        IFS=' '
        $reset
        IFS=$'\n'
    else
        local quoted
        _quote_readline_by_ref "${cur-}" quoted

        # Munge xspec to contain uppercase version too
        # https://lists.gnu.org/archive/html/bug-bash/2010-09/msg00036.html
        # news://news.gmane.io/4C940E1C.1010304@case.edu
        local xspec=${arg:+"!*.@($arg|${arg^^})"} plusdirs=()

        # Use plusdirs to get dir completions if we have a xspec; if we don't,
        # there's no need, dirs come along with other completions. Don't use
        # plusdirs quite yet if fallback is in use though, in order to not ruin
        # the fallback condition with the "plus" dirs.
        local opts=(-f -X "$xspec")
        [[ $xspec ]] && plusdirs=(-o plusdirs)
        [[ ${BASH_COMPLETION_FILEDIR_FALLBACK-${COMP_FILEDIR_FALLBACK-}} ||
            ! ${plusdirs-} ]] ||
            opts+=("${plusdirs[@]}")

        reset=$(shopt -po noglob)
        set -o noglob
        toks+=($(compgen "${opts[@]}" -- $quoted))
        IFS=' '
        $reset
        IFS=$'\n'

        # Try without filter if it failed to produce anything and configured to
        [[ ${BASH_COMPLETION_FILEDIR_FALLBACK-${COMP_FILEDIR_FALLBACK-}} &&
            $arg && ${#toks[@]} -lt 1 ]] && {
            reset=$(shopt -po noglob)
            set -o noglob
            toks+=($(compgen -f ${plusdirs+"${plusdirs[@]}"} -- $quoted))
            IFS=' '
            $reset
            IFS=$'\n'
        }
    fi

    if ((${#toks[@]} != 0)); then
        # 2>/dev/null for direct invocation, e.g. in the _filedir unit test
        compopt -o filenames 2>/dev/null
        COMPREPLY+=("${toks[@]}")
    fi
} # _filedir()

# This function splits $cur=--foo=bar into $prev=--foo, $cur=bar, making it
# easier to support both "--foo bar" and "--foo=bar" style completions.
# `=' should have been removed from COMP_WORDBREAKS when setting $cur for
# this to be useful.
# Returns 0 if current option was split, 1 otherwise.
#
_split_longopt()
{
    if [[ $cur == --?*=* ]]; then
        # Cut also backslash before '=' in case it ended up there
        # for some reason.
        prev=${cur%%?(\\)=*}
        cur=${cur#*=}
        return 0
    fi

    return 1
}

# Complete variables.
# @return  True (0) if variables were completed,
#          False (> 0) if not.
_variables()
{
    if [[ $cur =~ ^(\$(\{[!#]?)?)([A-Za-z0-9_]*)$ ]]; then
        # Completing $var / ${var / ${!var / ${#var
        if [[ $cur == '${'* ]]; then
            local arrs vars
            vars=($(compgen -A variable -P ${BASH_REMATCH[1]} -S '}' -- ${BASH_REMATCH[3]}))
            arrs=($(compgen -A arrayvar -P ${BASH_REMATCH[1]} -S '[' -- ${BASH_REMATCH[3]}))
            if ((${#vars[@]} == 1 && ${#arrs[@]} != 0)); then
                # Complete ${arr with ${array[ if there is only one match, and that match is an array variable
                compopt -o nospace
                COMPREPLY+=(${arrs[*]})
            else
                # Complete ${var with ${variable}
                COMPREPLY+=(${vars[*]})
            fi
        else
            # Complete $var with $variable
            COMPREPLY+=($(compgen -A variable -P '$' -- "${BASH_REMATCH[3]}"))
        fi
        return 0
    elif [[ $cur =~ ^(\$\{[#!]?)([A-Za-z0-9_]*)\[([^]]*)$ ]]; then
        # Complete ${array[i with ${array[idx]}
        local reset=$(shopt -po noglob) IFS=$'\n'
        set -o noglob
        COMPREPLY+=($(compgen -W '$(printf %s\\n "${!'${BASH_REMATCH[2]}'[@]}")' \
            -P "${BASH_REMATCH[1]}${BASH_REMATCH[2]}[" -S ']}' -- "${BASH_REMATCH[3]}"))
        IFS=$' \t\n'
        $reset
        # Complete ${arr[@ and ${arr[*
        if [[ ${BASH_REMATCH[3]} == [@*] ]]; then
            COMPREPLY+=("${BASH_REMATCH[1]}${BASH_REMATCH[2]}[${BASH_REMATCH[3]}]}")
        fi
        __ltrim_colon_completions "$cur" # array indexes may have colons
        return 0
    elif [[ $cur =~ ^\$\{[#!]?[A-Za-z0-9_]*\[.*\]$ ]]; then
        # Complete ${array[idx] with ${array[idx]}
        COMPREPLY+=("$cur}")
        __ltrim_colon_completions "$cur"
        return 0
    fi
    return 1
}

# Complete a delimited value.
#
# Usage: [-k] DELIMITER COMPGEN_ARG...
#         -k: do not filter out already present tokens in value
_comp_delimited()
{
    local prefix="" delimiter=$1 deduplicate=true
    shift
    if [[ $delimiter == -k ]]; then
        deduplicate=false
        delimiter=$1
        shift
    fi
    [[ $cur == *$delimiter* ]] && prefix=${cur%"$delimiter"*}$delimiter

    if $deduplicate; then
        # We could construct a -X pattern to feed to compgen, but that'd
        # conflict with possibly already set -X in $@, as well as have
        # glob char escaping issues to deal with. Do removals by hand instead.
        COMPREPLY=($(compgen "$@"))
        local -a existing
        local x i IFS=$delimiter
        existing=($cur)
        # Do not remove the last from existing if it's not followed by the
        # delimiter so we get space appended.
        [[ ! $cur || $cur == *"$delimiter" ]] || unset -v "existing[${#existing[@]}-1]"
        _comp_unlocal IFS
        if ((${#COMPREPLY[@]})); then
            for x in ${existing+"${existing[@]}"}; do
                for i in "${!COMPREPLY[@]}"; do
                    if [[ $x == "${COMPREPLY[i]}" ]]; then
                        unset -v 'COMPREPLY[i]'
                        continue 2 # assume no dupes in COMPREPLY
                    fi
                done
            done
            COMPREPLY=($(compgen -W '"${COMPREPLY[@]}"' -- "${cur##*"$delimiter"}"))
        fi
    else
        COMPREPLY=($(compgen "$@" -- "${cur##*"$delimiter"}"))
    fi

    ((${#COMPREPLY[@]} == 1)) && COMPREPLY=(${COMPREPLY/#/$prefix})
    [[ $delimiter != : ]] || __ltrim_colon_completions "$cur"
}

# Complete assignment of various known environment variables.
#
# The word to be completed is expected to contain the entire assignment,
# including the variable name and the "=". Some known variables are completed
# with colon separated values; for those to work, colon should not have been
# used to split words. See related parameters to _init_completion.
#
# @param  $1 variable assignment to be completed
# @return True (0) if variable value completion was attempted,
#         False (> 0) if not.
_comp_variable_assignments()
{
    local cur=${1-} i

    if [[ $cur =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
        prev=${BASH_REMATCH[1]}
        cur=${BASH_REMATCH[2]}
    else
        return 1
    fi

    case $prev in
        TZ)
            cur=/usr/share/zoneinfo/$cur
            _filedir
            if ((${#COMPREPLY[@]})); then
                for i in "${!COMPREPLY[@]}"; do
                    if [[ ${COMPREPLY[i]} == *.tab ]]; then
                        unset -v 'COMPREPLY[i]'
                        continue
                    elif [[ -d ${COMPREPLY[i]} ]]; then
                        COMPREPLY[i]+=/
                        compopt -o nospace
                    fi
                    COMPREPLY[i]=${COMPREPLY[i]#/usr/share/zoneinfo/}
                done
            fi
            ;;
        TERM)
            _terms
            ;;
        LANG | LC_*)
            COMPREPLY=($(compgen -W '$(locale -a 2>/dev/null)' -- "$cur"))
            ;;
        LANGUAGE)
            _comp_delimited : -W '$(locale -a 2>/dev/null)'
            ;;
        *)
            _variables && return 0
            _filedir
            ;;
    esac

    return 0
}

# Initialize completion and deal with various general things: do file
# and variable completion where appropriate, and adjust prev, words,
# and cword as if no redirections exist so that completions do not
# need to deal with them.  Before calling this function, make sure
# cur, prev, words, and cword are local, ditto split if you use -s.
#
# Options:
#     -n EXCLUDE  Passed to _get_comp_words_by_ref -n with redirection chars
#     -e XSPEC    Passed to _filedir as first arg for stderr redirections
#     -o XSPEC    Passed to _filedir as first arg for other output redirections
#     -i XSPEC    Passed to _filedir as first arg for stdin redirections
#     -s          Split long options with _split_longopt, implies -n =
# @return  True (0) if completion needs further processing,
#          False (> 0) no further processing is necessary.
#
_init_completion()
{
    local exclude="" flag outx errx inx OPTIND=1

    while getopts "n:e:o:i:s" flag "$@"; do
        case $flag in
            n) exclude+=$OPTARG ;;
            e) errx=$OPTARG ;;
            o) outx=$OPTARG ;;
            i) inx=$OPTARG ;;
            s)
                split=false
                exclude+="="
                ;;
            *)
                echo "bash_completion: $FUNCNAME: usage error" >&2
                return 1
                ;;
        esac
    done

    COMPREPLY=()
    local redir="@(?([0-9])<|?([0-9&])>?(>)|>&)"
    _get_comp_words_by_ref -n "$exclude<>&" cur prev words cword

    # Complete variable names.
    _variables && return 1

    # Complete on files if current is a redirect possibly followed by a
    # filename, e.g. ">foo", or previous is a "bare" redirect, e.g. ">".
    # shellcheck disable=SC2053
    if [[ $cur == $redir* || ${prev-} == $redir ]]; then
        local xspec
        case $cur in
            2'>'*) xspec=${errx-} ;;
            *'>'*) xspec=${outx-} ;;
            *'<'*) xspec=${inx-} ;;
            *)
                case $prev in
                    2'>'*) xspec=${errx-} ;;
                    *'>'*) xspec=${outx-} ;;
                    *'<'*) xspec=${inx-} ;;
                esac
                ;;
        esac
        cur=${cur##"$redir"}
        _filedir $xspec
        return 1
    fi

    # Remove all redirections so completions don't have to deal with them.
    local i skip
    for ((i = 1; i < ${#words[@]}; )); do
        if [[ ${words[i]} == $redir* ]]; then
            # If "bare" redirect, remove also the next word (skip=2).
            # shellcheck disable=SC2053
            [[ ${words[i]} == $redir ]] && skip=2 || skip=1
            words=("${words[@]:0:i}" "${words[@]:i+skip}")
            ((i <= cword)) && ((cword -= skip))
        else
            ((i++))
        fi
    done

    ((cword <= 0)) && return 1
    prev=${words[cword - 1]}

    [[ ${split-} ]] && _split_longopt && split=true

    return 0
}

# Helper function for _parse_help and _parse_usage.
# @return True (0) if an option was found, False (> 0) otherwise
__parse_options()
{
    local option option2 i IFS=$' \t\n,/|'

    # Take first found long option, or first one (short) if not found.
    option=
    local reset=$(shopt -po noglob)
    set -o noglob
    local -a array=($1)
    $reset
    for i in "${array[@]}"; do
        case "$i" in
            ---*) break ;;
            --?*)
                option=$i
                break
                ;;
            -?*) [[ $option ]] || option=$i ;;
            *) break ;;
        esac
    done
    [[ $option ]] || return 1

    IFS=$' \t\n' # affects parsing of the regexps below...

    # Expand --[no]foo to --foo and --nofoo etc
    if [[ $option =~ (\[((no|dont)-?)\]). ]]; then
        option2=${option/"${BASH_REMATCH[1]}"/}
        option2=${option2%%[<{().[]*}
        printf '%s\n' "${option2/=*/=}"
        option=${option/"${BASH_REMATCH[1]}"/"${BASH_REMATCH[2]}"}
    fi

    option=${option%%[<{().[]*}
    option=${option/=*/=}
    [[ $option ]] || return 1

    printf '%s\n' "$option"
}

# Parse GNU style help output of the given command.
# @param $1  command; if "-", read from stdin and ignore rest of args
# @param $2  command options (default: --help)
#
_parse_help()
{
    local IFS=$' \t\n'
    local reset_monitor=$(shopt -po monitor) reset_lastpipe=$(shopt -p lastpipe) reset_noglob=$(shopt -po noglob)
    set +o monitor
    shopt -s lastpipe
    set -o noglob

    local cmd=$1
    local line rc=1
    (
        case $cmd in
            -) exec cat ;;
            *) _comp_dequote "$cmd" && LC_ALL=C "$ret" ${2:---help} 2>&1 ;;
        esac
    ) |
        while read -r line; do

            [[ $line == *([[:blank:]])-* ]] || continue
            # transform "-f FOO, --foo=FOO" to "-f , --foo=FOO" etc
            while [[ $line =~ ((^|[^-])-[A-Za-z0-9?][[:space:]]+)\[?[A-Z0-9]+([,_-]+[A-Z0-9]+)?(\.\.+)?\]? ]]; do
                line=${line/"${BASH_REMATCH[0]}"/"${BASH_REMATCH[1]}"}
            done
            __parse_options "${line// or /, }" && rc=0

        done

    $reset_monitor
    $reset_lastpipe
    $reset_noglob
    return $rc
}

# Parse BSD style usage output (options in brackets) of the given command.
# @param $1  command; if "-", read from stdin and ignore rest of args
# @param $2  command options (default: --usage)
#
_parse_usage()
{
    local IFS=$' \t\n'
    local reset_monitor=$(shopt -po monitor) reset_lastpipe=$(shopt -p lastpipe) reset_noglob=$(shopt -po noglob)
    set +o monitor
    shopt -s lastpipe
    set -o noglob

    local cmd=$1
    local line match option i char rc=1
    (
        case $cmd in
            -) exec cat ;;
            *) _comp_dequote "$cmd" && LC_ALL=C "$ret" ${2:---usage} 2>&1 ;;
        esac
    ) |
        while read -r line; do

            while [[ $line =~ \[[[:space:]]*(-[^]]+)[[:space:]]*\] ]]; do
                match=${BASH_REMATCH[0]}
                option=${BASH_REMATCH[1]}
                case $option in
                    -?(\[)+([a-zA-Z0-9?]))
                        # Treat as bundled short options
                        for ((i = 1; i < ${#option}; i++)); do
                            char=${option:i:1}
                            [[ $char != '[' ]] && printf '%s\n' -$char && rc=0
                        done
                        ;;
                    *)
                        __parse_options "$option" && rc=0
                        ;;
                esac
                line=${line#*"$match"}
            done

        done

    $reset_monitor
    $reset_lastpipe
    $reset_noglob
    return $rc
}

# This function completes on signal names (minus the SIG prefix)
# @param $1 prefix
_signals()
{
    local -a sigs=($(compgen -P "${1-}" -A signal "SIG${cur#"${1-}"}"))
    COMPREPLY+=("${sigs[@]/#${1-}SIG/${1-}}")
}

# This function completes on known mac addresses
#
_mac_addresses()
{
    local re='\([A-Fa-f0-9]\{2\}:\)\{5\}[A-Fa-f0-9]\{2\}'
    local PATH="$PATH:/sbin:/usr/sbin"

    # Local interfaces
    # - ifconfig on Linux: HWaddr or ether
    # - ifconfig on FreeBSD: ether
    # - ip link: link/ether
    COMPREPLY+=($(
        {
            LC_ALL=C ifconfig -a || ip -c=never link show || ip link show
        } 2>/dev/null | command sed -ne \
            "s/.*[[:space:]]HWaddr[[:space:]]\{1,\}\($re\)[[:space:]].*/\1/p" -ne \
            "s/.*[[:space:]]HWaddr[[:space:]]\{1,\}\($re\)[[:space:]]*$/\1/p" -ne \
            "s|.*[[:space:]]\(link/\)\{0,1\}ether[[:space:]]\{1,\}\($re\)[[:space:]].*|\2|p" -ne \
            "s|.*[[:space:]]\(link/\)\{0,1\}ether[[:space:]]\{1,\}\($re\)[[:space:]]*$|\2|p"
    ))

    # ARP cache
    COMPREPLY+=($({
        arp -an || ip -c=never neigh show || ip neigh show
    } 2>/dev/null | command sed -ne \
        "s/.*[[:space:]]\($re\)[[:space:]].*/\1/p" -ne \
        "s/.*[[:space:]]\($re\)[[:space:]]*$/\1/p"))

    # /etc/ethers
    COMPREPLY+=($(command sed -ne \
        "s/^[[:space:]]*\($re\)[[:space:]].*/\1/p" /etc/ethers 2>/dev/null))

    ((${#COMPREPLY[@]})) &&
        COMPREPLY=($(compgen -W '"${COMPREPLY[@]}"' -- "$cur"))
    __ltrim_colon_completions "$cur"
}

# This function completes on configured network interfaces
#
_configured_interfaces()
{
    local -a files
    if [[ -f /etc/debian_version ]]; then
        # Debian system
        _comp_expand_glob files '/etc/network/interfaces /etc/network/interfaces.d/*'
        ((${#files[@]})) || return 0
        COMPREPLY=($(compgen -W "$(command sed -ne 's|^iface \([^ ]\{1,\}\).*$|\1|p' \
            "${files[@]}" 2>/dev/null)" \
            -- "$cur"))
    elif [[ -f /etc/SuSE-release ]]; then
        # SuSE system
        _comp_expand_glob files '/etc/sysconfig/network/ifcfg-*'
        ((${#files[@]})) || return 0
        COMPREPLY=($(compgen -W "$(printf '%s\n' \
            "${files[@]}" |
            command sed -ne 's|.*ifcfg-\([^*].*\)$|\1|p')" -- "$cur"))
    elif [[ -f /etc/pld-release ]]; then
        # PLD Linux
        COMPREPLY=($(compgen -W "$(command ls -B \
            /etc/sysconfig/interfaces |
            command sed -ne 's|.*ifcfg-\([^*].*\)$|\1|p')" -- "$cur"))
    else
        # Assume Red Hat
        _comp_expand_glob files '/etc/sysconfig/network-scripts/ifcfg-*'
        ((${#files[@]})) || return 0
        COMPREPLY=($(compgen -W "$(printf '%s\n' \
            "${files[@]}" |
            command sed -ne 's|.*ifcfg-\([^*].*\)$|\1|p')" -- "$cur"))
    fi
}

# Local IP addresses.
# -4: IPv4 addresses only (default)
# -6: IPv6 addresses only
# -a: All addresses
#
_ip_addresses()
{
    local n
    case ${1-} in
        -a) n='6\{0,1\}' ;;
        -6) n='6' ;;
        *) n= ;;
    esac
    local PATH=$PATH:/sbin
    local addrs=$({
        LC_ALL=C ifconfig -a || ip -c=never addr show || ip addr show
    } 2>/dev/null |
        command sed -e 's/[[:space:]]addr:/ /' -ne \
            "s|.*inet${n}[[:space:]]\{1,\}\([^[:space:]/]*\).*|\1|p")
    COMPREPLY+=($(compgen -W "$addrs" -- "${cur-}"))
}

# This function completes on available kernels
#
_kernel_versions()
{
    COMPREPLY=($(compgen -W '$(command ls /lib/modules)' -- "$cur"))
}

# This function completes on all available network interfaces
# -a: restrict to active interfaces only
# -w: restrict to wireless interfaces only
#
_available_interfaces()
{
    local PATH=$PATH:/sbin

    COMPREPLY=($({
        if [[ ${1:-} == -w ]]; then
            iwconfig
        elif [[ ${1:-} == -a ]]; then
            ifconfig || ip -c=never link show up || ip link show up
        else
            ifconfig -a || ip -c=never link show || ip link show
        fi
    } 2>/dev/null | awk \
        '/^[^ \t]/ { if ($1 ~ /^[0-9]+:/) { print $2 } else { print $1 } }'))

    ((${#COMPREPLY[@]})) &&
        COMPREPLY=($(compgen -W '"${COMPREPLY[@]/%[[:punct:]]/}"' -- "$cur"))
}

# Echo number of CPUs, falling back to 1 on failure.
_ncpus()
{
    local var=NPROCESSORS_ONLN
    [[ $OSTYPE == *@(linux|msys|${HOMER_OS_TYPE}win)* ]] && var=_$var
    local n=$(getconf $var 2>/dev/null)
    printf %s ${n:-1}
}

# Perform tilde (~) completion
# @return  True (0) if completion needs further processing,
#          False (> 0) if tilde is followed by a valid username, completions
#          are put in COMPREPLY and no further processing is necessary.
_tilde()
{
    local result=0
    if [[ ${1-} == \~* && $1 != */* ]]; then
        # Try generate ~username completions
        COMPREPLY=($(compgen -P '~' -u -- "${1#\~}"))
        result=${#COMPREPLY[@]}
        # 2>/dev/null for direct invocation, e.g. in the _tilde unit test
        ((result > 0)) && compopt -o filenames 2>/dev/null
    fi
    return $result
}

# Expand variable starting with tilde (~)
# We want to expand ~foo/... to /home/foo/... to avoid problems when
# word-to-complete starting with a tilde is fed to commands and ending up
# quoted instead of expanded.
# Only the first portion of the variable from the tilde up to the first slash
# (~../) is expanded.  The remainder of the variable, containing for example
# a dollar sign variable ($) or asterisk (*) is not expanded.
# Example usage:
#
#    $ v="~"; __expand_tilde_by_ref v; echo "$v"
#
# Example output:
#
#       v                  output
#    --------         ----------------
#    ~                /home/user
#    ~foo/bar         /home/foo/bar
#    ~foo/$HOME       /home/foo/$HOME
#    ~foo/a  b        /home/foo/a  b
#    ~foo/*           /home/foo/*
#
# @param $1  Name of variable (not the value of the variable) to expand
__expand_tilde_by_ref()
{
    if [[ ${!1-} == \~* ]]; then
        eval $1="$(printf ~%q "${!1#\~}")"
    fi
} # __expand_tilde_by_ref()

# This function expands tildes in pathnames
#
_expand()
{
    # Expand ~username type directory specifications.  We want to expand
    # ~foo/... to /home/foo/... to avoid problems when $cur starting with
    # a tilde is fed to commands and ending up quoted instead of expanded.

    case ${cur-} in
        ~*/*)
            __expand_tilde_by_ref cur
            ;;
        ~*)
            _tilde "$cur" ||
                eval "COMPREPLY[0]=$(printf ~%q "${COMPREPLY[0]#\~}")"
            return ${#COMPREPLY[@]}
            ;;
    esac
}

# Process ID related functions.
# for AIX and Solaris we use X/Open syntax, BSD for others.
if [[ $OSTYPE == *@(solaris|aix)* ]]; then
    # This function completes on process IDs.
    _pids()
    {
        COMPREPLY=($(
            compgen -W '$(command ps -efo pid | command sed 1d)' -- "$cur"
        ))
    }

    _pgids()
    {
        COMPREPLY=($(
            compgen -W '$(command ps -efo pgid | command sed 1d)' -- "$cur"
        ))
    }
    _pnames()
    {
        COMPREPLY=($(compgen -X '<defunct>' -W '$(command ps -efo comm | \
            command sed -e 1d -e "s:.*/::" -e "s/^-//" | sort -u)' -- "$cur"))
    }
else
    _pids()
    {
        COMPREPLY=($(compgen -W '$(command ps ax -o pid=)' -- "$cur"))
    }
    _pgids()
    {
        COMPREPLY=($(compgen -W '$(command ps ax -o pgid=)' -- "$cur"))
    }
    # @param $1 if -s, don't try to avoid truncated command names
    _pnames()
    {
        local -a procs=()
        if [[ ${1-} == -s ]]; then
            procs=($(command ps ax -o comm | command sed -e 1d))
        else
            local line i=-1 IFS=$'\n'
            # Some versions of ps don't support "command", but do "comm", e.g.
            # some busybox ones. Fall back
            local -a psout=($({
                command ps ax -o command= || command ps ax -o comm=
            } 2>/dev/null))
            _comp_unlocal IFS
            for line in "${psout[@]}"; do
                if ((i == -1)); then
                    # First line, see if it has COMMAND column header. For
                    # example some busybox ps versions do that, i.e. don't
                    # respect command=
                    if [[ $line =~ ^(.*[[:space:]])COMMAND([[:space:]]|$) ]]; then
                        # It does; store its index.
                        i=${#BASH_REMATCH[1]}
                    else
                        # Nope, fall through to "regular axo command=" parsing.
                        break
                    fi
                else
                    #
                    line=${line:i}   # take command starting from found index
                    line=${line%% *} # trim arguments
                    procs+=($line)
                fi
            done
            if ((i == -1)); then
                # Regular command= parsing
                for line in "${psout[@]}"; do
                    if [[ $line =~ ^[[(](.+)[])]$ ]]; then
                        procs+=(${BASH_REMATCH[1]})
                    else
                        line=${line%% *}      # trim arguments
                        line=${line##@(*/|-)} # trim leading path and -
                        procs+=($line)
                    fi
                done
            fi
        fi
        ((${#procs[@]})) &&
            COMPREPLY=($(compgen -X "<defunct>" -W '"${procs[@]}"' -- "$cur"))
    }
fi

# This function completes on user IDs
#
_uids()
{
    if type getent &>/dev/null; then
        COMPREPLY=($(compgen -W '$(getent passwd | cut -d: -f3)' -- "$cur"))
    elif type perl &>/dev/null; then
        COMPREPLY=($(compgen -W '$(perl -e '"'"'while (($uid) = (getpwent)[2]) { print $uid . "\n" }'"'"')' -- "$cur"))
    else
        # make do with /etc/passwd
        COMPREPLY=($(compgen -W '$(cut -d: -f3 /etc/passwd)' -- "$cur"))
    fi
}

# This function completes on group IDs
#
_gids()
{
    if type getent &>/dev/null; then
        COMPREPLY=($(compgen -W '$(getent group | cut -d: -f3)' -- "$cur"))
    elif type perl &>/dev/null; then
        COMPREPLY=($(compgen -W '$(perl -e '"'"'while (($gid) = (getgrent)[2]) { print $gid . "\n" }'"'"')' -- "$cur"))
    else
        # make do with /etc/group
        COMPREPLY=($(compgen -W '$(cut -d: -f3 /etc/group)' -- "$cur"))
    fi
}

# Glob for matching various backup files.
#
_comp_backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'

# @deprecated Use the variable `_comp_backup_glob` instead.  This is the
# backward-compatibility name.
_backup_glob=$_comp_backup_glob

# Complete on xinetd services
#
_xinetd_services()
{
    local xinetddir=${_comp__test_xinetd_dir:-/etc/xinetd.d}
    if [[ -d $xinetddir ]]; then
        local -a svcs
        _comp_expand_glob svcs '$xinetddir/!($_comp_backup_glob)'
        if ((${#svcs[@]})); then
            local IFS=$'\n'
            COMPREPLY+=($(compgen -W '"${svcs[@]#$xinetddir/}"' -- "${cur-}"))
        fi
    fi
}

# This function completes on services
#
_services()
{
    local sysvdirs
    _comp_sysvdirs

    _comp_expand_glob COMPREPLY '${sysvdirs[0]}/!($_comp_backup_glob|functions|README)'

    local IFS=$'\n'
    COMPREPLY+=($({
        systemctl list-units --full --all ||
            systemctl list-unit-files
    } 2>/dev/null |
        awk '$1 ~ /\.service$/ { sub("\\.service$", "", $1); print $1 }'))

    if [[ -x /sbin/upstart-udev-bridge ]]; then
        COMPREPLY+=($(initctl list 2>/dev/null | cut -d' ' -f1))
    fi

    ((${#COMPREPLY[@]})) &&
        COMPREPLY=($(compgen -W '"${COMPREPLY[@]#${sysvdirs[0]}/}"' -- "$cur"))
}

# This completes on a list of all available service scripts for the
# 'service' command and/or the SysV init.d directory, followed by
# that script's available commands
#
_service()
{
    local cur prev words cword
    _init_completion || return

    # don't complete past 2nd token
    ((cword > 2)) && return

    if [[ $cword -eq 1 && $prev == ?(*/)service ]]; then
        _services
        [[ -e /etc/mandrake-release ]] && _xinetd_services
    else
        local IFS=$'\n' sysvdirs
        _comp_sysvdirs
        COMPREPLY=($(compgen -W '`command sed -e "y/|/ /" \
            -ne "s/^.*\(U\|msg_u\)sage.*{\(.*\)}.*$/\2/p" \
            ${sysvdirs[0]}/${prev##*/} 2>/dev/null` start stop' -- "$cur"))
    fi
} &&
    complete -F _service service

_comp__init_set_up_service_completions()
{
    local sysvdirs svc svcdir
    _comp_sysvdirs
    for svcdir in "${sysvdirs[@]}"; do
        for svc in "$svcdir"/!($_comp_backup_glob); do
            [[ -x $svc ]] && complete -F _service "$svc"
        done
    done
    unset -f "$FUNCNAME"
}
_comp__init_set_up_service_completions

# This function completes on modules
#
_modules()
{
    local modpath
    modpath=/lib/modules/$1
    COMPREPLY=($(compgen -W "$(command ls -RL $modpath 2>/dev/null |
        command sed -ne 's/^\(.*\)\.k\{0,1\}o\(\.[gx]z\)\{0,1\}$/\1/p' \
            -e 's/^\(.*\)\.ko\.zst$/\1/p')" -- "$cur"))
}

# This function completes on installed modules
#
_installed_modules()
{
    COMPREPLY=($(compgen -W "$(PATH="$PATH:/sbin" lsmod |
        awk '{if (NR != 1) print $1}')" -- "$1"))
}

# This function completes on user or user:group format; as for chown and cpio.
#
# The : must be added manually; it will only complete usernames initially.
# The legacy user.group format is not supported.
#
# @param $1  If -u, only return users/groups the user has access to in
#            context of current completion.
_usergroup()
{
    if [[ $cur == *\\\\* || $cur == *:*:* ]]; then
        # Give up early on if something seems horribly wrong.
        return
    elif [[ $cur == *\\:* ]]; then
        # Completing group after 'user\:gr<TAB>'.
        # Reply with a list of groups prefixed with 'user:', readline will
        # escape to the colon.
        local prefix
        prefix=${cur%%*([^:])}
        prefix=${prefix//\\/}
        local mycur=${cur#*[:]}
        if [[ ${1-} == -u ]]; then
            _allowed_groups "$mycur"
        else
            local IFS=$'\n'
            COMPREPLY=($(compgen -g -- "$mycur"))
        fi
        ((${#COMPREPLY[@]})) &&
            COMPREPLY=($(compgen -P "$prefix" -W '"${COMPREPLY[@]}"'))
    elif [[ $cur == *:* ]]; then
        # Completing group after 'user:gr<TAB>'.
        # Reply with a list of unprefixed groups since readline with split on :
        # and only replace the 'gr' part
        local mycur=${cur#*:}
        if [[ ${1-} == -u ]]; then
            _allowed_groups "$mycur"
        else
            local IFS=$'\n'
            COMPREPLY=($(compgen -g -- "$mycur"))
        fi
    else
        # Completing a partial 'usernam<TAB>'.
        #
        # Don't suffix with a : because readline will escape it and add a
        # slash. It's better to complete into 'chown username ' than 'chown
        # username\:'.
        if [[ ${1-} == -u ]]; then
            _allowed_users "$cur"
        else
            local IFS=$'\n'
            COMPREPLY=($(compgen -u -- "$cur"))
        fi
    fi
}

_allowed_users()
{
    if _complete_as_root; then
        local IFS=$'\n'
        COMPREPLY=($(compgen -u -- "${1:-$cur}"))
    else
        local IFS=$'\n '
        COMPREPLY=($(compgen -W \
            "$(id -un 2>/dev/null || whoami 2>/dev/null)" -- "${1:-$cur}"))
    fi
}

_allowed_groups()
{
    if _complete_as_root; then
        local IFS=$'\n'
        COMPREPLY=($(compgen -g -- "$1"))
    else
        local IFS=$'\n '
        COMPREPLY=($(compgen -W \
            "$(id -Gn 2>/dev/null || groups 2>/dev/null)" -- "$1"))
    fi
}

_comp_selinux_users()
{
    COMPREPLY+=($(compgen -W '$(
        semanage user -nl 2>/dev/null | awk "{ print \$1 }"
    )' -- "$cur"))
}

# This function completes on valid shells
#
# @param $1 chroot to search from
_shells()
{
    local shell rest
    while read -r shell rest; do
        [[ $shell == /* && $shell == "$cur"* ]] && COMPREPLY+=($shell)
    done 2>/dev/null <"${1-}"/etc/shells
}

# This function completes on valid filesystem types
#
_fstypes()
{
    local fss

    if [[ -e /proc/filesystems ]]; then
        # Linux
        fss="$(cut -d$'\t' -f2 /proc/filesystems)
             $(awk '! /\*/ { print $NF }' /etc/filesystems 2>/dev/null)"
    else
        # Generic
        fss="$(awk '/^[ \t]*[^#]/ { print $3 }' /etc/fstab 2>/dev/null)
             $(awk '/^[ \t]*[^#]/ { print $3 }' /etc/mnttab 2>/dev/null)
             $(awk '/^[ \t]*[^#]/ { print $4 }' /etc/vfstab 2>/dev/null)
             $(awk '{ print $1 }' /etc/dfs/fstypes 2>/dev/null)
             $(lsvfs 2>/dev/null | awk '$1 !~ /^(Filesystem|[^a-zA-Z])/ { print $1 }')
             $([[ -d /etc/fs ]] && command ls /etc/fs)"
    fi

    [[ $fss ]] && COMPREPLY+=($(compgen -W "$fss" -- "$cur"))
}

# Get real command.
# - arg: $1  Command
# - stdout:  Filename of command in PATH with possible symbolic links resolved.
#            Empty string if command not found.
# - return:  True (0) if command found, False (> 0) if not.
_realcommand()
{
    type -P "$1" >/dev/null && {
        if type -p realpath >/dev/null; then
            realpath "$(type -P "$1")"
        elif type -p greadlink >/dev/null; then
            greadlink -f "$(type -P "$1")"
        elif type -p readlink >/dev/null; then
            readlink -f "$(type -P "$1")"
        else
            type -P "$1"
        fi
    }
}

# This function returns the first argument, excluding options
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. See __reassemble_comp_words_by_ref.
_get_first_arg()
{
    local i

    arg=
    for ((i = 1; i < COMP_CWORD; i++)); do
        if [[ ${COMP_WORDS[i]} != -* ]]; then
            arg=${COMP_WORDS[i]}
            break
        fi
    done
}

# This function counts the number of args, excluding options
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. See __reassemble_comp_words_by_ref.
# @param $2 glob   Options whose following argument should not be counted
# @param $3 glob   Options that should be counted as args
_count_args()
{
    local i cword words
    __reassemble_comp_words_by_ref "${1-}" words cword

    args=1
    for ((i = 1; i < cword; i++)); do
        # shellcheck disable=SC2053
        if [[ ${words[i]} != -* && ${words[i - 1]} != ${2-} ||
            ${words[i]} == ${3-} ]]; then
            ((args++))
        fi
    done
}

# This function completes on PCI IDs
#
_pci_ids()
{
    COMPREPLY+=($(compgen -W \
        "$(PATH="$PATH:/sbin" lspci -n | awk '{print $3}')" -- "$cur"))
}

# This function completes on USB IDs
#
_usb_ids()
{
    COMPREPLY+=($(compgen -W \
        "$(PATH="$PATH:/sbin" lsusb | awk '{print $6}')" -- "$cur"))
}

# CD device names
_cd_devices()
{
    COMPREPLY+=($(compgen -f -d -X "!*/?([amrs])cd*" -- "${cur:-/dev/}"))
}

# DVD device names
_dvd_devices()
{
    COMPREPLY+=($(compgen -f -d -X "!*/?(r)dvd*" -- "${cur:-/dev/}"))
}

# TERM environment variable values
_terms()
{
    COMPREPLY+=($(compgen -W "$({
        command sed -ne 's/^\([^[:space:]#|]\{2,\}\)|.*/\1/p' /etc/termcap
        {
            toe -a || toe
        } | awk '{ print $1 }'
        _comp_expand_glob dirs '/{etc,lib,usr/lib,usr/share}/terminfo/?'
        ((${#dirs[@]})) &&
            find "${dirs[@]}" -type f -maxdepth 1 |
            awk -F/ '{ print $NF }'
    } 2>/dev/null)" -- "$cur"))
}

_bashcomp_try_faketty()
{
    if type unbuffer &>/dev/null; then
        unbuffer -p "$@"
    elif script --version 2>&1 | command grep -qF util-linux; then
        # BSD and Solaris "script" do not seem to have required features
        script -qaefc "$*" /dev/null
    else
        "$@" # no can do, fallback
    fi
}

# a little help for FreeBSD ports users
[[ $OSTYPE == *freebsd* ]] && complete -W 'index search fetch fetch-list
    extract patch configure build install reinstall deinstall clean
    clean-depends kernel buildworld' make

# This function provides simple user@host completion
#
_user_at_host()
{
    local cur prev words cword
    _init_completion -n : || return

    if [[ $cur == *@* ]]; then
        _known_hosts_real "$cur"
    else
        COMPREPLY=($(compgen -u -S @ -- "$cur"))
        compopt -o nospace
    fi
}
shopt -u hostcomplete && complete -F _user_at_host talk ytalk finger

# NOTE: Using this function as a helper function is deprecated.  Use
#       `_known_hosts_real' instead.
_known_hosts()
{
    local cur prev words cword
    _init_completion -n : || return

    # NOTE: Using `_known_hosts' as a helper function and passing options
    #       to `_known_hosts' is deprecated: Use `_known_hosts_real' instead.
    local options
    [[ ${1-} == -a || ${2-} == -a ]] && options=-a
    [[ ${1-} == -c || ${2-} == -c ]] && options+=" -c"
    _known_hosts_real ${options-} -- "$cur"
} # _known_hosts()

# Helper function to locate ssh included files in configs
# This function looks for the "Include" keyword in ssh config files and
# includes them recursively, adding each result to the config variable.
_included_ssh_config_files()
{
    (($# < 1)) &&
        echo "bash_completion: $FUNCNAME: missing mandatory argument CONFIG" >&2
    local configfile i files f
    configfile=$1

    local IFS=$' \t\n' reset=$(shopt -po noglob)
    set -o noglob
    local included=($(command sed -ne 's/^[[:blank:]]*[Ii][Nn][Cc][Ll][Uu][Dd][Ee][[:blank:]]\(.*\)$/\1/p' "${configfile}"))
    $reset

    [[ ${included-} ]] || return
    for i in "${included[@]}"; do
        # Check the origin of $configfile to complete relative included paths on included
        # files according to ssh_config(5):
        #  "[...] Files without absolute paths are assumed to be in ~/.ssh if included in a user
        #   configuration file or /etc/ssh if included from the system configuration file.[...]"
        if ! [[ $i =~ ^\~.*|^\/.* ]]; then
            if [[ $configfile =~ ^\/etc\/ssh.* ]]; then
                i="/etc/ssh/$i"
            else
                i="$HOME/.ssh/$i"
            fi
        fi
        __expand_tilde_by_ref i
        # In case the expanded variable contains multiple paths
        _comp_expand_glob files '$i'
        if ((${#files[@]})); then
            for f in "${files[@]}"; do
                if [[ -r $f ]]; then
                    config+=("$f")
                    # The Included file is processed to look for Included files in itself
                    _included_ssh_config_files $f
                fi
            done
        fi
    done
} # _included_ssh_config_files()

# Helper function for completing _known_hosts.
# This function performs host completion based on ssh's config and known_hosts
# files, as well as hostnames reported by avahi-browse if
# BASH_COMPLETION_KNOWN_HOSTS_WITH_AVAHI is set to a non-empty value.
# Also hosts from HOSTFILE (compgen -A hostname) are added, unless
# BASH_COMPLETION_KNOWN_HOSTS_WITH_HOSTFILE is set to an empty value.
# Usage: _known_hosts_real [OPTIONS] CWORD
# Options:
#     -a             Use aliases from ssh config files
#     -c             Use `:' suffix
#     -F configfile  Use `configfile' for configuration settings
#     -p PREFIX      Use PREFIX
#     -4             Filter IPv6 addresses from results
#     -6             Filter IPv4 addresses from results
# @return Completions, starting with CWORD, are added to COMPREPLY[]
_known_hosts_real()
{
    local configfile flag prefix=""
    local cur suffix="" aliases i host ipv4 ipv6
    local -a kh tmpkh=() khd=() config=()

    # TODO remove trailing %foo from entries

    local OPTIND=1
    while getopts "ac46F:p:" flag "$@"; do
        case $flag in
            a) aliases='yes' ;;
            c) suffix=':' ;;
            F) configfile=$OPTARG ;;
            p) prefix=$OPTARG ;;
            4) ipv4=1 ;;
            6) ipv6=1 ;;
            *)
                echo "bash_completion: $FUNCNAME: usage error" >&2
                return 1
                ;;
        esac
    done
    if (($# < OPTIND)); then
        echo "bash_completion: $FUNCNAME: missing mandatory argument CWORD" >&2
        return 1
    fi
    cur=${!OPTIND}
    ((OPTIND += 1))
    if (($# >= OPTIND)); then
        echo "bash_completion: $FUNCNAME($*): unprocessed arguments:" \
            "$(while (($# >= OPTIND)); do
                printf '%s ' ${!OPTIND}
                shift
            done)" >&2
        return 1
    fi

    [[ $cur == *@* ]] && prefix=$prefix${cur%@*}@ && cur=${cur#*@}
    kh=()

    # ssh config files
    if [[ -v configfile ]]; then
        [[ -r $configfile ]] && config+=("$configfile")
    else
        for i in /etc/ssh/ssh_config ~/.ssh/config ~/.ssh2/config; do
            [[ -r $i ]] && config+=("$i")
        done
    fi

    local reset=$(shopt -po noglob)
    set -o noglob

    # "Include" keyword in ssh config files
    if ((${#config[@]} > 0)); then
        for i in "${config[@]}"; do
            _included_ssh_config_files "$i"
        done
    fi

    # Known hosts files from configs
    if ((${#config[@]} > 0)); then
        local IFS=$'\n'
        # expand paths (if present) to global and user known hosts files
        # TODO(?): try to make known hosts files with more than one consecutive
        #          spaces in their name work (watch out for ~ expansion
        #          breakage! Alioth#311595)
        tmpkh=($(awk 'sub("^[ \t]*([Gg][Ll][Oo][Bb][Aa][Ll]|[Uu][Ss][Ee][Rr])[Kk][Nn][Oo][Ww][Nn][Hh][Oo][Ss][Tt][Ss][Ff][Ii][Ll][Ee][ \t=]+", "") { print $0 }' "${config[@]}" | sort -u))
        _comp_unlocal IFS
    fi
    if ((${#tmpkh[@]} != 0)); then
        local j
        for i in "${tmpkh[@]}"; do
            # First deal with quoted entries...
            while [[ $i =~ ^([^\"]*)\"([^\"]*)\"(.*)$ ]]; do
                i=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
                j=${BASH_REMATCH[2]}
                __expand_tilde_by_ref j # Eval/expand possible `~' or `~user'
                [[ -r $j ]] && kh+=("$j")
            done
            # ...and then the rest.
            for j in $i; do
                __expand_tilde_by_ref j # Eval/expand possible `~' or `~user'
                [[ -r $j ]] && kh+=("$j")
            done
        done
    fi

    if [[ ! -v configfile ]]; then
        # Global and user known_hosts files
        for i in /etc/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts2 \
            /etc/known_hosts /etc/known_hosts2 ~/.ssh/known_hosts \
            ~/.ssh/known_hosts2; do
            [[ -r $i ]] && kh+=("$i")
        done
        for i in /etc/ssh2/knownhosts ~/.ssh2/hostkeys; do
            [[ -d $i ]] && khd+=("$i"/*pub)
        done
    fi

    # If we have known_hosts files to use
    if ((${#kh[@]} + ${#khd[@]} > 0)); then
        if ((${#kh[@]} > 0)); then
            # https://man.openbsd.org/sshd.8#SSH_KNOWN_HOSTS_FILE_FORMAT
            for i in "${kh[@]}"; do
                while read -ra tmpkh; do
                    ((${#tmpkh[@]} == 0)) && continue
                    set -- "${tmpkh[@]}"
                    # Skip entries starting with | (hashed) and # (comment)
                    [[ $1 == [\|\#]* ]] && continue
                    # Ignore leading @foo (markers)
                    [[ $1 == @* ]] && shift
                    # Split entry on commas
                    local IFS=,
                    for host in $1; do
                        # Skip hosts containing wildcards
                        [[ $host == *[*?]* ]] && continue
                        # Remove leading [
                        host=${host#[}
                        # Remove trailing ] + optional :port
                        host=${host%]?(:+([0-9]))}
                        # Add host to candidates
                        COMPREPLY+=($host)
                    done
                    _comp_unlocal IFS
                done <"$i"
            done
            ((${#COMPREPLY[@]})) &&
                COMPREPLY=($(compgen -W '"${COMPREPLY[@]}"' -- "$cur"))
        fi
        if ((${#khd[@]} > 0)); then
            # Needs to look for files called
            # .../.ssh2/key_22_<hostname>.pub
            # dont fork any processes, because in a cluster environment,
            # there can be hundreds of hostkeys
            for i in "${khd[@]}"; do
                if [[ $i == *key_22_$cur*.pub && -r $i ]]; then
                    host=${i/#*key_22_/}
                    host=${host/%.pub/}
                    COMPREPLY+=($host)
                fi
            done
        fi

        # apply suffix and prefix
        if ((${#COMPREPLY[@]})); then
            for i in ${!COMPREPLY[*]}; do
                COMPREPLY[i]=$prefix${COMPREPLY[i]}$suffix
            done
        fi
    fi

    # append any available aliases from ssh config files
    if [[ ${#config[@]} -gt 0 && -v aliases ]]; then
        local -a hosts=($(command sed -ne 's/^[[:blank:]]*[Hh][Oo][Ss][Tt][[:blank:]=]\{1,\}\(.*\)$/\1/p' "${config[@]}"))
        if ((${#hosts[@]} != 0)); then
            COMPREPLY+=($(compgen -P "$prefix" \
                -S "$suffix" -W '"${hosts[@]%%[*?%]*}"' -X '@(\!*|)' -- "$cur"))
        fi
    fi

    # Add hosts reported by avahi-browse, if desired and it's available.
    if [[ ${BASH_COMPLETION_KNOWN_HOSTS_WITH_AVAHI-${COMP_KNOWN_HOSTS_WITH_AVAHI-}} ]] &&
        type avahi-browse &>/dev/null; then
        # Some old versions of avahi-browse reportedly didn't have -k
        # (even if mentioned in the manpage); those we do not support any more.
        COMPREPLY+=($(compgen -P "$prefix" -S "$suffix" -W \
            "$(avahi-browse -cprak 2>/dev/null | awk -F';' \
                '/^=/ && $5 ~ /^_(ssh|workstation)\._tcp$/ { print $7 }' |
                sort -u)" -- "$cur"))
    fi

    # Add hosts reported by ruptime.
    if type ruptime &>/dev/null; then
        COMPREPLY+=($(compgen -W \
            "$(ruptime 2>/dev/null | awk '!/^ruptime:/ { print $1 }')" \
            -- "$cur"))
    fi

    # Add results of normal hostname completion, unless
    # `BASH_COMPLETION_KNOWN_HOSTS_WITH_HOSTFILE' is set to an empty value.
    if [[ ${BASH_COMPLETION_KNOWN_HOSTS_WITH_HOSTFILE-${COMP_KNOWN_HOSTS_WITH_HOSTFILE-1}} ]]; then
        COMPREPLY+=(
            $(compgen -A hostname -P "$prefix" -S "$suffix" -- "$cur"))
    fi

    $reset

    if ((${#COMPREPLY[@]})); then
        if [[ -v ipv4 ]]; then
            COMPREPLY=("${COMPREPLY[@]/*:*$suffix/}")
        fi
        if [[ -v ipv6 ]]; then
            COMPREPLY=("${COMPREPLY[@]/+([0-9]).+([0-9]).+([0-9]).+([0-9])$suffix/}")
        fi
        if [[ -v ipv4 || -v ipv6 ]]; then
            for i in "${!COMPREPLY[@]}"; do
                [[ ${COMPREPLY[i]} ]] || unset -v 'COMPREPLY[i]'
            done
        fi
    fi

    __ltrim_colon_completions "$prefix$cur"

} # _known_hosts_real()
complete -F _known_hosts traceroute traceroute6 \
    fping fping6 telnet rsh rlogin ftp dig mtr ssh-installkeys showmount

# This meta-cd function observes the CDPATH variable, so that cd additionally
# completes on directories under those specified in CDPATH.
#
_cd()
{
    local cur prev words cword
    _init_completion || return

    local IFS=$'\n' i j k

    compopt -o filenames

    # Use standard dir completion if no CDPATH or parameter starts with /,
    # ./ or ../
    if [[ ! ${CDPATH:-} || $cur == ?(.)?(.)/* ]]; then
        _filedir -d
        return
    fi

    local mark_dirs='' mark_symdirs=''
    _comp_readline_variable_on mark-directories && mark_dirs=y
    _comp_readline_variable_on mark-symlinked-directories && mark_symdirs=y

    # we have a CDPATH, so loop on its contents
    for i in ${CDPATH//:/$'\n'}; do
        # create an array of matched subdirs
        k=${#COMPREPLY[@]}
        for j in $(compgen -d -- $i/$cur); do
            if [[ ($mark_symdirs && -L $j || $mark_dirs && ! -L $j) && ! -d ${j#"$i/"} ]]; then
                j+="/"
            fi
            COMPREPLY[k++]=${j#"$i/"}
        done
    done

    _filedir -d

    if ((${#COMPREPLY[@]} == 1)); then
        i=${COMPREPLY[0]}
        if [[ $i == "$cur" && $i != "*/" ]]; then
            COMPREPLY[0]="${i}/"
        fi
    fi

    return
}
if shopt -q cdable_vars; then
    complete -v -F _cd -o nospace cd pushd
else
    complete -F _cd -o nospace cd pushd
fi

# A _command_offset wrapper function for use when the offset is unknown.
# Only intended to be used as a completion function directly associated
# with a command, not to be invoked from within other completion functions.
#
_command()
{
    local offset i

    # find actual offset, as position of the first non-option
    offset=1
    for ((i = 1; i <= COMP_CWORD; i++)); do
        if [[ ${COMP_WORDS[i]} != -* ]]; then
            offset=$i
            break
        fi
    done
    _command_offset $offset
}

# A meta-command completion function for commands like sudo(8), which need to
# first complete on a command, then complete according to that command's own
# completion definition.
#
_command_offset()
{
    # rewrite current completion context before invoking
    # actual command completion

    # find new first word position, then
    # rewrite COMP_LINE and adjust COMP_POINT
    local word_offset=$1 i j
    for ((i = 0; i < word_offset; i++)); do
        for ((j = 0; j <= ${#COMP_LINE}; j++)); do
            [[ $COMP_LINE == "${COMP_WORDS[i]}"* ]] && break
            COMP_LINE=${COMP_LINE:1}
            ((COMP_POINT--))
        done
        COMP_LINE=${COMP_LINE#"${COMP_WORDS[i]}"}
        ((COMP_POINT -= ${#COMP_WORDS[i]}))
    done

    # shift COMP_WORDS elements and adjust COMP_CWORD
    for ((i = 0; i <= COMP_CWORD - word_offset; i++)); do
        COMP_WORDS[i]=${COMP_WORDS[i + word_offset]}
    done
    for ((i; i <= COMP_CWORD; i++)); do
        unset -v 'COMP_WORDS[i]'
    done
    ((COMP_CWORD -= word_offset))

    COMPREPLY=()
    local cur
    _get_comp_words_by_ref cur

    if ((COMP_CWORD == 0)); then
        local IFS=$'\n'
        compopt -o filenames
        COMPREPLY=($(compgen -d -c -- "$cur"))
    else
        local cmd=${COMP_WORDS[0]} compcmd=${COMP_WORDS[0]}
        local cspec=$(complete -p "$cmd" 2>/dev/null)

        # If we have no completion for $cmd yet, see if we have for basename
        if [[ ! $cspec && $cmd == */* ]]; then
            cspec=$(complete -p "${cmd##*/}" 2>/dev/null)
            [[ $cspec ]] && compcmd=${cmd##*/}
        fi
        # If still nothing, just load it for the basename
        if [[ ! $cspec ]]; then
            compcmd=${cmd##*/}
            _completion_loader "$compcmd"
            cspec=$(complete -p "$compcmd" 2>/dev/null)
        fi

        local retry_count=0
        while true; do # loop for the retry request by status 124
            if [[ ! $cspec ]]; then
                if ((${#COMPREPLY[@]} == 0)); then
                    # XXX will probably never happen as long as completion loader loads
                    #     *something* for every command thrown at it ($cspec != empty)
                    _minimal
                fi
            elif [[ $cspec == *' -F '* ]]; then
                # complete -F <function>

                # get function name
                local func=${cspec#* -F }
                func=${func%% *}

                if ((${#COMP_WORDS[@]} >= 2)); then
                    $func "$cmd" "${COMP_WORDS[-1]}" "${COMP_WORDS[-2]}"
                else
                    $func "$cmd" "${COMP_WORDS[-1]}"
                fi

                # restart completion (once) if function exited with 124
                if (($? == 124 && retry_count++ == 0)); then
                    # Note: When the completion function returns 124, the state
                    # of COMPREPLY is discarded.
                    COMPREPLY=()

                    cspec=$(complete -p "$compcmd" 2>/dev/null)

                    # Note: When completion spec is removed after 124, we do
                    # not generate any completions including the default ones.
                    # This is the behavior of the original Bash progcomp.
                    [[ $cspec ]] || break

                    continue
                fi

                # restore initial compopts
                local opt
                while [[ $cspec == *" -o "* ]]; do
                    # FIXME: should we take "+o opt" into account?
                    cspec=${cspec#*-o }
                    opt=${cspec%% *}
                    compopt -o $opt
                    cspec=${cspec#"$opt"}
                done
            else
                cspec=${cspec#complete}
                cspec=${cspec%%"$compcmd"}
                COMPREPLY=($(eval compgen "$cspec" -- '$cur'))
            fi
            break
        done
    fi
}
complete -F _command aoss command "do" else eval exec ltrace nice nohup padsp \
    "then" time tsocks vsound xargs

_root_command()
{
    local PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
    local root_command=$1
    _command
}
complete -F _root_command fakeroot gksu gksudo kdesudo really

# Return true if the completion should be treated as running as root
_complete_as_root()
{
    [[ $EUID -eq 0 || ${root_command:-} ]]
}

_longopt()
{
    local cur prev words cword split
    _init_completion -s || return

    case "${prev,,}" in
        --help | --usage | --version)
            return
            ;;
        --!(no-*)dir*)
            _filedir -d
            return
            ;;
        --!(no-*)@(file|path)*)
            _filedir
            return
            ;;
        --+([-a-z0-9_]))
            local argtype=$(LC_ALL=C $1 --help 2>&1 | command sed -ne \
                "s|.*$prev\[\{0,1\}=[<[]\{0,1\}\([-A-Za-z0-9_]\{1,\}\).*|\1|p")
            case ${argtype,,} in
                *dir*)
                    _filedir -d
                    return
                    ;;
                *file* | *path*)
                    _filedir
                    return
                    ;;
            esac
            ;;
    esac

    $split && return

    if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "$(LC_ALL=C $1 --help 2>&1 |
            while read -r line; do
                [[ $line =~ --[A-Za-z0-9]+([-_][A-Za-z0-9]+)*=? ]] &&
                    printf '%s\n' ${BASH_REMATCH[0]}
            done)" -- "$cur"))
        [[ ${COMPREPLY-} == *= ]] && compopt -o nospace
    elif [[ $1 == *@(rmdir|chroot) ]]; then
        _filedir -d
    else
        [[ $1 == *mkdir ]] && compopt -o nospace
        _filedir
    fi
}
# makeinfo and texi2dvi are defined elsewhere.
complete -F _longopt a2ps awk base64 bash bc bison cat chroot colordiff cp \
    csplit cut date df diff dir du enscript env expand fmt fold gperf \
    grep grub head irb ld ldd less ln ls m4 mkdir mkfifo mknod \
    mv netstat nl nm objcopy objdump od paste pr ptx readelf rm rmdir \
    sed seq shar sort split strip sum tac tail tee \
    texindex touch tr uname unexpand uniq units vdir wc who

declare -Ag _xspecs

_filedir_xspec()
{
    local cur prev words cword
    _init_completion || return

    _tilde "$cur" || return

    local IFS=$'\n' xspec=${_xspecs[${1##*/}]} tmp
    local -a toks

    toks=($(
        compgen -d -- "$(quote_readline "$cur")" | {
            while read -r tmp; do
                printf '%s\n' $tmp
            done
        }
    ))

    # Munge xspec to contain uppercase version too
    # https://lists.gnu.org/archive/html/bug-bash/2010-09/msg00036.html
    # news://news.gmane.io/4C940E1C.1010304@case.edu
    eval xspec="${xspec}"
    local matchop=!
    if [[ $xspec == !* ]]; then
        xspec=${xspec#!}
        matchop=@
    fi
    xspec="$matchop($xspec|${xspec^^})"

    toks+=($(
        eval compgen -f -X "'!$xspec'" -- '$(quote_readline "$cur")' | {
            while read -r tmp; do
                [[ $tmp ]] && printf '%s\n' $tmp
            done
        }
    ))

    # Try without filter if it failed to produce anything and configured to
    [[ ${BASH_COMPLETION_FILEDIR_FALLBACK-${COMP_FILEDIR_FALLBACK-}} &&
        ${#toks[@]} -lt 1 ]] && {
        local reset=$(shopt -po noglob)
        set -o noglob
        toks+=($(compgen -f -- "$(quote_readline "$cur")"))
        IFS=' '
        $reset
        IFS=$'\n'
    }

    if ((${#toks[@]} != 0)); then
        compopt -o filenames
        COMPREPLY=("${toks[@]}")
    fi
}

_install_xspec()
{
    local xspec=$1 cmd
    shift
    for cmd in "$@"; do
        _xspecs[$cmd]=$xspec
    done
}
# bzcmp, bzdiff, bz*grep, bzless, bzmore intentionally not here, see Debian: #455510
_install_xspec '!*.?(t)bz?(2)' bunzip2 bzcat pbunzip2 pbzcat lbunzip2 lbzcat
_install_xspec '!*.@(zip|[aegjkswx]ar|exe|pk3|wsz|zargo|xpi|s[tx][cdiw]|sx[gm]|o[dt][tspgfc]|od[bm]|oxt|?(o)xps|epub|cbz|apk|aab|ipa|do[ct][xm]|p[op]t[mx]|xl[st][xm]|pyz|whl|[Ff][Cc][Ss]td)' unzip zipinfo
_install_xspec '*.Z' compress znew
# zcmp, zdiff, z*grep, zless, zmore intentionally not here, see Debian: #455510
_install_xspec '!*.@(Z|[gGd]z|t[ag]z)' gunzip zcat
_install_xspec '!*.@(Z|[gGdz]z|t[ag]z)' unpigz
_install_xspec '!*.Z' uncompress
# lzcmp, lzdiff intentionally not here, see Debian: #455510
_install_xspec '!*.@(tlz|lzma)' lzcat lzegrep lzfgrep lzgrep lzless lzmore unlzma
_install_xspec '!*.@(?(t)xz|tlz|lzma)' unxz xzcat
_install_xspec '!*.lrz' lrunzip
_install_xspec '!*.@(gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx)' ee
_install_xspec '!*.@(gif|jp?(e)g|tif?(f)|png|p[bgp]m|bmp|x[bp]m|rle|rgb|pcx|fits|pm|svg)' qiv
_install_xspec '!*.@(gif|jp?(e)g?(2)|j2[ck]|jp[2f]|tif?(f)|png|p[bgp]m|bmp|x[bp]m|rle|rgb|pcx|fits|pm|?(e)ps)' xv
_install_xspec '!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv kghostview
_install_xspec '!*.@(dvi|DVI)?(.@(gz|Z|bz2))' xdvi kdvi
_install_xspec '!*.dvi' dvips dviselect dvitype dvipdf advi dvipdfm dvipdfmx
_install_xspec '!*.[pf]df' acroread gpdf xpdf
_install_xspec '!*.@(?(e)ps|pdf)' kpdf
_install_xspec '!*.@(okular|@(?(e|x)ps|?(E|X)PS|[pf]df|[PF]DF|dvi|DVI|cb[rz]|CB[RZ]|djv?(u)|DJV?(U)|dvi|DVI|gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx|GIF|JP?(E)G|MIFF|TIF?(F)|PN[GM]|P[BGP]M|BMP|XPM|ICO|XWD|TGA|PCX|epub|EPUB|odt|ODT|fb?(2)|FB?(2)|mobi|MOBI|g3|G3|chm|CHM|md|markdown)?(.?(gz|GZ|bz2|BZ2|xz|XZ)))' okular
_install_xspec '!*.pdf' epdfview pdfunite
_install_xspec '!*.@(cb[rz7t]|djv?(u)|?(e)ps|pdf)' zathura
_install_xspec '!*.@(?(e)ps|pdf)' ps2pdf ps2pdf12 ps2pdf13 ps2pdf14 ps2pdfwr
_install_xspec '!*.texi*' makeinfo texi2html
_install_xspec '!*.@(?(la)tex|texi|dtx|ins|ltx|dbj)' tex latex slitex jadetex pdfjadetex pdftex pdflatex texi2dvi xetex xelatex luatex lualatex
_install_xspec '!*.mp3' mpg123 mpg321 madplay
_install_xspec '!*@(.@(mp?(e)g|MP?(E)G|wm[av]|WM[AV]|avi|AVI|asf|vob|VOB|bin|dat|divx|DIVX|vcd|ps|pes|fli|flv|FLV|fxm|FXM|viv|rm|ram|yuv|mov|MOV|qt|QT|web[am]|WEB[AM]|mp[234]|MP[234]|m?(p)4[av]|M?(P)4[AV]|mkv|MKV|og[agmv]|OG[AGMV]|t[ps]|T[PS]|m2t?(s)|M2T?(S)|mts|MTS|wav|WAV|flac|FLAC|asx|ASX|mng|MNG|srt|m[eo]d|M[EO]D|s[3t]m|S[3T]M|it|IT|xm|XM)|+([0-9]).@(vdr|VDR))?(.@(crdownload|part))' xine aaxine cacaxine fbxine
_install_xspec '!*@(.@(mp?(e)g|MP?(E)G|wm[av]|WM[AV]|avi|AVI|asf|vob|VOB|bin|dat|divx|DIVX|vcd|ps|pes|fli|flv|FLV|fxm|FXM|viv|rm|ram|yuv|mov|MOV|qt|QT|web[am]|WEB[AM]|mp[234]|MP[234]|m?(p)4[av]|M?(P)4[AV]|mkv|MKV|og[agmv]|OG[AGMV]|opus|OPUS|t[ps]|T[PS]|m2t?(s)|M2T?(S)|mts|MTS|wav|WAV|flac|FLAC|asx|ASX|mng|MNG|srt|m[eo]d|M[EO]D|s[3t]m|S[3T]M|it|IT|xm|XM|iso|ISO)|+([0-9]).@(vdr|VDR))?(.@(crdownload|part))' kaffeine dragon totem
_install_xspec '!*.@(avi|asf|wmv)' aviplay
_install_xspec '!*.@(rm?(j)|ra?(m)|smi?(l))' realplay
_install_xspec '!*.@(mpg|mpeg|avi|mov|qt)' xanim
_install_xspec '!*.@(og[ag]|m3u|flac|spx)' ogg123
_install_xspec '!*.@(mp3|ogg|pls|m3u)' gqmpeg freeamp
_install_xspec '!*.fig' xfig
_install_xspec '!*.@(mid?(i)|cmf)' playmidi
_install_xspec '!*.@(mid?(i)|rmi|rcp|[gr]36|g18|mod|xm|it|x3m|s[3t]m|kar)' timidity
_install_xspec '!*.@(669|abc|am[fs]|d[bs]m|dmf|far|it|mdl|m[eo]d|mid?(i)|mt[2m]|oct|okt?(a)|p[st]m|s[3t]m|ult|umx|wav|xm)' modplugplay modplug123
_install_xspec '*.@([ao]|so|so.!(conf|*/*)|[rs]pm|gif|jp?(e)g|mp3|mp?(e)g|avi|asf|ogg|class)' vi vim gvim rvim view rview rgvim rgview gview emacs xemacs sxemacs kate kwrite
_install_xspec '!*.@(zip|z|gz|tgz)' bzme
# konqueror not here on purpose, it's more than a web/html browser
_install_xspec '!*.@(?([xX]|[sS])[hH][tT][mM]?([lL]))' netscape mozilla lynx galeon dillo elinks amaya epiphany
_install_xspec '!*.@(sxw|stw|sxg|sgl|doc?([mx])|dot?([mx])|rtf|txt|htm|html|?(f)odt|ott|odm|pdf)' oowriter lowriter
_install_xspec '!*.@(sxi|sti|pps?(x)|ppt?([mx])|pot?([mx])|?(f)odp|otp)' ooimpress loimpress
_install_xspec '!*.@(sxc|stc|xls?([bmx])|xlw|xlt?([mx])|[ct]sv|?(f)ods|ots)' oocalc localc
_install_xspec '!*.@(sxd|std|sda|sdd|?(f)odg|otg)' oodraw lodraw
_install_xspec '!*.@(sxm|smf|mml|odf)' oomath lomath
_install_xspec '!*.odb' oobase lobase
_install_xspec '!*.[rs]pm' rpm2cpio
_install_xspec '!*.aux' bibtex
_install_xspec '!*.po' poedit gtranslator kbabel lokalize
_install_xspec '!*.@([Pp][Rr][Gg]|[Cc][Ll][Pp])' harbour gharbour hbpp
_install_xspec '!*.[Hh][Rr][Bb]' hbrun
_install_xspec '!*.ly' lilypond ly2dvi
_install_xspec '!*.@(dif?(f)|?(d)patch)?(.@([gx]z|bz2|lzma))' cdiff
_install_xspec '!@(*.@(ks|jks|jceks|p12|pfx|bks|ubr|gkr|cer|crt|cert|p7b|pkipath|pem|p10|csr|crl)|cacerts)' portecle
_install_xspec '!*.@(mp[234c]|og[ag]|@(fl|a)ac|m4[abp]|spx|tta|w?(a)v|wma|aif?(f)|asf|ape)' kid3 kid3-qt
unset -f _install_xspec

# Minimal completion to use as fallback in _completion_loader.
_minimal()
{
    local cur prev words cword split
    _init_completion -s || return
    $split && return
    _filedir
}
# Complete the empty string to allow completion of '>', '>>', and '<' on < 4.3
# https://lists.gnu.org/archive/html/bug-bash/2012-01/msg00045.html
complete -F _minimal ''

__load_completion()
{
    local -a dirs=(${BASH_COMPLETION_USER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion}/completions)
    local IFS=: dir cmd="${1##*/}" compfile
    [[ $cmd ]] || return 1
    for dir in ${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do
        dirs+=($dir/bash-completion/completions)
    done
    _comp_unlocal IFS

    if [[ $BASH_SOURCE == */* ]]; then
        dirs+=("${BASH_SOURCE%/*}/completions")
    else
        dirs+=(./completions)
    fi

    local backslash=
    if [[ $cmd == \\* ]]; then
        cmd=${cmd:1}
        # If we already have a completion for the "real" command, use it
        $(complete -p "$cmd" 2>/dev/null || echo false) "\\$cmd" && return 0
        backslash=\\
    fi

    for dir in "${dirs[@]}"; do
        [[ -d $dir ]] || continue
        for compfile in "$cmd" "$cmd.bash" "_$cmd"; do
            compfile="$dir/$compfile"
            # Avoid trying to source dirs; https://bugzilla.redhat.com/903540
            if [[ -d $compfile ]]; then
                echo "bash_completion: $compfile: is a directory" >&2
            elif [[ -e $compfile ]] && . "$compfile"; then
                [[ $backslash ]] && $(complete -p "$cmd") "\\$cmd"
                return 0
            fi
        done
    done

    # Look up simple "xspec" completions
    [[ -v _xspecs[$cmd] ]] &&
        complete -F _filedir_xspec "$cmd" "$backslash$cmd" && return 0

    return 1
}

# set up dynamic completion loading
_completion_loader()
{
    # $1=_EmptycmD_ already for empty cmds in bash 4.3, set to it for earlier
    local cmd=${1:-_EmptycmD_}

    __load_completion "$cmd" && return 124

    # Need to define *something*, otherwise there will be no completion at all.
    complete -F _minimal -- "$cmd" && return 124
} &&
    complete -D -F _completion_loader

# Function for loading and calling functions from dynamically loaded
# completion files that may not have been sourced yet.
# @param $1 completion file to load function from in case it is missing
# @param $2 the xfunc name.  When it does not start with `_',
#   `_comp_xfunc_${1//[^a-zA-Z0-9_]/_}_$2' is used for the actual name of the
#   shell function.
# @param $3... if any, specifies the arguments that are passed to the xfunc.
_comp_xfunc()
{
    local xfunc_name=$2
    [[ $xfunc_name == _* ]] ||
        xfunc_name=_comp_xfunc_${1//[^a-zA-Z0-9_]/_}_$xfunc_name
    declare -F "$xfunc_name" &>/dev/null || __load_completion "$1"
    "$xfunc_name" "${@:3}"
}

_comp_deprecate_func _xfunc _comp_xfunc

# source compat completion directory definitions
_comp__init_compat_dir=${BASH_COMPLETION_COMPAT_DIR:-/etc/bash_completion.d}
if [[ -d $_comp__init_compat_dir && -r $_comp__init_compat_dir && -x $_comp__init_compat_dir ]]; then
    for _comp__init_file in "$_comp__init_compat_dir"/*; do
        [[ ${_comp__init_file##*/} != @($_comp_backup_glob|Makefile*|${BASH_COMPLETION_COMPAT_IGNORE-}) &&
            -f $_comp__init_file && -r $_comp__init_file ]] && . "$_comp__init_file"
    done
fi
unset -v _comp__init_compat_dir _comp__init_file

# source user completion file
#
# Remark: We explicitly check that $user_completion is not '/dev/null' since
#   /dev/null may be a regular file in broken systems and can contain arbitrary
#   garbages of suppressed command outputs.
_comp__init_user_file=${BASH_COMPLETION_USER_FILE:-~/.bash_completion}
[[ $_comp__init_user_file != "${BASH_SOURCE[0]}" && $_comp__init_user_file != /dev/null && -r $_comp__init_user_file && -f $_comp__init_user_file ]] &&
    . $_comp__init_user_file
unset -v _comp__init_user_file

unset -f have
unset -v have

set $_comp__init_original_set_v
unset -v _comp__init_original_set_v

# ex: filetype=sh