ARG REGISTRY=docker.io/
ARG DEBIAN_VERSION=bullseye
ARG SCRATCHDIR=/scratch
ARG VARIANT=core


FROM ${REGISTRY}bitnami/minideb:${DEBIAN_VERSION} as core-rootfs

RUN set -eux; \
    apt-get update; \
    apt-get install \
      --assume-yes \
      --no-install-recommends \
      openvpn \
      iputils-ping \
    ; \
    rm -rf /var/lib/apt/lists/*;


FROM ${REGISTRY}bitnami/minideb:${DEBIAN_VERSION} as devel-rootfs

RUN set -eux; \
    apt-get update; \
    apt-get install \
      --assume-yes \
      --no-install-recommends \
      openvpn \
      iputils-ping \
      curl \
      ca-certificates \
      unzip \
    ; \
    rm -rf /var/lib/apt/lists/*


FROM devel-rootfs as openvpn-configs

ARG SCRATCHDIR
ARG OPENVPN_ARCHIVE_SHA512=
ARG OPENVPN_ARCHIVE_URL=https://www.ivpn.net/releases/config/ivpn-openvpn-config.zip
ARG OPENVPN_SKIP_CHECKSUM=0

WORKDIR /tmp

RUN set -eux; \
    curl $OPENVPN_ARCHIVE_URL --output archive.zip; \
    [[ $OPENVPN_SKIP_CHECKSUM -eq 1 ]] && echo "$OPENVPN_ARCHIVE_SHA512 archive.zip" | sha512sum --strict --check; \
    unzip -j -d $SCRATCHDIR archive.zip 


FROM devel-rootfs as entrypoint-aux-scripts

ARG SCRATCHDIR

RUN mkdir -p $SCRATCHDIR
COPY /entrypoint/* ${SCRATCHDIR}/
RUN set -eux; \
  find $SCRATCHDIR  -type f ! \( -name '[[:digit:]]?-*.sh' \) -exec rm -rf {} \;


FROM ${VARIANT}-rootfs as runtime-rootfs

FROM scratch

ARG SCRATCHDIR

COPY --from=runtime-rootfs / /

LABEL maintainer="Eli Gladman <eli@gladman.cc>"

ARG UID=2222
ARG GID=2222
ARG SCRATCHDIR

RUN set -eux; \
    addgroup --system --gid $GID foo; \
    adduser --system --disabled-login --ingroup foo --no-create-home --home /nonexistent --gecos "openvpn user" --shell /bin/false --uid $UID foo; \
    mkdir -p /etc/docker-entrypoint.d /var/cache/docker-entrypoint

COPY --from=openvpn-configs $SCRATCHDIR /config/client/
COPY /Default /var/cache/docker-entrypoint/cmd
COPY /Environment /var/cache/docker-entrypoint/env

COPY /docker-healthcheck.sh /usr/local/bin/docker-healthcheck
COPY /entrypoint/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --from=entrypoint-aux-scripts $SCRATCHDIR/* /etc/docker-entrypoint.d/

RUN set -eux; \
    chmod +x /usr/local/bin/docker-* /etc/docker-entrypoint.d/*; \
    chmod gu+s /usr/sbin/openvpn; \
    chown -R $UID:$GID /config

STOPSIGNAL SIGQUIT
WORKDIR /config/client
USER $UID

HEALTHCHECK --interval=60s --timeout=4s \
  CMD /usr/local/bin/docker-healthcheck || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
