This role installs, configures and start [blocky](https://github.com/0xERR0R/blocky).
Blocky is used for adblocking and uses [coredns](./coredns.md) as its upstream DNS server.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| blocky_version | Version to install | string | `0.21` |
| blocky_url | Binary URL | string | |
| blocky_checksum_url | Binary checksum URL | string | |
| blocky_dns_port | | int | `53` |
| blocky_user | User | string | `coredns` |
| blocky_group | Group | string | `coredns` |

## Notes

- The `blocky` systemd service is started with a dynamic user. This means the
  user and group `blocky` are transient and managed fully by systemd.
