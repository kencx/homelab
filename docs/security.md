# Security Checklist

### Common
- Non-default password-protected user
- Lock down ports with firewall
- SSH hardening (no password authentication, no root login)
- Fail2ban

### Vault
- Do not run as root
- End-to-end TLS encryption
- Avoid root tokens
- Avoid plain text credentials (tokens, unseal keys)
- Use short TTLs
- Enable audit logging
- Lock down file permissions and storage

[For reference](https://learn.hashicorp.com/tutorials/vault/production-hardening?in=vault/day-one-raft)

### Consul-template
- Do not run as root

### Consul
- Gossip encryption with automated rotation
- TLS encryption for API

### Nomad
- Gossip encryption with automated rotation
- TLS encryption for API

### TODO
- [ ] Security audit
- [ ] Monitoring and alerting system
