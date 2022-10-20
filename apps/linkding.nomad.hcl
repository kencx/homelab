variable "domain_name" {
  type = string
}

job "linkding" {
  datacenters = ["dc1"]

  group "linkding" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "9090"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.linkding-proxy.entrypoints=https",
        "traefik.http.routers.linkding-proxy.tls=true",
        "traefik.http.routers.linkding-proxy.rule=Host(`[[ .app.linkding.domain ]].[[ .common.domain ]]`)",
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

    task "linkding" {
      driver = "docker"

      config {
        image = "sissbruecker/linkding:1.15.1"
        ports = ["http"]

        volumes = [
          "[[ .app.linkding.volumes.data ]]:/etc/linkding/data",
        ]

        labels = {
          "diun.enable" = "true"
        }
      }

      env {
        LD_DISABLE_BACKGROUND_TASKS = "False"
        LD_DISABLE_URL_VALIDATION   = "False"
        LD_SUPERUSER_NAME           = ""
        LD_SUPERUSER_PASSWORD       = ""
      }

      resources {
        cpu    = 35
        memory = 512
      }
    }
  }
}
