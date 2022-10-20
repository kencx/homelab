job "miniflux" {
  datacenters = ["dc1"]

  group "miniflux" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "8120"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.miniflux-proxy.entrypoints=https",
        "traefik.http.routers.miniflux-proxy.tls=true",
        "traefik.http.routers.miniflux-proxy.rule=Host(`[[ .app.miniflux.domain ]].[[ .common.domain ]]`)",
      ]

      check {
        type     = "http"
        path     = "/healthcheck"
        port     = "http"
        interval = "30s"
        timeout  = "5s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }
    }

    task "miniflux" {
      driver = "docker"

      config {
        image = "miniflux/miniflux:2.0.36"
        ports = ["http"]
      }

      env {
        PORT              = 8120
        DEBUG             = 1
        RUN_MIGRATIONS    = 1
        POLLING_FREQUENCY = 1440
        CREATE_ADMIN      = 1
        ADMIN_USERNAME    = "miniflux"
        ADMIN_PASSWORD    = "miniflux"
      }

      template {
        data        = <<EOF
{{ range service "postgres" }}
DATABASE_URL = "postgres://postgres:postgres@{{ .Address }}:{{ .Port }}/miniflux?sslmode=disable"
{{ end }}
EOF
        destination = "secrets/.env"
        env         = true
      }

      resources {
        cpu    = 35
        memory = 256
      }
    }
  }
}
