job "string" {
  datacenters = ["dc1"]

  group "string" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "3000"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.string-proxy.entrypoints=https",
        "traefik.http.routers.string-proxy.tls=true",
        "traefik.http.routers.string-proxy.rule=Host(`[[ .app.string.domain ]].[[ .common.domain ]]`)",
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

    task "string" {
      driver = "docker"

      config {
        image = "daveperrett/string-is:v1.34.4"
        ports = ["http"]
      }

      resources {
        cpu    = 35
        memory = 256
      }
    }
  }
}
