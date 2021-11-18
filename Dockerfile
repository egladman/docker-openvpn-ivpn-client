ARG REGISTRY=docker.io/

FROM ${REGISTRY}debian:11.0-slim

ARG UID=2222
ARG GID=2222

ARG DEBIAN_FRONTEND=noninteractive
ARG IVPN_OPENVPN_CONFIG_SHA512=7ae10984f221d7b29b6cc778637607f053ea66ca02faffde434d63b74ef3bea306e73548b5bc5f11799d0f83878a700647f8f222c2ba70c18667c31d83c46da4

RUN set -eux; \
    addgroup --system --gid $GID foo; \
    adduser --system --disabled-login --ingroup foo --no-create-home --home /nonexistent --gecos "openvpn user" --shell /bin/false --uid $UID foo; \
    apt-get update; \
    apt-get install -y openvpn unzip curl iputils-ping iproute2 openresolv gettext-base; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /docker-entrypoint.d

RUN set -eux; \
    curl https://www.ivpn.net/releases/config/ivpn-openvpn-config.zip --output ivpn.zip; \
    echo "${IVPN_OPENVPN_CONFIG_SHA512} ivpn.zip" | sha512sum --strict --check; \
    mkdir /config; \
    unzip -j -d /config/client ivpn.zip; \
    chown -R $UID:$GID /config

COPY /entrypoint/docker-entrypoint.sh /
COPY /entrypoint/10-modify-in-place-opvn.sh /docker-entrypoint.d
COPY /entrypoint/20-create-resolv-conf.sh /docker-entrypoint.d
COPY /entrypoint/90-update-resolv-conf.sh /docker-entrypoint.d

RUN set -eux; \
    chmod +x /docker-entrypoint.sh /docker-entrypoint.d/*; \
    chmod gu+s /usr/sbin/openvpn

STOPSIGNAL SIGQUIT
WORKDIR /config/client
USER $UID

ENTRYPOINT ["/docker-entrypoint.sh"]
