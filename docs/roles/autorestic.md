!!! warning "Work in Progress"
    This role is unfinished and untested.

This role installs and configures restic and autorestic for automated backups.
See [backups](../backups.md) for more information.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| nas_user | User | string | `debian`
| nas_backup_partition | Backup disk partition | string | |
| nas_backup_mount_dir | Backup mount location | string | |
| nas_backup_restore_dir | Backup restore test directory | string | `/home/${nas_user}/restore-test` |
| nas_backup_export_dir | Backup metrics directory | string | `/home/${nas_user}/node_exporter` |
| nas_backup_export_file | Backup metrics file | string | `${nas_backup_export_dir}/restic.prom` |
| nas_backup_time | Time to start daily backup | string | `06:00:00` |
| restic_version | Latest restic version to install | string | `0.15.2` |
| autorestic_version | Latest autorestic version to install | string | `1.7.7` |
| autorestic_bin_dir | Backup script location | string | `/usr/local/bin` |
| autorestic_config_dir | Autorestic config file directory | string | `/root` |
| autorestic_log_dir | Autorestic log file directory | string | `/var/log/autorestic` |
| autorestic_log_file | Autorestic log file | string |`${autorestic_log_dir }/autorestic.log` |
| autorestic_locations | Autorestic locations | list(dict) | |
| autorestic_backends | Autorestic backends | list(dict) | |
| autorestic_forget | Autorestic forget schedule | dict | |

- Examples of `autorestic_*` variables:

```yml
autorestic_locations:
  - name: foo
    from: /path/to/foo
    to: [hdd, remote]
    options:
      exclude: ["bar", "baz"]
  - name: bar
    from: /path/to/bar
    to: [hdd, remote]
autorestic_backends:
  - name: hdd
    type: local
    path: "{{ nas_backup_mount_dir }}/restic"
  - name: remote
    type: b2
    path: "foo"
autorestic_forget:
  keep_daily: 7
  keep_weekly: 4
  keep_monthly: 3
  keep_yearly: 1
```
