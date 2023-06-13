job "openbooks" {
  datacenters = ["dc1"]

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
        "traefik.http.routers.openbooks-proxy.rule=Host(`[[ .app.openbooks.domain ]].[[ .common.domain ]]`)",
      ]

      # healthcheck seems to cause openbooks to stop working
      # check {
      #   type     = "tcp"
      #   port     = "http"
      #   interval = "30s"
      #   timeout  = "5s"
      #
      #   success_before_passing   = "3"
      #   failures_before_critical = "3"
      # }
    }

    task "openbooks" {
      driver = "docker"

      config {
        image = "evanbuss/openbooks:[[ .app.openbooks.image ]]"
        ports = ["http"]
        args  = ["--persist", "--name", "changeme"]

        # download to browser only
        # volumes = [
        #   "[[ .app.openbooks.volumes.data ]]:/books",
        # ]
      }

      resources {
        cpu    = 100
        memory = 200
      }
    }
  }
}
