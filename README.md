# docker-openvpn-ivpn-client
OpenVPN client docker image for [ivpn.net](https://www.ivpn.net/).

Features:
- Does not require `--privileged`
- Does not run as root
- Less than 100MB in size

While this was built with [ivpn.net](https://www.ivpn.net/) in mind, this image
can easily be used for any other vpn provider by mounting a volume to
`/config/client` that contains `.ovpn` files.

## Build

Create image `openvpn-ivpn`

```
make image
```

### Advanced
Create image `openvpn-ivpn`
- Skip checksum validation
- Do not use cache when building image

```
make image DOCKER_BUILD_FLAGS="--no-cache --build-arg SKIP_CHECKSUM=1" 
```

## Run

1. Determine which openvpn config to use. You can list all available `.ovpn`
configs with the following command:

```
docker run --rm --env SKIP_ENTRYPOINTD=1 openvpn-ivpn:latest ls
```

2. Run container

```
docker run \
    --rm \
    --cap-add NET_ADMIN \
    --volume <path/to/empty/file>:/etc/resolv.conf \
    --env USERNAME=<user> \
    --env CONFIG=<config> \
    --device=/dev/net/tun \
    openvpn-ivpn:latest
```

## Example

1. Create an empty file named `resolv.conf` and grant ownership to the image's uid/gid

```
touch resolv.conf && sudo chown 2222:2222 resolv.conf
```

2. Run container

```
docker run \
    --rm \
    --cap-add NET_ADMIN \
    --volume "${PWD}"/resolv.conf:/etc/resolv.conf \
    --env USERNAME=ivpnADCef123 \
    --env CONFIG=USA-New_York.ovpn \
    --device=/dev/net/tun \
    openvpn-ivpn:latest
```

> Only your account ID is used for the authentication and is case-sensitive.
> The password can be anything, like "ivpn", if your client requires a non-blank password.

Source: [ivpn docs](https://www.ivpn.net/setup/linux-terminal/)

## Variables

### Build

- `REGISTRY`
  - Default: `docker.io/`
- `DEBIAN_VERSION`
  - Default: `bullseye`
- `UID`
  - Default: `2222`
- `GID`
  - Default: `2222`
- `OPENVPN_ARCHIVE_SHA512`
  - Default: *See code*
- `OPENVPN_ARCHIVE_URL`
  - Default: *See code*
- `SKIP_CHECKSUM`
  - Default: `0`

### Runtime

- `SKIP_ENTRYPOINTD`
  - Default: `0`
- `DEBUG`
  - Default: `0`
- `VERBOSITY`
  - Default: `4`
- `USERNAME`
  - Required: False
- `PASSWORD`
  - Required: False
- `CONFIG_DIR`
  - Default: `/config/client`
- `PASS_FILE`
  - Default: `/config/credentials`
