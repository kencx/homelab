This role configures a NAS system by setting up NFS mounts and restic backups.
See [backups](../backups.md) for more information.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| nas_user | User to be created | string | `debian` |
| nas_nfs_exports | NFS directories to be exported | dict | `{}` |
| nas_backup_partition | Backup disk partition | string | `/dev/sdb1` |
| nas_backup_mount_dir | Backup mount location | string | `/mnt/kd` |
| nas_backup_time | Time to start daily backup | string | `06:00:00` |
| restic_version | Latest restic version to install | string | `0.15.2` |
| autorestic_version | Latest autorestic version to install | string | `1.7.7` |
| autorestic_bin_dir | Backup script location | string | `/usr/local/bin` |
| autorestic_config_dir | Autorestic config file directory | string | `/root` |
| autorestic_log_dir | Autorestic log file directory | string | `/var/log/autorestic` |
| autorestic_log_file | Autorestic log file | string |`${autorestic_log_dir }/autorestic.log` |
| autorestic_config | Full autorestic configuration | dict | See `defaults.yml` or [autorestic docs](https://autorestic.vercel.app/config) |

- `nas_nfs_exports` should have the following structure:

```
nas_nfs_exports:
  - dir: /home/debian/apps
    ip: 10.10.10.2
    opts: rw,sync,no_subtree_check,no_root_squash
```
