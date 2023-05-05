# Monitoring Stack
An external VM is provisioning as a monitoring stack outside of the Hashicorp
cluster. This ensures its availability if the cluster were to go down.

The stack includes:

- Prometheus
- Grafana
- Promtail
- Loki

### Prometheus
Prometheus scrapes metrics from the following sources:

- [x] consul: Nomad metrics
- [x] static: Vault metrics
- [x] static: Custom backup metrics from node-exporter
- [ ] static: Proxmox metrics from pve-exporter
- [ ] consul: Consul metrics
- [ ] static: Certificate expiration from cert-exporter
- [ ] static: Pihole metrics from pihole-exporter

Grafana taps into the Prometheus datasource to populate dashboards.

### Centralized Log Management

Promtail is deployed on all cluster nodes: via docker-compose on server nodes,
Nomad system job on client nodes. It pushes `journald` logs to the remote Loki
instance.

Grafana taps into the Loki datasource to allow log visualization.
