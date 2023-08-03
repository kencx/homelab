# Diun

[Diun](https://crazymax.dev/diun/) is used to monitor Docker images for new
updates.

## Configuration

```yml
watch:
  workers: 10
  schedule: "0 0 * * 5"
  jitter: 30s
  firstCheckNotif: false

providers:
  docker:
    watchByDefault: false

notif:
  telegram:
    # Telegram bot token
    token: aabbccdd:11223344
    # Telegram chat ID
    chatIDs:
      - 123456789
    templateBody: |
      Docker tag {{ .Entry.Image }} which you subscribed to through {{ .Entry.Provider }} provider has been released.
```

## Watch Images

To opt in to watching a Docker image, include the `diun.enable`
Docker label:

```hcl
config {
  labels = {
    "diun.enable" = "true"
  }
}
```

By default, this will only watch the current tag of the image. If the tag is
`latest`, Diun will send a notification when that tag's checksum changes.

To allow Diun to watch other tags, include additional labels:

```hcl
config {
  labels = {
    "diun.enable"     = "true"
    "diun.watch_repo" = "true"
    "diun.max_tags"   = 3
  }
}
```

This will let Diun watch all tags in the Docker repo. It is highly recommended
to set a maximum number of tags that Diun should watch, otherwise Diun will
watch ALL tags, including older ones.

### Command Line

```bash
# manipulate images in database
$ docker exec diun diun image list
$ docker exec diun diun image inspect --image=[image]
$ docker exec diun diun image remove --image=[image]

# send test notification
$ docker exec diun diun notif test
```

## References
- [Diun](https://crazymax.dev/diun/)
