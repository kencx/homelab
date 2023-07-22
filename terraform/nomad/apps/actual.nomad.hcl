job "actual" {
  datacenters = ["dc1"]

  group "actual" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "5006"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.actual-proxy.entrypoints=https",
        "traefik.http.routers.actual-proxy.tls=true",
        "traefik.http.routers.actual-proxy.rule=Host(`[[ .app.actual.domain ]].[[ .common.domain ]]`)",
      ]

      check {
        type     = "http"
        path     = "/health"
        port     = "http"
        interval = "30s"
        timeout  = "5s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }
    }

    task "actual" {
      driver = "docker"

      config {
        image = "ghcr.io/actualbudget/actual-server:[[ .app.actual.image ]]"
        ports = ["http"]

        volumes = [
          "[[ .app.actual.volumes.server ]]:/app/server-files",
          "[[ .app.actual.volumes.user ]]:/app/user-files",
        ]

        labels = {
          "diun.enable" = "true"
        }
      }

      env {
        userFilesPath   = "./user-files"
        serverFilesPath = "./server-files"
        externalPort    = 5006
      }

      resources {
        cpu    = 25
        memory = 100
      }
    }
  }
}
