#!/usr/bin/env bash

set -o pipefail -o errexit

main() {
    local config_dir="${CONFIG_DIR:-/config/client}"
    local pass_file="${PASS_FILE:-/config/credentials}"

    # This could be accomplished with a sed one-liner, but where's the fun in
    # that. Pure bash solution ftw

    regex="^auth-user-pass([[:blank:]]){0,}"
    for conf in "${config_dir}"/*.ovpn; do
        conf_patched=0

        while read -r line; do
            conf_data+=("$line")
        done < "$conf"

        for i in "${!conf_data[@]}"; do
            if [[ "${conf_data[$i]}" =~ $regex ]] && [[ "${conf_data[$i]}" != *"${pass_file}" ]]; then
                conf_data[$i]="auth-user-pass ${pass_file}"
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
        log::warn "Environment variable 'PASSWORD' is unset. Defaulting to 'hunter2'."
    fi

    if [[ -f "$pass_file" ]]; then # A pass file was bind mounted in
        log::debug "Found openvpn credentials file."
        return
    fi

    log::debug "Creating credentials file '$pass_file'."

    # shellcheck disable=SC2188
    >"$pass_file"
    chmod 600 "$pass_file"

    printf '%s\n' "$USERNAME" > "$pass_file"
    printf '%s\n' "${PASSWORD:-hunter2}" >> "$pass_file"
}

main
