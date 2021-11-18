#!/usr/bin/env bash

set -o pipefail -o errexit

DNS_INIT="${DNS_INIT:-8.8.8.8}"

_log() {
    # Usage: log <prefix> <message>
    #        log WARN "hello world"

    printf -v now '%(%m-%d-%Y %H:%M:%S)T' -1
    printf '%b\n' "[${1:: 4}] ${now} ${0##*/} ${2}"
}

log::info() {
    _log "INFO" "$*"
}

main() {
    log::info "DNS modified. Temporarily using nameserver '${DNS_INIT}' during init."
    printf '%s\n' "# Added by $0" > /etc/resolv.conf
    printf '%s\n' "nameserver ${DNS_INIT}" >> /etc/resolv.conf

}

main
