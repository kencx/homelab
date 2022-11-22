job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"

  group "monitoring" {
    count = 1

    network {
      port "ui" {
        to = "9090"
      }
    }

    service {
      name = "prometheus"
      tags = ["urlprefix-/"]
      port = "ui"

      check {
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "5s"
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus"
        ports = ["ui"]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "secrets/tls:/etc/prometheus/tls",
        ]
      }

      template {
        data        = <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'nomad_metrics'
    consul_sd_configs:
      - server: "consul.service.consul:8501"
        scheme: "https"
        services: ['nomad-client', 'nomad']
        tls_config:
          ca_file: "tls/prom-client.dc1.consul-ca.crt"
          cert_file: "tls/prom-client.dc1.consul-cert.crt"
          key_file: "tls/prom-client.dc1.consul-key.pem"

    relabel_configs:
      - source_labels: ['__meta_consul_tags']
        regex: '(.*)http(.*)'
        action: keep
      - source_labels: ['__scheme__']
        target_label: __scheme__
        replacement: https

    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']

  - job_name: 'pve'
    static_configs:
      - targets:
          - 192.168.86.200
    metrics_path: /pve
    params:
      module: [default]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
{{ range service "pve_exporter" }}
        replacement: {{ .Address }}:{{ .Port }}
{{ end }}
EOF
        destination = "${NOMAD_TASK_DIR}/prometheus.yml"
        change_mode = "noop"
      }

      template {
        data        = <<EOF
{{ with secret "pki_int/issue/cluster" "common_name=prom-client.dc1.consul" }}
{{ .Data.certificate }}
{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/tls/prom-client.dc1.consul-cert.crt"
        perms       = "0600"
        change_mode = "restart"
      }

      template {
        data        = <<EOF
{{ with secret "pki_int/issue/cluster" "common_name=prom-client.dc1.consul" }}
{{ .Data.private_key }}
{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/tls/prom-client.dc1.consul-key.pem"
        perms       = "0400"
        change_mode = "restart"
      }
      template {
        data        = <<EOF
{{ with secret "pki_int/issue/cluster" "common_name=prom-client.dc1.consul" }}
{{ .Data.issuing_ca }}
{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/tls/prom-client.dc1.consul-ca.crt"
        perms       = "0640"
        change_mode = "restart"
      }

      resources {
        cpu    = 80
        memory = 256
      }
    }
  }
}
