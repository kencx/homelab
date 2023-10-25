job "pigallery2" {
  datacenters = ${datacenters}

  group "pigallery2" {
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
        "traefik.http.routers.pigallery2-proxy.entrypoints=https",
        "traefik.http.routers.pigallery2-proxy.tls=true",
        "traefik.http.routers.pigallery2-proxy.rule=Host(`${pigallery2_subdomain}.${domain}`)",
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

    task "pigallery2" {
      driver = "docker"

      config {
        image = "bpatrik/pigallery2:${pigallery2_image_version}"
        ports = ["http"]

        volumes = [
          "${pigallery2_volumes_config}:/app/data/config",
          "${pigallery2_volumes_data}:/app/data/db",
          "${pigallery2_volumes_images}:/app/data/images",
          "${pigallery2_volumes_tmp}:/app/data/tmp",
        ]
      }

      env {
        NODE_ENV = "production"
      }

      resources {
        cpu    = 300
        memory = 512
      }
    }
  }
}
