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
        image = "postgres:14-alpine3.16"
        ports = ["db"]

        volumes = [
          "[[ .app.postgres.volumes.data ]]:/var/lib/postgresql/data",
          "local/init.sql:/docker-entrypoint-initdb.d/init.sql",
        ]

        labels = {
          "diun.enable" = "true"
        }
      }

      env {
        POSTGRES_USER     = "postgres"
        POSTGRES_PASSWORD = "postgres"
      }

      template {
        data        = <<EOF
CREATE USER john WITH PASSWORD 'password';
CREATE DATABASE foo;
GRANT ALL PRIVILEGES ON DATABASE foo TO john;
EOF
        destination = "local/init.sql"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
