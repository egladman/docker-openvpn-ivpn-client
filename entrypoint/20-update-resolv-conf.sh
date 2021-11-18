#!/usr/bin/env bash

set -o pipefail -o errexit

DNS="${DNS:-10.0.254.1}"
DNS_MODIFY_TIMEOUT=${DNS_MODIFY_TIMEOUT:-15}

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
    local pid_file="/tmp/openvpn.pid"

    # Wait until the openvpn process has started
    while [[ ! -f "$pid_file" ]]; do
        sleep 1
    done

    log::info "File '${pid_file}' found. Sleeping..."
    sleep $DNS_MODIFY_TIMEOUT
    log::info "Waking up. Overwriting '/etc/resolv.conf'."

    printf '%s\n' "# Added by $0" > /etc/resolv.conf
    printf '%s\n' "nameserver ${DNS}" >> /etc/resolv.conf
}

log::info "Executing as background job."
main &


