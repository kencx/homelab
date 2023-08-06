job "postgres" {
  datacenters = ${datacenters}

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
        name     = "TCP check"
        type     = "tcp"
        port     = "db"
        interval = "30s"
        timeout  = "10s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }

      check {
        name     = "Postgres check"
        type     = "script"
        command  = "pg_isready"
        args     = ["-U", "postgres"]
        task     = "postgres"
        interval = "30s"
        timeout  = "10s"
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:${postgres_image_version}"
        ports = ["db"]

        volumes = [
          "${postgres_volumes_data}:/var/lib/postgresql/data",
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      env {
        POSTGRES_USER     = "postgres"
        # Temporary root password on startup. This will be reset and managed by Vault.
        POSTGRES_PASSWORD = "postgres"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
