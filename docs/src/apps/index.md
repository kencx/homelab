# Applications

## Actual

- On first startup, you will be prompted to secure the new server with a password.

## Calibre Web

- Point the `books` bind mount to an existing
[calibre](https://github.com/kovidgoyal/calibre) database with the books
metadata.

## Gotify

- Populate `GOTIFY_DEFAULTUSER_NAME` and `GOTIFY_DEFAULTUSER_PASS` with custom
credentials.

## Linkding

- Populate `LD_SUPERUSER_NAME` and `LD_SUPERUSER_PASSWORD` with custom
credentials.

## yarr

- Populate the `AUTH_FILE` environment variable with custom credentials
in the form `username:password`.
