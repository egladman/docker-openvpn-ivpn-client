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
    local config_dir="${CONFIG_DIR:-/config/client}"
    local pass_file="${PASS_FILE:-/config/credentials}"

    sed -i "s:auth-user-pass:auth-user-pass ${pass_file}:" "${config_dir}"/*.ovpn

    if [[ -z "$USERNAME" ]]; then
        log::warn "Environment variable 'USERNAME' is unset."
    fi

    if [[ -z "$PASSWORD" ]]; then
        log::warn "Environment variable 'PASSWORD' is unset. Defaulting to 'hunter2'."
    fi

    if [[ -f "$pass_file" ]]; then # A pass file was bind mounted in
        return
    fi

    >"$pass_file"
    chmod 600 "$pass_file"

    printf '%s\n' "$USERNAME" > "$pass_file"
    printf '%s\n' "${PASSWORD:-hunter2}" >> "$pass_file"
}

main
