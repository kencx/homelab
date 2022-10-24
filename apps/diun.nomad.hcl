job "diun" {
  datacenters = ["dc1"]

  group "diun" {
    count = 1

    task "diun" {
      driver = "docker"

      config {
        image   = "crazymax/diun"
        command = "serve"

        volumes = [
          "/mnt/storage/diun:/data",
          "local/diun.yml:/diun.yml",
          "/var/run/docker.sock:/var/run/docker.sock",
        ]

        labels = {
          "diun.enable" = "true"
        }
      }

      env {
        TZ        = "Asia/Singapore"
        LOG_LEVEL = "info"
        LOG_JSON  = false
      }

      template {
        data        = <<EOF
watch:
  workers: 10
  schedule: "0 */6 * * *"
  firstCheckNotif: false

providers:
  docker:
    watchByDefault: false

notif:
  gotify:
    endpoint: "[[ .app.gotify.domain ]].[[ .common.domain ]]"
    token: ""
    priority: 1
    timeout: "10s"
EOF
        destination = "${NOMAD_TASK_DIR}/diun.yml"
      }

      resources {
        cpu    = 30
        memory = 128
      }
    }
  }
}
