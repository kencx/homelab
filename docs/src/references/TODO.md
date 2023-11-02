# Roadmap

- [ ] Secure sudo user
- [ ] Fix configuragble cert TTL by Vault
- [ ] Make Bitwarden scripts in Vault role more robust
- [ ] Nomad, Consul automated gossip key rotation
- [ ] Nomad, Consul ACLs
- [ ] Run consul-template as non-root user
- [ ] Replace fail2ban with crowdsec
- [ ] Setup Authelia
- [ ] Complete `autorestic` role
    - Installation of restic and autorestic not implemented
    - `autorestic.env` not populated by Ansible
- [ ] Complete `unseal_vault` role
- [ ] Fix Packer `base` ISO build
    - `preseed.cfg` is unreachable by boot command when controller host and Proxmox VM
are on different subnets.
- [ ] systemd notification on failure
- [ ] Monitoring stack on separate node
