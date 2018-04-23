#! /usr/bin/env bash

declare -r ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source $ROOT_DIR/common/log.sh

declare IMAGE=regtest

print_usage() {
    cat <<USAGE
$0 [OPTION]... [IMAGE]

    -h, --help              Display this help and exit

Default image name is "regtest".

USAGE
}

download_src() {
    local src_dir="${ROOT_DIR}/docker-files/src"

    mkdir -p "$src_dir" && cd "$src_dir"

    if [[ -d "$src_dir/db-4.8.30.NC" ]]; then
        rm -rf "$src_dir/db-4.8.30.NC"
    fi

    wget -qO- http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz | tar -vxz || return

    if ! [[ -d "$src_dir/bitcoin" ]]; then
        git clone https://github.com/bitcoin/bitcoin.git
    fi
}

build_image() {
    cd "${ROOT_DIR}/docker-files" && sudo docker build -t "$IMAGE" .
}

main() {
    # Parse options
    local args
    args=$(getopt -o h -l help -n $0 -- "$@")
    [[ $? -eq 0 ]] || { print_usage; return 1; }
    eval set -- "$args"

    local argc=0
    while true; do
        ((++argc))
        case "$1" in
            -h | --help)
                print_usage
                [[ $argc -eq 1 ]] && { [[ $# -eq 1 ]] || [[ $# -eq 2 ]] && [[ $2 = "--" ]]; }
                return
                ;;
            --)
                shift
                [[ -n "$1" ]] && IMAGE="$1"
                [[ $# -le 1 ]] || { print_usage; return 1; }
                break
                ;;
            *)
                _log_error "Unexpected option: $1"
                return 1
                ;;
        esac
    done

    # Build image
    download_src && build_image
}

main "$@"
