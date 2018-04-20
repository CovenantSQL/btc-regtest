#! /usr/bin/env bash

declare -r ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source $ROOT_DIR/common/log.sh

declare -r IMAGE=regtest:latest
declare -r BTC_PORT=18444
declare -r RPC_PORT=18443

declare JOIN=0
declare JOINT=
declare NODES=1
declare START_PORT=5000

print_usage() {
    cat <<USAGE
$0 [OPTION]...

    -h, --help              Display this help and exit
        --join[=<ip:port>]  Join these new nodes into a BTC network; or to another network if the
                              optional argument is given as a joint point
    -n, --nodes=INT         Set node number
    -p, --start-port=INT    Start port of a range

USAGE
}

add_node() {
    # $1: node name
    # $2: target ip:port

    # Retry for a few times while the node is initiating
    local index

    for ((index=0; index<5; index++)); do
        if sudo docker exec "$1" bitcoin-cli -datadir=data addnode "$2" add; then
            return 0
        else
            sleep 1
        fi
    done

    return 1
}

start_new_nodes() {
    local ip=
    local port=
    local name=
    local index=

    for ((index=0; index<NODES; index++)); do
        port=$((START_PORT+index))
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

        if [[ "$JOIN" -eq 1 ]]; then
            if [[ -z "$JOINT" ]]; then
                # Use the first new node as a joint if none is given
                JOINT="$ip:$BTC_PORT"
            else
                if add_node "$name" "$JOINT"; then
                    _log_debug "Joined new node \"$name\" through \"$JOINT\""
                else
                    _log_error "Failed to join node \"$name\" to \"$JOINT\""
                    return 1
                fi
            fi
        fi
    done
}

main() {
    # Parse options
    local args
    args=$(getopt -o hj::n:p: -l help,join::,nodes:start-port: -n $0 -- "$@")
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
            --join)
                JOIN=1
                JOINT="$2"
                shift 2
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
