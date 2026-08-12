#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

set -e

DATA_DIR=/data/victoriametrics
LOG_LEVEL=$(bashio::config 'log_level')
RETENTION_PERIOD=$(bashio::config 'retention_period')

mkdir -p "${DATA_DIR}"

bashio::log.info "Starting VictoriaMetrics..."
bashio::log.info "Log level: ${LOG_LEVEL}"
bashio::log.info "Retention period: ${RETENTION_PERIOD} months"

cd /opt/victoriametrics || bashio::exit.nok "VictoriaMetrics installation directory not found."

exec ./victoria-metrics-prod \
    -storageDataPath="${DATA_DIR}" \
    -retentionPeriod="${RETENTION_PERIOD}" \
    -loggerLevel="${LOG_LEVEL}" \
    -httpListenAddr=":8428"
