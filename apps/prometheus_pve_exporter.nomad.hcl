job "pve_exporter" {
  datacenters = ["dc1"]

  group "pve_exporter" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = "9221"
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "http"
    }

    task "pve_exporter" {
      driver = "docker"

      config {
        image = "prompve/prometheus-pve-exporter:2.2.4"
        ports = ["http"]

        volumes = [
          "secrets/pve.yml:/etc/pve.yml",
        ]

        labels = {
          "diun.enable" = "true"
        }
      }

      template {
        data        = <<EOF
default:
    user:
    password:
    verify_ssl: false
EOF
        destination = "${NOMAD_SECRETS_DIR}/pve.yml"
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }
}
