#!/usr/bin/env bash

set -o pipefail -o errexit

# Used in combanation with openvpn option '--up'. Create a file named
# openvpn_isready once the openvpn process is operational

main() {
    log::debug "Creating file '/tmp/openvpn_up'."
    printf '%s\n%s\n' "#!/bin/bash" ">/tmp/openvpn_isready" > /tmp/openvpn_up
    chmod +x /tmp/openvpn_up
}

main
