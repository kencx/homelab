job "grafana" {
  datacenters = ["dc1"]

  group "grafana" {
    count = 1

    network {
      port "http" {
        to = "3000"
      }
    }

    service {
      name = "grafana"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.grafana-proxy.entrypoints=https",
        "traefik.http.routers.grafana-proxy.tls=true",
        "traefik.http.routers.grafana-proxy.rule=Host(`[[ .app.grafana.domain ]].[[ .common.domain ]]`)",
      ]

      check {
        type     = "http"
        path     = "/api/health"
        interval = "10s"
        timeout  = "5s"
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:9.2.5"
        ports = ["http"]
        volumes = [
          "[[ .app.grafana.volumes.data ]]:/var/lib/grafana",
          "[[ .app.grafana.volumes.dashboards ]]:/dashboards",
          "local/provisioning:/etc/grafana/provisioning",
        ]
      }

      template {
        data        = <<EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
{{ range service "prometheus" }}
    url: http://{{ .Address }}:{{ .Port }}
{{ end }}
    jsonData:
      timeInterval: 10s
    version: 1
    editable: true
EOF
        destination = "${NOMAD_TASK_DIR}/provisioning/datasources/datasource.yml"
      }

      template {
        data        = <<EOF
apiVersion: 1
providers:
  - name: Dashboard
    folder: 'Services'
    type: file
    updateIntervalSeconds: 30
    allowUiUpdates: true
    disableDeletion: true
    options:
      path: /dashboards
      foldersFromFileStructure: true
EOF
        destination = "${NOMAD_TASK_DIR}/provisioning/dashboards/dashboard.yml"
      }

      resources {
        cpu    = 80
        memory = 256
      }
    }
  }
}
