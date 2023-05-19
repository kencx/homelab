job "uptime" {
  datacenters = ["dc1"]

  group "uptime" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "3001"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.uptime-proxy.entrypoints=https",
        "traefik.http.routers.uptime-proxy.tls=true",
        "traefik.http.routers.uptime-proxy.rule=Host(`[[ .app.uptime-kuma.domain ]].[ .common.domain ]`)",
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

    task "uptime" {
      driver = "docker"

      config {
        image = "louislam/uptime-kuma:1"
        ports = ["http"]

        volumes = [
          "[[ .app.uptime-kuma.volumes.data ]]:/app/data",
        ]
      }

      env {
        PUID = 1000
        PGID = 1000
      }

      resources {
        cpu    = 35
        memory = 200
      }
    }
  }
}
