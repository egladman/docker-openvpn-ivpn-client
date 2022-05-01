#!/bin/bash

set -o pipefail -o errexit

_log() {
    # Usage: _log <prefix> <message>
    #        _log WARN "hello world"

    printf -v now '%(%m-%d-%Y %H:%M:%S)T' -1
    printf '%b\n' "[${1:: 4}] ${now} ${0##*/} ${2}"
}

log::info() {
    _log "INFO" "$*"
}

log::debug() {
    [[ "$DEBUG_ENTRYPOINT" -eq 0 ]] && return
    _log "DEBUG" "$*"
}

log::warn() {
    _log "WARN" "$*"
}

log::error() {
    _log "ERROR" "$*"
}

export DEBUG_ENTRYPOINT=${DEBUG_ENTRYPOINT:-0}
export -f _log log::warn log::info log::debug log::error

if [[ -s /var/cache/docker-entrypoint/env ]]; then
    mapfile -t file_data < "/var/cache/docker-entrypoint/env"
    log::info "Initalizing environment."
    log::debug "Reading /var/cache/docker-entrypoint/env"

    is_optional='^([a-zA-Z_])+[[:space:]]\?=[[:space:]]'
    for line in "${file_data[@]}"; do
        key="${line/ \= *}"
        override=1
        if [[ "$line" =~ $is_optional ]]; then
            key="${line/ \?\= *}"
            override=0
        fi

        val="${line/*\= }" # Everything after the =
        val_current="$(eval printf '%s' \"\$"$key"\")"

        if [[ -n "$val_current" ]] && [[ $override -eq 0 ]]; then
            log::debug "Environment variable '$key' is already set. Skipping..."
            continue
        fi

        eval export "${key}=${val}"
        log::debug "Environment variable '$key' set."
    done
fi

log::debug "Checking /docker-entrypoint.d"
for f in /etc/docker-entrypoint.d/*.sh; do
    if [[ $SKIP_ENTRYPOINTD -eq 1 ]]; then
	      log::info "Skipping executables in '/docker-entrypoint.d'"
	      break
    fi

    if [[ -x "$f" ]]; then # It's executable
	      log::info "Executing script '${f}'"
	      "$f"
    else
	      log::warn "Ignoring '${f}'. Not executable."
    fi
done

if [[ -z "$1" ]] && [[ -s /var/cache/docker-entrypoint/cmd ]]; then
    log::debug "No command passed. Using default. Reading '/var/cache/docker-entrypoint/cmd'."
    mapfile -t file_data < /var/cache/docker-entrypoint/cmd

    is_variable='^((")?\$)([a-zA-Z_])+(")?$'
    for i in "${!file_data[@]}"; do
        if [[ "${file_data[$i]}" =~ $is_variable ]]; then
            log::debug "Evaluating ${file_data[$i]}."
            file_data[$i]="$(eval printf '%s' "${file_data[$i]}")"
        fi
    done
    set -- "${file_data[@]}"
elif [[ -z "$1" ]]; then
    log::error "No command passed to entrypoint."
    exit 127
fi

# shellcheck disable=SC2145
log::info "Finished configuration. Launching '${@:1:1}'."
log::debug "$*"
exec "$@"
