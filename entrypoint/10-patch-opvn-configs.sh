#!/usr/bin/env bash

set -o pipefail -o errexit

main() {
    # This might look odd. We're using ';' as the delimiter so we don't have to
    # worry about escaping forward slashes in var PASS_FILE
    sed -i -r "s;^(auth-user-pass)[[:blank:]]*$;auth-user-pass $PASS_FILE;" "$CONFIG_DIR"/*.ovpn

    if [[ -z "$USERNAME" ]]; then
        log::warn "Environment variable 'USERNAME' is unset."
    fi

    if [[ -z "$PASSWORD" ]]; then
        log::warn "Environment variable 'PASSWORD' is unset."
    fi

    if [[ -f "$PASS_FILE" ]]; then # A pass file was bind mounted in
        log::debug "Found openvpn credentials file."
        return
    fi

    log::debug "Creating credentials file '$PASS_FILE'."

    # shellcheck disable=SC2188
    >"$PASS_FILE"
    chmod 600 "$PASS_FILE"

    printf '%s\n' "$USERNAME" > "$PASS_FILE"
    printf '%s\n' "$PASSWORD" >> "$PASS_FILE"
}

main
