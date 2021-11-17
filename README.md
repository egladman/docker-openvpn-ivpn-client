# docker-openvpn-ivpn-client
OpenVPN client docker image for [ivpn.net](https://www.ivpn.net/).

While this was built with [ivpn.net](https://www.ivpn.net/) in mind, this image
can easily be used for any other vpn provider by mounting a volume to
`/config/client` that contains `.ovpn` files.

## Build

Create image `openvpn-ivpn`

```
make image
```

## Run

1. Determine which openvpn config to use. You can list all available `.ovpn`
configs with the following command:

```
docker run --rm openvpn-ivpn:latest ls
```

2. Run container

```
docker run \
    --rm \
    --cap-add NET_ADMIN \
    --privileged \
    --volume <path/to/openvpn/credentails>:/config/credentials:ro \
    openvpn-ivpn:latest \
    openvpn <config>
```

## Example

1. Create file `credentials` with contents:

```
ivpnADCef123
foobar
```
> Only your account ID is used for the authentication and is case-sensitive.
> The password can be anything, like "ivpn", if your client requires a non-blank password.

Source: [ivpn docs](https://www.ivpn.net/setup/linux-terminal/)

2. Run container 

```
docker run \
    --rm \
    --cap-add NET_ADMIN \
    --privileged \
    --volume "${PWD}"/credentials:/config/credentials:ro \
    openvpn-ivpn:latest \
    openvpn USA-New_York.ovpn
```
