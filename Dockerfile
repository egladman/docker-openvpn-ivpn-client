ARG REGISTRY=docker.io/

FROM ${REGISTRY}debian:11.0-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG IVPN_OPENVPN_CONFIG_SHA512=9c2d03c187100366eedc6ae0e047f6287f82d7dc998b35da92547a8ba8195854cc5d9bfb46ea7590774fd5f557b220cc9e4b3e3e95976c3ca6cd41fd03269db0

RUN set -eux; \
    apt-get update; \
    apt-get install -y openvpn unzip curl iputils-ping iproute2 openresolv gettext-base; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /docker-entrypoint.d

RUN set -eux; \
    curl https://www.ivpn.net/releases/config/ivpn-openvpn-config.zip --output ivpn.zip; \
    echo "${IVPN_OPENVPN_CONFIG_SHA512} ivpn.zip" | sha512sum --strict --check; \
    mkdir /config; \
    unzip -j -d /config/client ivpn.zip

# COPY /entrypoint/docker-healthcheck.sh /
COPY /entrypoint/docker-entrypoint.sh /
COPY /entrypoint/10-modify-in-place-opvn.sh /docker-entrypoint.d
COPY /entrypoint/20-update-resolv-conf.sh /docker-entrypoint.d

RUN set -eux; \
    chmod +x /docker-entrypoint.sh /docker-entrypoint.d/*

#HEALTHCHECK --interval=10s --timeout=5s --start-period=15s \
#  CMD /docker-healthcheck.sh /var/run/container/dns

STOPSIGNAL SIGQUIT

ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR /config/client
