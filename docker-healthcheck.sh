#!/usr/bin/env bash

main() {
    local tuple
    tuple=($(<"/etc/resolv.conf"))

    printf '%s\n' "Pinging ${tuple[1]}"
    ping -c 1 -w 5 ${tuple[1]}
}
main
