# Common

This role installs common packages and performs standard post-provisioning such
as:

- Creation of user
- Creation of NFS share directories
- Installation of Hashicorp software
- Installation of Bitwarden CLI

>**Note**: Security hardening and installation of Docker are performed
>separately in the `common.yml` playbook.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| common_user | User to be created | string | `debian` |
| common_timezone | Timezone to set | string | `Asia/Singapore` |
| common_keyring_dir | Keyring directory path for external apt repositories | string | `/etc/apt/keyrings` |
| common_nfs_dir | NFS share directory path | string | `/mnt/storage` |
| common_packages | List of common packages to be installed | list(string) | See `defaults.yml` for full list |
| common_nomad_version | Nomad version to install | string | `1.6.1-1` |
| common_consul_version | Consul version to install | string | `1.15.4-1` |
| common_vault_version | Vault version to install | string | `1.14.0-1` |
| common_consul_template_version | Consul template version to install | string | `0.32.0-1` |
| common_reset_nomad | Clear Nomad data directory | boolean | `true` |
| common_dotfiles | List of dotfiles to be added, and their destinations | list | `[]` |

## Tags

- Skip `bw` to not install the Bitwarden CLI
- Skip `nfs` to not create any NFS share directories
- Skip `dotfiles` to not copy any remote dotfiles

## Notes

- This role clears any existing `/opt/nomad/data` directories to a blank slate. To disable this
behaviour, set `common_reset_nomad: false`.
- This role only supports Ubuntu/Debian amd64 systems with `apt`.
- The Hashicorp apt server [only supports amd64
packages](https://github.com/hashicorp/terraform/issues/27378). For arm64
systems, download the individual zip files instead.
- `common_dotfiles` is used to add dotfiles from a Github repository to the host.
For example:

```yml
common_dotfiles:
  - url: https://raw.githubusercontent.com/foo/repo/master/.vimrc
    dest: /home/foo/.vimrc
```
