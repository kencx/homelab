# CoreDNS

This role installs, configures and start [coredns](https://coredns.io/). Coredns
will be used for local DNS resolution and DNS forwarding over TLS.

It can be paired with an adblocker (eg. [blocky](./blocky.md)) as its upstream
DNS server.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| coredns_version | Version to install | string | `1.10.1` |
| coredns_url | Binary URL | string | |
| coredns_checksum_url | Binary checksum URL | string | `${coredns_url}.sha256` |
| coredns_dns_port | | int | `5300` |
| coredns_user | User | string | `coredns` |
| coredns_group | Group | string | `coredns` |

## Notes

- The `coredns` systemd service is started with a dynamic user. This means the
  user and group `coredns` are transient and managed fully by systemd.
