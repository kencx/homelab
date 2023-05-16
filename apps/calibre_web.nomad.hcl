job "calibre" {
  datacenters = ["dc1"]

  group "calibre" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "8083"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.calibre-proxy.entrypoints=https",
        "traefik.http.routers.calibre-proxy.tls=true",
        "traefik.http.routers.calibre-proxy.rule=Host(`[[ .app.calibre_web.domain ]].[[ .common.domain ]]`)",
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

    task "calibre" {
      driver = "docker"

      config {
        image = "lscr.io/linuxserver/calibre-web:[[ .app.calibre_web.image ]]"
        ports = ["http"]

        volumes = [
          "[[ .app.calibre_web.volumes.config ]]:/config",
          "[[ .app.calibre_web.volumes.books ]]:/books",
        ]

        labels = {
          "diun.enable" = "true"
        }
      }

      env {
        PUID = 1000
        PGID = 1000
        TZ   = "Asia/Singapore"
      }

      resources {
        cpu    = 35
        memory = 512
      }
    }
  }
}
