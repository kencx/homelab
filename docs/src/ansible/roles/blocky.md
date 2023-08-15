# Blocky

This role installs, configures and start [blocky](https://github.com/0xERR0R/blocky).
Blocky is used for adblocking and uses [coredns](./coredns.md) as its upstream DNS server.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| blocky_version | Version to install | string | `0.21` |
| blocky_dns_port | | int | `53` |
| blocky_user | User | string | `coredns` |
| blocky_group | Group | string | `coredns` |
| blocky_client_lookup | Enables client lookup | map | `{}` |

## Notes

- The `blocky` systemd service is started with a dynamic user. This means the
  user and group `blocky` are transient and managed fully by systemd.
- `blocky_client_lookup` should contain an upstream host and a list of clients:

```yml
blocky_client_lookup:
  upstream: 192.168.86.1
  clients:
    arch:
      - 192.168.86.82
    pixel:
      - 192.168.86.20
```
