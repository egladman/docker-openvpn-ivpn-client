#!/usr/bin/env bash

set -o pipefail -o errexit

main() {
    # This could be accomplished with a sed one-liner, but where's the fun in
    # that. Pure bash solution ftw

    regex="^auth-user-pass([[:blank:]]){0,}"
    for conf in "${CONFIG_DIR:?}"/*.ovpn; do
        conf_patched=0

        while read -r line; do
            conf_data+=("$line")
        done < "$conf"

        for i in "${!conf_data[@]}"; do
            if [[ "${conf_data[$i]}" =~ $regex ]] && [[ "${conf_data[$i]}" != *"${PASS_FILE:?}" ]]; then
                conf_data[$i]="auth-user-pass ${PASS_FILE}"
                conf_patched=1
            fi
        done

        if [[ $conf_patched -eq 0 ]]; then
            log::debug "Skipping config '$conf'."
            continue
        fi

        log::debug "Patching config '$conf'."
        printf '%s\n' "${conf_data[@]}" > "$conf"
    done

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
