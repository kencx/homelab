job "diun" {
  datacenters = ["dc1"]

  group "diun" {
    count = 1

    task "diun" {
      driver = "docker"

      config {
        image   = "ghcr.io/crazy-max/diun:[[ .app.diun.image ]]"
        command = "serve"

        volumes = [
          "[[ .app.diun.volumes.data ]]:/data",
          "secrets/diun.yml:/etc/diun/diun.yml",
          "/var/run/docker.sock:/var/run/docker.sock",
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      vault {
        policies = ["nomad_diun"]
      }

      env {
        TZ        = "[[ .common.tz ]]"
        LOG_LEVEL = "info"
        LOG_JSON  = false
      }

      template {
        data        = <<EOF
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
{{ with secret "kvv2/data/prod/nomad/diun" }}
    token: {{ .Data.data.tg_bot_token }}
    chatIDs:
      - {{ .Data.data.tg_chat_id }}
{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/diun.yml"
      }

      resources {
        cpu    = 30
        memory = 128
      }
    }
  }
}
