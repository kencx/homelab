job "whoami" {
  datacenters = ["dc1"]

  group "whoami" {
    count = 2

    network {
      mode = "bridge"
      port "http" {}
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.whoami-proxy.entrypoints=https",
        "traefik.http.routers.whoami-proxy.tls=true",
        "traefik.http.routers.whoami-proxy.rule=Host(`[[ .app.whoami.domain ]].[[ .common.domain ]]`)",
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

    task "whoami" {
      driver = "docker"

      config {
        image = "traefik/whoami"
        ports = ["http"]
        args  = ["--port", "${NOMAD_PORT_http}"]
      }

      resources {
        cpu    = 5
        memory = 32
      }
    }
  }
}
