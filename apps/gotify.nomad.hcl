job "gotify" {
  datacenters = ["dc1"]

  group "gotify" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "80"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.gotify-proxy.entrypoints=https",
        "traefik.http.routers.gotify-proxy.tls=true",
        "traefik.http.routers.gotify-proxy.rule=Host(`[[ .app.gotify.domain ]].[[ .common.domain ]]`)",
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

    task "gotify" {
      driver = "docker"

      config {
        image = "gotify/server:[[ .app.gotify.image ]]"
        ports = ["http"]

        volumes = [
          "[[ .app.gotify.volumes.data ]]:/app/data",
        ]
      }

      env {
        TZ                         = "Asia/Singapore"
        GOTIFY_DATABASE_DIALECT    = "sqlite3"
        GOTIFY_DATABASE_CONNECTION = "data/gotify.db"
        GOTIFY_DEFAULTUSER_NAME    = "admin"
        GOTIFY_DEFAULTUSER_PASS    = "admin"
        GOTIFY_UPLOADEDIMAGESDIR   = "data/images"
        GOTIFY_PLUGINSDIR          = "data/plugins"
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }
}
