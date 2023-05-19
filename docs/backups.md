# Backups

Daily backups are performed on a central NAS server that stores all persistent
data. The backup plan aims to be automatic, redundant and offsite by following
the [3 2 1](https://www.backblaze.com/blog/the-3-2-1-backup-strategy) rule. The
setup uses [restic](https://restic.readthedocs.io/en/stable/) and
[autorestic](https://autorestic.vercel.app/), a CLI wrapper for restic, to
perform fast and encrypted backups to a local USB hard drive and an offsite
Backblaze B2 bucket.

## Execution

A custom `autorestic-backup` script is run daily with systemd timers. The script
requires an external hard drive and a
[Backblaze](https://www.backblaze.com/b2/cloud-storage.html) account. The script
and systemd units are installed and configured via the Ansible [autorestic
role](roles/autorestic.md).

The script performs the following:

1. Perform backup based on given `autorestic.yml` configuration
2. Prune and forget old snapshots based on configuration
3. Run restoration tests to verify data integrity

### Tests

To verify the integrity of the backups, the script performs limited restoration
tests on the latest restic snapshot. While complete restores would be more
representative of the data, they are too unfeasible.

The restoration tests involve:

- Checking a subset of all data with [restic
  check](https://restic.readthedocs.io/en/stable/045_working_with_repos.html#checking-integrity-and-consistency)
  (1% in my case)
- Restoring test files and comparing them to the original

Before every backup, a `generate-restore-test-files` script is executed to
generate a test file with random contents to a specified directory. This
directory stores the last 5 generated test files. After every backup, we restore
all files in the test directory and `diff` them with the original. The
backup fails if any of the files are different.

## Configuration

Configuration can be performed via the Ansible [autorestic
role](roles/autorestic.md) or manually.

- Ensure the external hard drive is present and functional.
- Configure the `autorestic-backup` script with the backup drive's partition.
- Configure `autorestic.yml` (see [autorestic
  docs](https://autorestic.vercel.app/config) ).
- Configure `autorestic.env` with the correct credentials.

### Credentials

Backblaze requires a Backblaze keyID and Backblaze application key for the
specified Backblaze path.

## Monitoring

After a successful backup, a custom `backup-exporter` script parses the log file
and generates Prometheus metrics for consumption by node exporter's
textfile-collector. These metrics are sent to Prometheus where they can be used
to visualize backup metrics and send alerts on failure.

## Usage

Check the configuration for any issues

```
$ autorestic check [--config /path/to/config]
```

Perform a backup on all locations

```bash
$ autorestic backup -av [--ci]
```

### Check

```bash
# check snapshots
$ autorestic exec -av -- check

# list snapshots
$ autorestic exec -av -- snapshots
$ autorestic exec -- stats [snapshot-id]
```

### Restore

```bash
$ autorestic restore -l [location] --from [backend] --to /path/where/to/restore

# restore specific file or dir
$ autorestic restore latest -l [location] --to /path/where/to/restore --include /path/to/restore
```

## Troubleshooting

### An instance is already running

1. Check for an `.autorestic.lock.yml` file.
2. Delete the file if there is no running instance of autorestic or restic.
3. Run `autorestic exec check -av` to check all snapshots.
