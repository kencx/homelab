job "firefly" {
  datacenters = ["dc1"]

  group "firefly" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "8080"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.firefly-proxy.entrypoints=https",
        "traefik.http.routers.firefly-proxy.tls=true",
        "traefik.http.routers.firefly-proxy.rule=Host(`[[ .app.firefly.domain ]].[[ .common.domain ]]`)",
      ]

      check {
        type     = "http"
        path     = "/health"
        port     = "http"
        interval = "30s"
        timeout  = "5s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }
    }

    task "firefly" {
      driver = "docker"

      config {
        image = "fireflyiii/core:[[ .app.firefly.image ]]"
        ports = ["http"]

        volumes = [
          "[[ .app.firefly.volumes.data ]]:/var/www/html/storage/upload",
        ]
      }

      env {
        TZ               = "Asia/Singapore"
        DEFAULT_LANGUAGE = "en_US"
        DEFAULT_LOCALE   = "equal"
        APP_ENV          = "local"
        APP_DEBUG        = false
        SITE_OWNER       = "mail@example.com"
        APP_KEY          = ""
        TRUSTED_PROXIES  = "**"
        LOG_CHANNEL      = "stack"
        APP_LOG_LEVEL    = "notice"
        AUDIT_LOG_LEVEL  = "info"

        DB_CONNECTION = "mysql"
        DB_DATABASE   = "firefly"
        DB_USERNAME   = "firefly"
        DB_PASSWORD   = "changeme"

        MYSQL_USE_SSL = false
      }

      template {
        data        = <<EOF
{{ range service "mariadb" }}
DB_HOST = {{ .Address }}
DB_PORT = {{ .Port }}
{{ end }}
EOF
        destination = "secrets/.env"
        env         = true
      }

      resources {
        cpu    = 35
        memory = 256
      }
    }
  }
}
