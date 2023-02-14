This role installs common packages and performs standard post-provisioning such
as:

- Creation of user
- Creation of NFS share directories
- Installation of Hashicorp software
- Installation of Bitwarden CLI

!!! note
    Security hardening and installation of Docker are performed separately in the
    `common.yml` playbook.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| common_user | User to be created | string | `debian` |
| common_timezone | Timezone to set | string | `Asia/Singapore` |
| common_keyring_dir | Keyring directory path for external apt repositories | string | `/etc/apt/keyrings` |
| common_nfs_dir | NFS share directory path | string | `/mnt/storage` |
| common_packages | List of common packages to be installed | list(string) | See `defaults.yml` for full list |
| common_reset_nomad | Clear Nomad data directory | boolean | `true` |
| common_dotfiles_url | Dotfiles Git repository URL | string | `""` |

## Notes

This role clears any existing `/opt/nomad/data` directories to a blank slate. To disable this
behaviour, set `common_reset_nomad: false`.
