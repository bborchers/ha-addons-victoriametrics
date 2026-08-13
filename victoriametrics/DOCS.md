# Home Assistant Add-on: VictoriaMetrics

This add-on provides the open-source [VictoriaMetrics single-node server](https://docs.victoriametrics.com/victoriametrics/), a fast and resource-efficient time-series database for Prometheus-compatible metrics.

The HTTP API and built-in web UI are available at and protected by HTTP Basic
Authentication:

```text
http://<home-assistant-ip>:8428
```

## Configuration

```yaml
log_level: INFO
retention_period: "1m"
username: "admin"
password: "change-me"
scrape_configs: ""
```

### Option: `log_level`

Controls VictoriaMetrics log verbosity. Supported values are `ERROR`, `WARN`, `INFO`, and `DEBUG`. Default: `INFO`.

### Option: `retention_period`

Retention period passed to VictoriaMetrics as `-retentionPeriod`. The default is `1m` (one month). Values may use VictoriaMetrics duration units such as `d` (days), `w` (weeks), `m` (months), or `y` (years). See the [VictoriaMetrics retention documentation](https://docs.victoriametrics.com/victoriametrics/#retention).

### Option: `username`

Username required by the `vmauth` proxy on port `8428`. Default: `admin`.

### Option: `password`

Password required by the `vmauth` proxy on port `8428`. Change the default before exposing the add-on to other networks.

### Option: `scrape_configs`

Optional YAML passed to VictoriaMetrics through `-promscrape.config`. Include the
top-level `scrape_configs` key. Multiple scrape jobs can be configured in the
list, for example:

```yaml
scrape_configs:
  - job_name: node-exporter
    static_configs:
      - targets:
          - "homeassistant.local:9100"
  - job_name: another-exporter
    static_configs:
      - targets:
          - "192.168.1.20:8080"
```

The complete YAML block is entered as the `scrape_configs` value in the Home
Assistant add-on configuration. VictoriaMetrics supports additional discovery
and relabeling options such as `file_sd_configs`, `http_sd_configs`, and
`relabel_configs`; see the [scrape configuration examples](https://docs.victoriametrics.com/victoriametrics/scrape_config_examples/).

Leave this option empty to disable scraping. Targets must be reachable from
the add-on container.

## Using VictoriaMetrics

VictoriaMetrics accepts Prometheus remote-write requests at:

```text
http://<home-assistant-ip>:8428/api/v1/write
```

Prometheus-compatible queries use the standard endpoints such as `/api/v1/query` and `/api/v1/query_range`. The built-in UI is available at `/vmui`.

## Data and backups

All time-series data is stored below `/data/victoriametrics` in the persistent add-on data directory. Create a Home Assistant backup before uninstalling the add-on; Supervisor removes an add-on's private data directory during uninstall.

## Support

Please report issues in the [build repository](https://github.com/bborchers/ha-addons-victoriametrics).
