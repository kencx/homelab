job "paperless" {
  datacenters = ${datacenters}

  group "paperless-app" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "8000"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.paperless-proxy.entrypoints=https",
        "traefik.http.routers.paperless-proxy.tls=true",
        "traefik.http.routers.paperless-proxy.rule=Host(`${paperless_subdomain}.${domain}`)",
      ]

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "paperless-redis"
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
      }
    }

    task "paperless" {
      driver = "docker"

      config {
        image              = "ghcr.io/paperless-ngx/paperless-ngx:${paperless_image_version}"
        image_pull_timeout = "10m"
        ports              = ["http"]

        volumes = [
          "paperless_volumes_data:/usr/src/paperless/data",
          "paperless_volumes_consume:/usr/src/paperless/consume",
          "paperless_volumes_media:/usr/src/paperless/media",
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      env {
        USERMAP_UID         = 1000
        USERMAP_GID         = 1000
        PAPERLESS_TIME_ZONE = "${timezone}"
        PAPERLESS_URL       = "https://${paperless_subdomain}.${domain}"
        PAPERLESS_REDIS     = "redis://$${NOMAD_UPSTREAM_ADDR_paperless_redis}"

        PAPERLESS_SECRET_KEY   = ""
        PAPERLESS_OCR_LANGUAGE = "eng"

        # default 0, set to 1 on pi
        PAPERLESS_OCR_PAGES = 1

        # default 2, set to 1 on pi
        PAPERLESS_WEBSERVER_WORKERS = 1

        # traefik
        PAPERLESS_HTTP_REMOTE_USER_HEADER_NAME = HTTP_X_FORWARDED_USER
        PAPERLESS_ALLOWED_HOSTS                = "$${NOMAD_IP_http},localhost"

        # refer to docs
        PAPERLESS_TASKS_WORKERS      = 2
        PAPERLESS_THREADS_PER_WORKER = 1

        PAPERLESS_ADMIN_USER     = ""
        PAPERLESS_ADMIN_PASSWORD = ""
        PAPERLESS_ADMIN_MAIL     = ""
      }

      resources {
        cpu    = 50
        memory = 400
      }
    }
  }

  group "paperless-redis" {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      provider = "consul"
      name     = "paperless-redis"
      port     = "6379"

      connect {
        sidecar_service {}
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
