#! /usr/bin/env bash

declare -r ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source $ROOT_DIR/common/log.sh

declare -r IMAGE=regtest:latest
declare -r BTC_PORT=18444
declare -r RPC_PORT=18443

declare NODES=1
declare START_PORT=5000

print_usage() {
    cat <<USAGE
$0 [OPTION]...

    -h, --help              Display this help and exit
    -n, --nodes             Set node number
    -p, --start-port        Start port of a range

USAGE
}

start_new_nodes() {
    local ip=
    local port=
    local name=

    for ((i=0; i<NODES; i++)); do
        port=$((START_PORT+i))
        name="regtest-$port"

        sudo docker run -dt --expose="$BTC_PORT" -p "$port:$RPC_PORT" --name="$name" "$IMAGE" \
            bitcoind -datadir=data || {
            _log_error "Failed to create new regtest node \"$name\""
            return 1
        }

        ip=$(sudo docker container inspect "$name" |
            grep '"IPAddress": ' | tail -1 | sed -n 's/^[[:space:]]*"IPAddress": "\(.*\)",$/\1/p')

        [[ $? -eq 0 ]] || {
            _log_error "Failed to acquire IP address of regtest node \"$name\""
            return 1
        }

        _log_debug "New regtest node created: name=\"$name\" ip=\"$ip\" port=$BTC_PORT rpcport=$port"
    done
}

main() {
    # Parse options
    local args
    args=$(getopt -o hn:p: -l help,nodes:start-port: -n $0 -- "$@")
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
            -n | --nodes)
                NODES="$2"
                shift 2
                ;;
            -p | --start-port)
                START_PORT="$2"
                shift 2
                ;;
            --)
                shift
                [[ $# -eq 0 ]] || { print_usage; return 1; }
                break
                ;;
            *)
                _log_error "Unexpected option: $1"
                return 1
                ;;
        esac
    done

    start_new_nodes
}

main "$@"
