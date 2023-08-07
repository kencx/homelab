# Summary

[Home](index.md)
[Prerequisites](./prerequisites.md)
[Getting Started](./getting_started.md)

---

# Infrastructure

- [Provisioning](provisioning.md)
    - [Images](images/index.md)
        - [Cloud Images](images/cloud_image.md)
        - [Packer](images/packer.md)

    - [Terraform](terraform/index.md)
        - [Postgres](terraform/postgres.md)
        - [Proxmox](terraform/proxmox.md)
        - [Vault](terraform/vault.md)

    - [Ansible](ansible/index.md)
        <!-- - [Inventory](ansible/inventory.md) -->
        - [Roles](ansible/roles/index.md)
            - [Arch Repository](ansible/roles/arch_repository.md)
            - [Autorestic](ansible/roles/autorestic.md)
            - [Blocky](ansible/roles/blocky.md)
            - [Common](ansible/roles/common.md)
            - [Consul](ansible/roles/consul.md)
            - [Consul Template](ansible/roles/consul-template.md)
            - [Coredns](ansible/roles/coredns.md)
            - [Issue Cert](ansible/roles/issue_cert.md)
            - [NFS](ansible/roles/nfs.md)
            - [Nomad](ansible/roles/nomad.md)
            - [Unseal Vault](ansible/roles/unseal_vault.md)
            - [Vault](ansible/roles/vault.md)

    <!-- - [Development Server]() -->

<!-- - [CICD]() -->
<!-- - [Monitoring]() -->
<!-- - [Vault]() -->
<!-- - [Consul]() -->
<!-- - [Nomad]() -->
<!-- - [Certificate Management]() -->
<!-- - [VPS](vps.md) -->

# Applications

- [Applications](apps/index.md)
    - [Adding New Application](apps/add_new.md)
    - [Diun](apps/diun.md)
    - [Registry](apps/registry.md)

- [Backups](backups.md)

# References

- [Known Issues](references/issues.md)
- [Roadmap](references/TODO.md)
