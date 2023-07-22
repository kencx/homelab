job "mariadb" {
  datacenters = ["dc1"]

  group "mariadb" {
    count = 1

    network {
      mode = "bridge"
      port "db" {
        to = "3306"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "db"
    }

    task "mariadb" {
      driver = "docker"
      user   = "1000"

      config {
        image = "mariadb:[[ .app.mariadb.image ]]"

        volumes = [
          "[[ .app.firefly.volumes.db ]]:/var/lib/mysql",
        ]
      }

      env {
        MYSQL_RANDOM_ROOT_PASSWORD = "yes"
        MYSQL_USER                 = "firefly"
        MYSQL_PASSWORD             = "changeme"
        MYSQL_DATABASE             = "firefly"
      }

      resources {
        cpu    = 35
        memory = 256
      }
    }
  }
}
