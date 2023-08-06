job "openbooks" {
  datacenters = ${datacenters}

  group "openbooks" {
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
        "traefik.http.routers.openbooks-proxy.entrypoints=https",
        "traefik.http.routers.openbooks-proxy.tls=true",
        "traefik.http.routers.openbooks-proxy.rule=Host(`${openbooks_subdomain}.${domain}`)",
      ]
    }

    task "openbooks" {
      driver = "docker"

      config {
        image = "evanbuss/openbooks:${openbooks_image_version}"
        ports = ["http"]
        args  = ["--persist", "--name", "foo"]

        # Download to browser only. Uncomment if we want to save downloads to
        # filesystem.
        # volumes = [
        #   "${openbooks_volumes_books}:/books",
        # ]
      }

      resources {
        cpu    = 100
        memory = 200
      }
    }
  }
}
