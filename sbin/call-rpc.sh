#! /usr/bin/env bash

declare -r ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source $ROOT_DIR/common/log.sh

declare NAME=

print_usage() {
    cat <<USAGE
$0 [-n NAME | -p PORT] RPC [ARG...]

    -h, --help              Display this help and exit
    -n, --name=NAME         Container name of the target node
    -p, --port=PORT         RPC port of the target node

Frequently-used RPCs:

    generate NUM
    getaccountaddress ACCOUNT
    getbalance
    getblockchaininfo
    getntworkinfo
    getpeerinfo
    getwalletinfo
    sendtoaddress ADDRESS AMOUNT ...

Check https://bitcoin.org/en/developer-reference#rpcs for details.

USAGE
}

call_rpc() {
    sudo docker exec "$NAME" bitcoin-cli -datadir=data "$@"
}

main() {
    # Parse options
    local args
    args=$(getopt -o hn:p: -l help,name:,port: -n $0 -- "$@")
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
            -n | --name)
                [[ -n "$NAME" ]] && _log_warn "Some option is overwritten by -n/--name"
                NAME="$2"
                shift 2
                ;;
            -p | --port)
                [[ -n "$NAME" ]] && _log_warn "Some option is overwritten by -p/--port"
                NAME="regtest-$2"
                shift 2
                ;;
            --)
                shift
                [[ -n "$NAME" ]] && [[ $# -gt 0 ]] || { print_usage; return 1; }
                break
                ;;
            *)
                _log_error "Unexpected option: $1"
                return 1
                ;;
        esac
    done

    call_rpc "$@"
}

main "$@"
