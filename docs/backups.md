# Backups

## Overview

The backup plan follows the [3-2-1 backup
strategy](https://www.backblaze.com/blog/the-3-2-1-backup-strategy). It ensures
backups are automatic, redundant and offsite with restic,
[autorestic](https://autorestic.vercel.app/) and systemd.

## Setup

An `autorestic-backup` script is run daily with autorestic and systemd. It
requires:

- An external hard drive
- A [Backblaze](https://www.backblaze.com/b2/cloud-storage.html) B2 account

The script and systemd units can be configured via the Ansible [nas
role](roles/nas.md) or manually.

## Configuration

1. Ensure the external hard drive is present and functional.
2. Configure the `autorestic-backup` script with the backup drive's partition.
3. Configure `autorestic.yml` (see [autorestic docs](https://autorestic.vercel.app/config) ).
4. Configure `autorestic.env` with the correct credentials.

### Credentials

Backblaze requires a Backblaze keyID and Backblaze application key for the
specified Backblaze path.

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
