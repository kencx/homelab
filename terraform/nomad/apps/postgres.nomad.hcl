job "postgres" {
  datacenters = ["dc1"]

  group "postgres" {
    count = 1

    network {
      mode = "bridge"
      port "db" {
        to = "5432"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "db"

      check {
        type     = "tcp"
        port     = "db"
        interval = "30s"
        timeout  = "10s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:[[ .app.postgres.image ]]"
        ports = ["db"]

        volumes = [
          "[[ .app.postgres.volumes.data ]]:/var/lib/postgresql/data",
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      env {
        POSTGRES_USER     = "postgres"
        POSTGRES_PASSWORD = "postgres"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
