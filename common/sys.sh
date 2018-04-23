#! /usr/bin/env bash

_has_command() {
    for arg in "$@"; do
        if ! command -v $arg >/dev/null; then
            >&2 echo "Command not found: \"$arg\""
            return 1
        fi
    done
}

_has_executable() {
    for arg in "$@"; do
        if ! [[ -x $(which $arg) ]]; then
            >&2 echo "Executable file not found: \"$arg\""
            return 1
        fi
    done
}
