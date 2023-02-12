job "name" {
  datacenters = ["dc1"]

  group "name" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "9999"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.name-proxy.entrypoints=https",
        "traefik.http.routers.name-proxy.tls=true",
        "traefik.http.routers.name-proxy.rule=Host(`[[ .app.name.domain ]].[[ .common.domain ]]`)",
      ]

      check {
        type     = "http"
        path     = "/"
        port     = "http"
        interval = "30s"
        timeout  = "5s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }
    }

    task "name" {
      driver = "docker"

      config {
        image = ""
        ports = ["http"]

        volumes = [
          "[[ .app.name.volumes.data ]]:/data",
        ]

        labels = {
          "diun.enable" = "true"
        }
      }

      env {
      }

      template {
        data        = <<EOF
YARR_AUTH="user:pass"
EOF
        destination = "secrets/auth.env"
        env         = true
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }
}
