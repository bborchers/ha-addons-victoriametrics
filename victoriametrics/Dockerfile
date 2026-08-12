ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG VICTORIAMETRICS_VERSION="1.148.0"

RUN \
    apk add --no-cache \
        ca-certificates \
        curl \
        tzdata \
    && case "${BUILD_ARCH}" in \
        aarch64) VICTORIAMETRICS_ARCH="arm64" ;; \
        amd64) VICTORIAMETRICS_ARCH="amd64" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" >&2 && exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/victoriametrics.tar.gz \
        "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VICTORIAMETRICS_VERSION}/victoria-metrics-linux-${VICTORIAMETRICS_ARCH}-v${VICTORIAMETRICS_VERSION}.tar.gz" \
    && mkdir -p /opt/victoriametrics \
    && tar -xzf /tmp/victoriametrics.tar.gz -C /opt/victoriametrics \
    && rm -f /tmp/victoriametrics.tar.gz

COPY run.sh /
RUN chmod a+x /run.sh

LABEL \
    io.hass.name="VictoriaMetrics" \
    io.hass.description="VictoriaMetrics single-node time-series database" \
    io.hass.type="addon"

CMD ["/run.sh"]
