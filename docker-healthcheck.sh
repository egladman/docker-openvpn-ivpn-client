#!/usr/bin/env bash

main() {
    local tuple
    while read -r line; do
        if [[ "$line" == "nameserver"* ]]; then
            # shellcheck disable=SC2206
            tuple=($line)
            break
        fi
    done < /etc/resolv.conf

    printf '%s\n' "Pinging '${tuple[1]}'."

    ping -c 1 -w 5 "${tuple[1]}"
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]]; then
        printf '%s\n' "Command 'ping' returned non-zero code. Failed to establish connection to '${tuple[1]}'."
        exit 1
    fi
}
main
