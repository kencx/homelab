job "actual" {
  datacenters = ${datacenters}

  group "actual" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "5006"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.actual-proxy.entrypoints=https",
        "traefik.http.routers.actual-proxy.tls=true",
        "traefik.http.routers.actual-proxy.rule=Host(`${actual_subdomain}.${domain}`)",
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

    task "actual" {
      driver = "docker"

      config {
        image = "ghcr.io/actualbudget/actual-server:${actual_image_version}"
        ports = ["http"]

        volumes = [
          "${actual_volumes_server}:/app/server-files",
          "${actual_volumes_user}:/app/user-files",
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      env {
        userFilesPath   = "./user-files"
        serverFilesPath = "./server-files"
        externalPort    = 5006
      }

      resources {
        cpu    = 25
        memory = 100
      }
    }
  }
}
