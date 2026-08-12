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
```

### Option: `log_level`

Controls VictoriaMetrics log verbosity. Supported values are `ERROR`, `WARN`, `INFO`, and `DEBUG`. Default: `INFO`.

### Option: `retention_period`

Retention period passed to VictoriaMetrics as `-retentionPeriod`. The default is `1m` (one month). Values may use VictoriaMetrics duration units such as `d` (days), `w` (weeks), `m` (months), or `y` (years). See the [VictoriaMetrics retention documentation](https://docs.victoriametrics.com/victoriametrics/#retention).

### Option: `username`

Username required by the `vmauth` proxy on port `8428`. Default: `admin`.

### Option: `password`

Password required by the `vmauth` proxy on port `8428`. Change the default before exposing the add-on to other networks.

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
