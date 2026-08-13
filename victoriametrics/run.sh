#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

set -e

DATA_DIR=/data/victoriametrics
AUTH_CONFIG_FILE=${DATA_DIR}/vmauth-auth.yml
LOG_LEVEL=$(bashio::config 'log_level')
RETENTION_PERIOD=$(bashio::config 'retention_period')
USERNAME=$(bashio::config 'username')
PASSWORD=$(bashio::config 'password')
SCRAPE_CONFIG=$(bashio::config 'scrape_configs')
SCRAPE_CONFIG_FILE=${DATA_DIR}/scrape.yml
PUBLIC_SCRAPE_CONFIG_FILE=/config/scrape.yml

mkdir -p "${DATA_DIR}"

umask 077
USERNAME_YAML=$(printf '%s' "${USERNAME}" | sed "s/'/''/g")
PASSWORD_YAML=$(printf '%s' "${PASSWORD}" | sed "s/'/''/g")
printf "users:\n  - username: '%s'\n    password: '%s'\n    url_prefix: 'http://127.0.0.1:8429'\n" \
    "${USERNAME_YAML}" "${PASSWORD_YAML}" > "${AUTH_CONFIG_FILE}"
chmod 600 "${AUTH_CONFIG_FILE}"

if [[ -f "${PUBLIC_SCRAPE_CONFIG_FILE}" ]]; then
    cp "${PUBLIC_SCRAPE_CONFIG_FILE}" "${SCRAPE_CONFIG_FILE}"
    chmod 600 "${SCRAPE_CONFIG_FILE}"
    SCRAPE_CONFIG_ARGS=("-promscrape.config=${SCRAPE_CONFIG_FILE}")
    bashio::log.info "Prometheus scrape configuration loaded from /config/scrape.yml."
elif [[ -n "${SCRAPE_CONFIG}" ]]; then
    printf '%s\n' "${SCRAPE_CONFIG}" > "${SCRAPE_CONFIG_FILE}"
    chmod 600 "${SCRAPE_CONFIG_FILE}"
    SCRAPE_CONFIG_ARGS=("-promscrape.config=${SCRAPE_CONFIG_FILE}")
    bashio::log.info "Prometheus scrape configuration loaded from the add-on options."
else
    rm -f "${SCRAPE_CONFIG_FILE}"
    SCRAPE_CONFIG_ARGS=()
fi

bashio::log.info "Starting VictoriaMetrics..."
bashio::log.info "Log level: ${LOG_LEVEL}"
bashio::log.info "Retention period: ${RETENTION_PERIOD}"
bashio::log.info "vmauth is enabled on port 8428 for user ${USERNAME}."

cd /opt/victoriametrics || bashio::exit.nok "VictoriaMetrics installation directory not found."

./victoria-metrics-prod \
    -storageDataPath="${DATA_DIR}" \
    -retentionPeriod="${RETENTION_PERIOD}" \
    -loggerLevel="${LOG_LEVEL}" \
    -httpListenAddr=":8429" \
    "${SCRAPE_CONFIG_ARGS[@]}" &
VICTORIAMETRICS_PID=$!

/opt/vmauth/vmauth-prod \
    -auth.config="${AUTH_CONFIG_FILE}" \
    -httpListenAddr=":8428" &
VMAUTH_PID=$!

trap 'kill "${VICTORIAMETRICS_PID}" "${VMAUTH_PID}" 2>/dev/null || true' EXIT
wait -n "${VICTORIAMETRICS_PID}" "${VMAUTH_PID}"
exit 1
