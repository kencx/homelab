# Arch Repository

This role creates a custom local repository on an Arch Linux system. The
repository is used to host and cache built [AUR](https://aur.archlinux.org/)
packages for other Arch systems on the network.

## Prerequisites
- Target host must be an Arch Linux system

## Usage

The role installs an `aurutils` wrapper script that is used to interact with the
repository easily:

```bash
$ aur-wrapper add [package]
$ aur-wrapper remove [package]
$ aur-wrapper list
$ aur-wrapper sync
```

>**Note**: The script should be run as the `{{ arch_repository_user }}` stated
>in the role. It should **not** be run as root.

The role also installs the systemd service `update-aur.service` triggered hourly
by `update-aur.timer`. This service runs `aur-wrapper sync` periodically to
check for package updates.

## Hosting Remotely

For clients to use this repository remotely, the repository files must be hosted
via a webserver. Alternatively, it can also be mirrored to an S3 storage like
Minio.

Clients can then access the repository by adding the server's URL to their
`/etc/pacman.conf`.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| arch_repository_user | Repository user | string | `aur` |
| arch_repository_root_dir | Path to repository root directory | string | `/var/cache/pacman` |
| arch_repository_name | Repository name | string | `custom` |
| arch_repository_dir | Path to repository directory | string | `${arch_repository_root_dir}/${arch_repository_name}` |
| arch_repository_sig_level | Repository signature level | string | `Optional TrustAll` |
| arch_repository_url | Repository URL | string |`file://${arch_repository_dir }` |
| arch_repository_aurutils_temp_dir | Directory to install aurutils temporarily | string | `/tmp/aurutils` |
| arch_repository_sync_packages | Sync given AUR packages | bool | `false` |
| arch_repository_packages | List of AUR packages to sync | list(string) | `[aurutils]` |
