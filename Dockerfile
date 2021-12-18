ARG REGISTRY=docker.io/
ARG DEBIAN_VERSION=bullseye

FROM ${REGISTRY}bitnami/minideb:${DEBIAN_VERSION}

LABEL maintainer="Eli Gladman <eli@gladman.cc>"

ARG UID=2222
ARG GID=2222

ARG OPENVPN_ARCHIVE_SHA512=
ARG OPENVPN_ARCHIVE_URL=https://www.ivpn.net/releases/config/ivpn-openvpn-config.zip

ARG DEBIAN_FRONTEND=noninteractive
ARG SKIP_CHECKSUM=0

RUN set -eux; \
    addgroup --system --gid $GID foo; \
    adduser --system --disabled-login --ingroup foo --no-create-home --home /nonexistent --gecos "openvpn user" --shell /bin/false --uid $UID foo; \
    apt-get update; \
    apt-get install -y --no-install-recommends openvpn unzip curl ca-certificates iputils-ping; \
    curl $OPENVPN_ARCHIVE_URL --output /tmp/archive.zip; \
    [[ $SKIP_CHECKSUM -eq 1 ]] && echo "$OPENVPN_ARCHIVE_SHA512 /tmp/archive.zip" | sha512sum --strict --check; \
    mkdir /config; \
    unzip -j -d /config/client /tmp/archive.zip; \
    apt-get remove -y curl unzip ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /docker-entrypoint.d; \
    mkdir /var/cache/docker; \
    rm -rf /tmp/*

COPY /Default /var/cache/docker/cmd
COPY /Environment /var/cache/docker/env

COPY /docker-healthcheck.sh /
COPY /entrypoint/docker-entrypoint.sh /
COPY /entrypoint/10-patch-opvn-configs.sh /docker-entrypoint.d
COPY /entrypoint/20-create-resolv-conf.sh /docker-entrypoint.d
COPY /entrypoint/30-create-opvn-hook.sh /docker-entrypoint.d
COPY /entrypoint/90-update-resolv-conf.sh /docker-entrypoint.d

RUN set -eux; \
    chmod +x /docker-entrypoint.sh /docker-healthcheck.sh /docker-entrypoint.d/*; \
    chmod gu+s /usr/sbin/openvpn; \
    chown -R $UID:$GID /config

STOPSIGNAL SIGQUIT
WORKDIR /config/client
USER $UID

HEALTHCHECK --interval=60s --timeout=4s \
  CMD /docker-healthcheck.sh || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
