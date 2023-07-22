job "yarr" {
  datacenters = ["dc1"]

  group "yarr" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "7070"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.yarr-proxy.entrypoints=https",
        "traefik.http.routers.yarr-proxy.tls=true",
        "traefik.http.routers.yarr-proxy.rule=Host(`[[ .app.yarr.domain ]].[[ .common.domain ]]`)",
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

    task "yarr" {
      driver = "docker"

      config {
        image = "ghcr.io/kencx/yarr:[[ .app.yarr.image ]]"
        ports = ["http"]

        volumes = [
          "[[ .app.yarr.volumes.data ]]:/data",
        ]

        /* labels = { */
        /*   "diun.enable" = "true" */
        /* } */
      }

      vault {
        policies = ["nomad_yarr"]
      }

      template {
        data        = <<EOF
{{ with secret "kvv2/data/prod/nomad/yarr" }}
YARR_AUTH="{{ .Data.data.username }}":"{{ .Data.data.password }}"
{{ end }}
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
