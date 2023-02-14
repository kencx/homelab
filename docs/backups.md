# Backups

## Overview

The backup plan follows the [3-2-1 backup
strategy](https://www.backblaze.com/blog/the-3-2-1-backup-strategy). It ensures
backups are automatic, redundant and offsite with restic,
[autorestic](https://autorestic.vercel.app/) and cron.

## Configuration

1. Populate `autorestic.yml` appropriately.
2. Populate `autorestic.env`:

```
AUTORESTIC_HDD_RESTIC_PASSWORD=

AUTORESTIC_REMOTE_RESTIC_PASSWORD=
AUTORESTIC_REMOTE_B2_ACCOUNT_ID=
AUTORESTIC_REMOTE_B2_ACCOUNT_KEY=
```

3. Populate variables in `backup-script`:

```bash
# UUID of external hard drive
DISK_UUID=

# Mount point of external hard drive
MOUNT_DIR=

# location of .autorestic.yml file
CONFIG_DIR=
```

### Backblaze

Backblaze requires a Backblaze keyID and Backblaze application key for the
specified Backblaze path.

## Usage

Check the configuration for any issues

```
$ autorestic check
```

Perform a backup on all locations

```bash
$ autorestic backup -av [--ci]
```

### Check

```bash
# check snapshots
$ autorestic exec check -av

# list snapshots
$ autorestic exec snapshots -av
$ autorestic exec stats [snapshot-id]
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
