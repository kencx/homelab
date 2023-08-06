job "calibre" {
  datacenters = ${datacenters}

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
        "traefik.http.routers.calibre-proxy.rule=Host(`${calibre_web_subdomain}.${domain}`)",
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
        image = "lscr.io/linuxserver/calibre-web:${calibre_web_image_version}"
        ports = ["http"]

        volumes = [
          "${calibre_web_volumes_config}:/config",
          "${calibre_web_volumes_books}:/books",
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
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
