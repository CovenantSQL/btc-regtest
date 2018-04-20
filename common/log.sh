#! /usr/bin/env bash

declare -r LOG_LEVEL_DEBUG=5
declare -r LOG_LEVEL_INFO=4
declare -r LOG_LEVEL_WARN=3
declare -r LOG_LEVEL_ERROR=2

declare -r LOG_STYLE_DEBUG="$(tput setaf 3)"
declare -r LOG_STYLE_INFO="$(tput setaf 2)"
declare -r LOG_STYLE_WARN="$(tput setaf 1)"
declare -r LOG_STYLE_ERROR="$(tput setaf 1)"
declare -r LOG_STYLE_RESET="$(tput sgr0)"

_set_log_level() {
    [[ $# -eq 1 ]] && [[ $1 =~ ^[[:digit:]]+$ ]] || return
    declare -g LOG_LEVEL=$1
}

_log_debug() {
    { [ $# -eq 0 ] || [[ ${LOG_LEVEL:-5} -lt $LOG_LEVEL_DEBUG ]]; } && return
    echo -e ${LOG_STYLE_DEBUG}$(date +"[%F %T]") "[DEBUG]" "$*"${LOG_STYLE_RESET}
}

_log_info() {
    { [ $# -eq 0 ] || [[ ${LOG_LEVEL:-5} -lt $LOG_LEVEL_INFO ]]; } && return
    echo -e ${LOG_STYLE_INFO}$(date +"[%F %T]") "[INFO]" "$*"${LOG_STYLE_RESET}
}

_log_warn() {
    { [ $# -eq 0 ] || [[ ${LOG_LEVEL:-5} -lt $LOG_LEVEL_WARN ]]; } && return
    echo -e ${LOG_STYLE_WARN}$(date +"[%F %T]") "[WARN]" "$*"${LOG_STYLE_RESET}
}

_log_error() {
    { [ $# -eq 0 ] || [[ ${LOG_LEVEL:-5} -lt $LOG_LEVEL_ERROR ]]; } && return
    echo -e ${LOG_STYLE_ERROR}$(date +"[%F %T]") "[ERROR]" "$*"${LOG_STYLE_RESET}
}
