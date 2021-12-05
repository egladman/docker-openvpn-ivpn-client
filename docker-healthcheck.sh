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

    printf '%s\n' "Pinging ${tuple[1]}"
    ping -c 1 -w 5 "${tuple[1]}"
}
main
