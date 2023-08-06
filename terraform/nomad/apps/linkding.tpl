job "linkding" {
  datacenters = ${datacenters}

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
        "traefik.http.routers.linkding-proxy.rule=Host(`${linkding_subdomain}.${domain}`)",
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
        image = "sissbruecker/linkding:${linkding_image_version}"
        ports = ["http"]

        volumes = [
          "${linkding_volumes_data}:/etc/linkding/data",
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      vault {
        policies = ["nomad_linkding"]
      }

      env {
        LD_DISABLE_BACKGROUND_TASKS = "False"
        LD_DISABLE_URL_VALIDATION   = "False"
      }

      template {
        data        = <<EOF
{{ with secret "kvv2/data/prod/nomad/linkding" }}
LD_SUPERUSER_NAME="{{ .Data.data.username }}"
LD_SUPERUSER_PASSWORD="{{ .Data.data.password }}"
{{ end }}
EOF
        destination = "secrets/auth.env"
        env         = true
      }

      resources {
        cpu    = 50
        memory = 256
      }
    }
  }
}
