job "ghostfolio" {
  datacenters = ["dc1"]

  group "ghostfolio-app" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "3333"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.ghostfolio-proxy.entrypoints=https",
        "traefik.http.routers.ghostfolio-proxy.tls=true",
        "traefik.http.routers.ghostfolio-proxy.rule=Host(`[[ .app.ghostfolio.domain ]].[[ .common.domain ]]`)",
      ]

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "ghostfolio-redis"
              local_bind_port  = 6379
            }
          }
          tags = ["dummy"]
        }
      }

      check {
        type     = "http"
        path     = "/"
        port     = "http"
        interval = "30s"
        timeout  = "5s"

        success_before_passing   = "3"
        failures_before_critical = "3"

        check_restart {
          grace = "120s"
        }
      }
    }

    task "ghostfolio" {
      driver = "docker"

      config {
        image = "ghostfolio/ghostfolio:1.215.0"
        ports = ["http"]
      }

      env {
        REDIS_HOST = NOMAD_UPSTREAM_IP_ghostfolio_redis
        REDIS_PORT = NOMAD_UPSTREAM_PORT_ghostfolio_redis

        NODE_ENV          = "production"
        ACCESS_TOKEN_SALT = ""
        JWT_SECRET_KEY    = ""
      }

      template {
        data        = <<EOF
{{ range service "postgres" }}
DATABASE_URL = "postgresql://ghostfolio:ghostfolio@{{ .Address }}:{{ .Port }}/ghostfolio"
{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/.env"
        env         = true
      }

      resources {
        cpu    = 100
        memory = 300
      }
    }
  }

  group "ghostfolio-redis" {
    count = 1

    network {
      mode = "bridge"
      port "redis" {
        to = "6379"
      }
    }

    service {
      provider = "consul"
      name     = "ghostfolio-redis"
      port     = "6379"

      connect {
        sidecar_service {
          disable_default_tcp_check = true
        }
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6"
        ports = ["redis"]
      }

      resources {
        cpu    = 20
        memory = 128
      }
    }
  }
}
