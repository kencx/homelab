job "traefik" {
  datacenters = ${datacenters}
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = "80"
      }
      port "https" {
        static = "443"
      }
      port "dashboard" {
        static = ${traefik_dashboard_port}
      }
    }

    service {
      provider = "consul"
      name     = NOMAD_JOB_NAME
      port     = "https"

      tags = [
        "traefik.enable=true",

        # http to https redirect
        "traefik.http.routers.http-catch.entrypoints=http",
        "traefik.http.routers.http-catch.rule=HostRegexp(`{host:.+}`)",
        "traefik.http.routers.http-catch.middlewares=redirect-to-https",
        "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https",

        # https router
        "traefik.http.routers.traefik-router.entrypoints=https",
        "traefik.http.routers.traefik-router.rule=Host(`${traefik_subdomain}.${domain}`)",
        "traefik.http.routers.traefik-router.service=api@internal",

        "traefik.http.routers.traefik-router.tls=true",
        # Comment out the below line after first run of traefik to force the use of wildcard certs
        # "traefik.http.routers.traefik-router.tls.certResolver=dns-dgo",
        "traefik.http.routers.traefik-router.tls.domains[0].main=${domain}",
        "traefik.http.routers.traefik-router.tls.domains[0].sans=*.${domain}"
      ]

      check {
        type     = "tcp"
        port     = "http"
        interval = "30s"
        timeout  = "5s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }

      check {
        type     = "tcp"
        port     = "https"
        interval = "30s"
        timeout  = "5s"

        success_before_passing   = "3"
        failures_before_critical = "3"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:${traefik_image_version}"
        ports        = ["http", "https", "dashboard"]
        network_mode = "host"

        volumes = [
          "local/traefik.yml:/traefik.yml",
          "local/rules:/rules",
          "secrets/tls:/tls",
          "${traefik_volumes_acme}:/acme",
          "${traefik_volumes_logs}:/logs/traefik.log"
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      vault {
        policies = ["nomad_traefik"]
      }

      template {
        data        = <<EOF
{{ with secret "kvv2/data/prod/nomad/traefik" }}
CF_API_KEY="{{ .Data.data.cloudflare_api_key }}"
CF_API_EMAIL="{{ .Data.data.ca_email }}"
TRAEFIK_CERTIFICATESRESOLVERS_DNS_DGO_ACME_EMAIL="{{ .Data.data.ca_email }}"
{{ end }}
EOF
        destination = "secrets/secrets.env"
        env         = true
      }

      template {
        data        = <<EOF
global:
  checkNewVersion: true
  sendAnonymousUsage: false

api:
  insecure: false
  dashboard: true

ping: {}

log:
  level: "INFO"

accessLog:
  filePath: "/logs/access.log"
  filters:
    statusCodes: "400-499"

entrypoints:
  http:
    address: ":{{ env "NOMAD_PORT_http" }}"
  https:
    address: ":{{ env "NOMAD_PORT_https" }}"

providers:
  consulCatalog:
    endpoint:
      scheme: "https"
      address: "${traefik_consul_provider_address}"
      tls:
        # create cert for traefik to consul TLS
        # must be renewed
        ca: "tls/traefik-client.dc1.consul-ca.crt"
        cert: "tls/traefik-client.dc1.consul-cert.crt"
        key: "tls/traefik-client.dc1.consul-key.pem"
    exposedByDefault: false

  file:
    directory: "/rules"

certificatesResolvers:
  dns-dgo:
    acme:
      storage: "acme/acme.json"
      caServer: "${traefik_acme_ca_server}"
      dnsChallenge:
        provider: cloudflare
        delayBeforeCheck: 90
        resolvers:
          - "1.1.1.1"
          - "8.8.8.8"
EOF
        destination = "$${NOMAD_TASK_DIR}/traefik.yml"
      }

      template {
        data        = <<EOF
http:
  routers:
    proxmox-https:
      entryPoints:
        - https
      rule: "Host(`${proxmox_domain}.${domain}`)"
      tls: {}
      middlewares:
        - default-headers
      service: proxmox

    nomad:
      entryPoints:
        - https
      rule: "Host(`nomad.${domain}`)"
      tls: {}
      middlewares:
        - default-headers
      service: nomad

    consul:
      entryPoints:
        - https
      rule: "Host(`consul.${domain}`)"
      tls: {}
      middlewares:
        - default-headers
      service: consul

  services:
    proxmox:
      loadBalancer:
        servers:
          - url: "${proxmox_address}"
        serversTransport: insecureTransport
    nomad:
      loadBalancer:
        servers:
          - url: "https://nomad.service.consul:4646"
        serversTransport: insecureTransport
    consul:
      loadBalancer:
        servers:
          - url: "https://consul.service.consul:8501"
        serversTransport: insecureTransport

  serversTransports:
    insecureTransport:
      insecureSkipVerify: true

  middlewares:
    default-headers:
      headers:
        frameDeny: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
EOF
        destination = "$${NOMAD_TASK_DIR}/rules/rules.yml"
      }

      template {
        data        = <<EOF
{{ with secret "pki_int/issue/client" "common_name=traefik-client.dc1.consul" "alt_names=consul.service.consul" }}
{{ .Data.certificate }}
{{ end }}
EOF
        destination = "$${NOMAD_SECRETS_DIR}/tls/traefik-client.dc1.consul-cert.crt"
        perms       = "0600"
        change_mode = "restart"
      }

      template {
        data        = <<EOF
{{ with secret "pki_int/issue/client" "common_name=traefik-client.dc1.consul" "alt_names=consul.service.consul" }}
{{ .Data.private_key }}
{{ end }}
EOF
        destination = "$${NOMAD_SECRETS_DIR}/tls/traefik-client.dc1.consul-key.pem"
        perms       = "0400"
        change_mode = "restart"
      }
      template {
        data        = <<EOF
{{ with secret "pki_int/issue/client" "common_name=traefik-client.dc1.consul" "alt_names=consul.service.consul" }}
{{ .Data.issuing_ca }}
{{ end }}
EOF
        destination = "$${NOMAD_SECRETS_DIR}/tls/traefik-client.dc1.consul-ca.crt"
        perms       = "0640"
        change_mode = "restart"
      }

      resources {
        cpu    = 60
        memory = 128
      }
    }
  }
}
