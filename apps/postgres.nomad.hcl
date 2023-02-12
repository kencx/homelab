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
          "local/bin:/docker-entrypoint-initdb.d",
        ]

        labels = {
          "diun.enable" = "true"
        }
      }

      env {
        POSTGRES_USER      = "postgres"
        POSTGRES_PASSWORD  = "postgres"
        MULTIPLE_DATABASES = "ghostfolio"
      }

      template {
        data        = <<EOF
#!/bin/sh

set -eu

create_user_and_database() {
	database=$1
	echo "  Creating user and database '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    CREATE USER $database;
        ALTER USER $database WITH PASSWORD '$database';
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $database;
EOSQL
}

if [ -n "$MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $MULTIPLE_DATABASES"
	for db in $(echo "$MULTIPLE_DATABASES" | tr ',' ' '); do
		create_user_and_database "$db"
	done
	echo "Multiple databases created"
fi
EOF
        destination = "${NOMAD_TASK_DIR}/bin/init.sh"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
