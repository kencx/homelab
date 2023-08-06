job "diun" {
  datacenters = ${datacenters}

  group "diun" {
    count = 1

    task "diun" {
      driver = "docker"

      config {
        image   = "ghcr.io/crazy-max/diun:${diun_image_version}"
        command = "serve"

        volumes = [
          "${diun_volumes_data}:/data",
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
        TZ        = "${timezone}"
        LOG_LEVEL = "info"
        LOG_JSON  = false
      }

      template {
        data        = <<EOF
watch:
  workers: 10
  schedule: "${diun_watch_schedule}"
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
        destination = "$${NOMAD_SECRETS_DIR}/diun.yml"
      }

      resources {
        cpu    = 30
        memory = 128
      }
    }
  }
}
