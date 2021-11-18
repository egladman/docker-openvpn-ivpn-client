#!/usr/bin/env bash

set -o pipefail -o errexit

_log() {
    # Usage: log <prefix> <message>
    #        log WARN "hello world"

    printf -v now '%(%m-%d-%Y %H:%M:%S)T' -1
    printf '%b\n' "[${1:: 4}] ${now} ${0##*/} ${2}"
}

log::warn() {
    _log "WARN" "$*"
}

log::error() {
    _log "ERROR" "$*"
}

main() {
    local config_dir="${OPENVPN_CONFIG_DIR:-/config/client}"
    local pass_file="${OPENVPN_PASS_FILE:-/config/credentials}"

    sed -i "s:auth-user-pass:auth-user-pass ${pass_file}:" "${config_dir}"/*.ovpn

    >"$pass_file"
    chmod 600 "$pass_file"

    if [[ -z "$USERNAME" ]]; then
        log::error "Environment variable 'USERNAME' is unset."
    fi

    if [[ -z "$PASSWORD" ]]; then
        log::warn "Environment variable 'PASSWORD' is unset. Defaulting to 'hunter2'."
    fi

    printf '%s\n' "$USERNAME" > "$pass_file"
    printf '%s\n' "${PASSWORD:-hunter2}" >> "$pass_file"
}

main
