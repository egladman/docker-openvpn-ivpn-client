#!/usr/bin/env bash

set -o pipefail -o errexit

main() {
    # Wait until the openvpn process has started
    while [[ ! -f /tmp/openvpn.pid ]]; do
        sleep 1
    done

    sleep ${DNS_TIMEOUT:-15}

    printf '%s\n' "Waking up. Updating '/etc/resolv.conf'"

    printf '%s\n' "# Added by $0" > /etc/resolv.conf
    printf '%s\n' "nameserver ${DNS:-10.0.254.1}" >> /etc/resolv.conf
}

main &


