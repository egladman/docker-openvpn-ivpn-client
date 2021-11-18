ARG REGISTRY=docker.io/
ARG DEBIAN_VERSION=bullseye

FROM ${REGISTRY}bitnami/minideb:${DEBIAN_VERSION}

LABEL maintainer="Eli Gladman <eli@gladman.cc>"

ARG UID=2222
ARG GID=2222

ARG OPENVPN_ARCHIVE_SHA512=7ae10984f221d7b29b6cc778637607f053ea66ca02faffde434d63b74ef3bea306e73548b5bc5f11799d0f83878a700647f8f222c2ba70c18667c31d83c46da4
ARG OPENVPN_ARCHIVE_URL=https://www.ivpn.net/releases/config/ivpn-openvpn-config.zip

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    addgroup --system --gid $GID foo; \
    adduser --system --disabled-login --ingroup foo --no-create-home --home /nonexistent --gecos "openvpn user" --shell /bin/false --uid $UID foo; \
    apt-get update; \
    apt-get install -y --no-install-recommends openvpn unzip curl ca-certificates; \
    curl $OPENVPN_ARCHIVE_URL --output archive.zip; \
    echo "$OPENVPN_ARCHIVE_SHA512 archive.zip" | sha512sum --strict --check; \
    mkdir /config; \
    unzip -j -d /config/client archive.zip; \
    apt-get remove -y curl ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /docker-entrypoint.d

COPY /entrypoint/docker-entrypoint.sh /
COPY /entrypoint/10-patch-opvn-configs.sh /docker-entrypoint.d
COPY /entrypoint/20-create-resolv-conf.sh /docker-entrypoint.d
COPY /entrypoint/90-update-resolv-conf.sh /docker-entrypoint.d

RUN set -eux; \
    chmod +x /docker-entrypoint.sh /docker-entrypoint.d/*; \
    chmod gu+s /usr/sbin/openvpn; \
    chown -R $UID:$GID /config

STOPSIGNAL SIGQUIT
WORKDIR /config/client
USER $UID

ENTRYPOINT ["/docker-entrypoint.sh"]
