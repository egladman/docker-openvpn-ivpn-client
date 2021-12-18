#!/usr/bin/env bash

set -o pipefail -o errexit

main() {
    log::info "Modifying DNS. Temporarily using nameserver '${DNS_EXTERNAL:?}' during init phase."
    printf '%s\n' "# Added by $0" > /etc/resolv.conf
    printf '%s\n' "nameserver ${DNS_EXTERNAL}" >> /etc/resolv.conf
}

main
