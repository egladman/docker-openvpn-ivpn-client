#!/usr/bin/env bash

set -o pipefail -o errexit

DNS="${DNS:-10.0.254.1}"

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
    # Wait until the openvpn process has started
    while [[ ! -f "/tmp/openvpn_isready" ]]; do
        sleep 1
    done

    log::info "DNS modified. Permanently using nameserver '${DNS}'."
    printf '%s\n' "# Added by $0" > /etc/resolv.conf
    printf '%s\n' "nameserver ${DNS}" >> /etc/resolv.conf

}

log::info "Executing as background job."
main &
