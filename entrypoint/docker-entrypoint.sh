#!/usr/bin/env bash

set -o pipefail -o errexit

SKIP_ENTRYPOINTD=${SKIP_ENTRYPOINTD:-0}

_log() {
    # Usage: log <prefix> <message>
    #        log WARN "hello world"

    printf -v now '%(%m-%d-%Y %H:%M:%S)T' -1
    printf '%b\n' "[${1:: 4}] ${now} ${0##*/} ${2}"
}

log::warn() {
    _log "WARN" "$*"
}

log::info() {
    _log "INFO" "$*"
}

log::error() {
    _log "ERROR" "$*"
}

for f in /docker-entrypoint.d/*.sh; do
    if [[ $SKIP_ENTRYPOINTD -eq 1 ]]; then
	      log::info "Skipping scripts in /docker-entrypoint.d"
	      break
    fi

    if [[ -x "$f" ]]; then # It's executable
	      log::info "Executing script '$f'"
	      "$f"
    else
	      log::warn "Ignoring '${script}'. Not executable."
    fi
done

log::info "Finished configuration. Launching..."

argv=("$@")
if [[ "${argv[0]}" == "openvpn" ]]; then
    # Dumbest, but simplest solution I could think of at one in the morning.
    # --up is very particular of what gets passed to it
    printf '%s\n%s\n' "#!/bin/bash" ">/tmp/openvpn_isready" > /tmp/openvpn_up
    chmod +x /tmp/openvpn_up

    set -- "${argv[0]}" --config "${argv[@]:1}" --script-security 2 --up /tmp/openvpn_up
fi

exec "$@"
