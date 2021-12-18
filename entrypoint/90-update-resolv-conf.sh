#!/usr/bin/env bash

set -o pipefail -o errexit

main() {
    # Wait until the openvpn process has started
    while [[ ! -f "/tmp/openvpn_isready" ]]; do
        sleep 1
    done

    log::info "Modifying DNS. Permanently using nameserver '${DNS_INTERNAL:?}'."
    printf '%s\n' "# Added by $0" > /etc/resolv.conf
    printf '%s\n' "nameserver ${DNS_INTERNAL}" >> /etc/resolv.conf

}

log::info "Executing as background job."
main &
