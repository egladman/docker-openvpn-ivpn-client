ARG REGISTRY=docker.io/
ARG DEBIAN_VERSION=bullseye

FROM ${REGISTRY}bitnami/minideb:${DEBIAN_VERSION}

LABEL maintainer="Eli Gladman <eli@gladman.cc>"

ARG UID=2222
ARG GID=2222

ARG OPENVPN_ARCHIVE_SHA512=f7bc95720fe91610e118408080c6edb79d07350d020c3188101d2eedcafd533f57bc043a18a0558eaffac45d03a786a72b8c3771c822d34e035d2637d488dbaa
ARG OPENVPN_ARCHIVE_URL=https://www.ivpn.net/releases/config/ivpn-openvpn-config.zip

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    addgroup --system --gid $GID foo; \
    adduser --system --disabled-login --ingroup foo --no-create-home --home /nonexistent --gecos "openvpn user" --shell /bin/false --uid $UID foo; \
    apt-get update; \
    apt-get install -y --no-install-recommends openvpn unzip curl ca-certificates iputils-ping; \
    curl $OPENVPN_ARCHIVE_URL --output archive.zip; \
    echo "$OPENVPN_ARCHIVE_SHA512 archive.zip" | sha512sum --strict --check; \
    mkdir /config; \
    unzip -j -d /config/client archive.zip; \
    apt-get remove -y curl unzip ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /docker-entrypoint.d

COPY /docker-healthcheck.sh /
COPY /entrypoint/docker-entrypoint.sh /
COPY /entrypoint/10-patch-opvn-configs.sh /docker-entrypoint.d
COPY /entrypoint/20-create-resolv-conf.sh /docker-entrypoint.d
COPY /entrypoint/90-update-resolv-conf.sh /docker-entrypoint.d

RUN set -eux; \
    chmod +x /docker-entrypoint.sh /docker-healthcheck.sh /docker-entrypoint.d/*; \
    chmod gu+s /usr/sbin/openvpn; \
    chown -R $UID:$GID /config

STOPSIGNAL SIGQUIT
WORKDIR /config/client
USER $UID

HEALTHCHECK --interval=90s --timeout=10s --start-period=5s \
  CMD /docker-healthcheck.sh || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
