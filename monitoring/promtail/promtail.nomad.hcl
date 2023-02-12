job "promtail" {
  datacenters = ["dc1"]

  group "promtail" {
    network {
      mode = "bridge"
    }

    #service {
    #  name = "promtail"
    #  port = "http"

    #  check {
    #    type = "http"
    #    path = "/health"
    #    interval = "10s"
    #    timeout = "5s"
    #  }
    #}

    task "promtail" {
      driver = "docker"
      config {
        image = "grafana/promtail:latest"

        args = [
          "-config.file=/etc/promtail/config.yml",
        ]

        volumes = [
          "local/config.yml:/etc/promtail/config.yml",
          "/var/log/journal/:/var/log/journal/:ro",
          "/run/log/journal/:/run/log/journal/:ro",
          "/etc/machine-id:/etc/machine-id:ro",
        ]
      }

      template {
        data = <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yml

clients:
  - url: http://10.10.10.135:3100/loki/api/v1/push

scrape_configs:
  - job_name: journal
    journal:
      max_age: 12h
      json: false
      path: /var/log/journal
      labels:
        job: systemd-journal
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: 'unit'
      - source_labels: ['__journal__hostname']
        target_label: 'nodename'
EOF
        destination = "local/config.yml"
      }

      resources {
        cpu = 50
        memory = 96
      }
    }
  }
}
