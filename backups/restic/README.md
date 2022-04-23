# restic

## Install
`init-restic` installs restic as an unprivileged user that still allows for root read access. This is useful to perform full backups without having to run restic as root all the time.

Refer to the [restic docs](https://restic.readthedocs.io/en/stable/080_examples.html#backing-up-your-system-without-running-restic-as-root) for more details.

## restic commands
When running restic commands, we must pass the repo path through the command line or as environment variables. This can be difficult to manage when you have 2 or more separate repositories. It is more useful to create separate "commands" or scripts for each restic repo. `restic-temp` provides a template to run restic with custom environment variables.

For example, `restic-local` is used solely for local backups:
```bash
export RESTIC_REPOSITORY="path/to/repo"
export RESTIC_PASSWORD_FILE="path/to/password/file"

/home/restic/bin/restic "$@"
```
and `restic-remote` is used solely for remote backups.

## cronjobs
`local_backup` and `remote_backup` are backup scripts powered by restic. They backup the user's home directory and can be automated with crontabs.

To note:
- Both scripts use their respective restic command (eg. `restic-local`)
- Both scripts log to `$HOME/logs/restic.log` by default
- `local_backup` requires a `MOUNT_POINT` to be specified AND requires the disk to be added to `/etc/fdisk`

## References
- [restic docs](https://restic.readthedocs.io/en/stable/)
- [Centralised backups with restic and rsync](https://webworxshop.com/centralised-backups-with-restic-and-rsync/)
- [Managing repository env variables](https://forum.restic.net/t/recipes-for-managing-repository-environment-variables/1716)
