#!/usr/bin/env bash

set -o pipefail -o errexit

main() {
    log::info "DNS modified. Temporarily using nameserver '${DNS_INIT}' during init."
    printf '%s\n' "# Added by $0" > /etc/resolv.conf
    printf '%s\n' "nameserver ${DNS_INIT}" >> /etc/resolv.conf
}

main
