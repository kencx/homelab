job "registry" {
  datacenters = ${datacenters}

  group "registry" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "5000"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.registry-proxy.entrypoints=https",
        "traefik.http.routers.registry-proxy.tls=true",
        "traefik.http.routers.registry-proxy.rule=Host(`${registry_subdomain}.${domain}`)",
      ]

      check {
        type     = "tcp"
        port     = "http"
        interval = "30s"
        timeout  = "5s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }
    }

    task "registry" {
      driver = "docker"

      config {
        image = "registry:${registry_image_version}"
        ports = ["http"]

        volumes = [
          "${registry_volumes_data}:/var/lib/registry",
          "secrets/auth:/auth"
        ]

        # labels = {
        #   "diun.enable" = "true"
        # }
      }

      env {
        REGISTRY_AUTH                = "htpasswd"
        REGISTRY_AUTH_HTPASSWD_PATH  = "/auth/htpasswd"
        REGISTRY_AUTH_HTPASSWD_REALM = "Registry Realm"
      }

      vault {
        policies = ["nomad_registry"]
      }

      template {
        data        = <<EOF
{{ with secret "kvv2/data/prod/nomad/registry" }}
{{ .Data.data.htpasswd }}
{{ end }}
EOF
        destination = "$${NOMAD_SECRETS_DIR}/auth/htpasswd"
        perms       = "0600"
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }
}
