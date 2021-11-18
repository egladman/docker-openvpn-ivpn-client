#!/usr/bin/env bash

set -o pipefail -o errexit

main() {
    local config_dir="${OPENVPN_CONFIG_DIR:-/config/client}"
    local pass_file="${OPENVPN_PASS_FILE:-/config/credentials}"

    sed -i "s:auth-user-pass:auth-user-pass ${pass_file}:" "${config_dir}"/*.ovpn
}

main
