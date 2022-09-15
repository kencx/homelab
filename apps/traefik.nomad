variable "domain_name" {
  type = string
}

variable "do_token" {
  type = string
}


job "traefik" {
  datacenters = ["dc1"]
  type = "service"

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
		static = "8080"
	  }
    }

	service {
	  provider = "consul"
	  name = "${NOMAD_JOB_NAME}"
	  port = "https"

	  tags = [
		"traefik.enable=true",

		# http to https redirect
		"traefik.http.routers.http-catch.entrypoints=http",
		"traefik.http.routers.http-catch.rule=HostRegexp(`{host:.+}`)",
		"traefik.http.routers.http-catch.middlewares=redirect-to-https",
		"traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https",

		# https router
		"traefik.http.routers.traefik-router.entrypoints=https",
		"traefik.http.routers.traefik-router.rule=Host(`traefik.${var.domain_name}`)",
		"traefik.http.routers.traefik-router.service=api@internal"

		"traefik.http.routers.traefik-router.tls=true",
		# Comment out the below line after first run of traefik to force the use of wildcard certs
		# "traefik.http.routers.traefik-router.tls.certResolver=dns-dgo"
		"traefik.http.routers.traefik-router.tls.domains[0].main=${var.domain_name}"
		"traefik.http.routers.traefik-router.tls.domains[0].sans=*.${var.domain_name}"
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

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.6.1"
        ports = ["http", "https", "dashboard"]
		network_mode = "host"

		volumes = [
		  "local/traefik.yml:/traefik.yml",
		  "${pathexpand("~/acme")}:/acme",
		]
      }

	  env {
		DO_AUTH_TOKEN = "${do_token}"
	  }

	  template {
	    data = <<EOF
global:
  checkNewVersion: true
  sendAnonymousUsage: false

api:
  insecure: false
  dashboard: true

ping: {}

log:
  level: "DEBUG"

# accessLog:
#   filePath: "/traefik.log"
#   filters:
#     statusCodes: "400-499"

entrypoints:
  http:
    address: ":{{ env "NOMAD_PORT_http" }}"
  https:
    address: ":{{ env "NOMAD_PORT_https" }}"

providers:
  consulCatalog:
    endpoint:
      scheme: "http"
      address: "http://localhost:8500"
    exposedByDefault: false

certificatesResolvers:
  dns-dgo:
    acme:
	  # TODO populate with levant
      email: ""
      storage: "acme.json"
      caServer: ""
      dnsChallenge:
        provider: digitalocean
        resolvers: "1.1.1.1:53,1.0.0.1:53"
EOF
		destination = "local/traefik.yml"
	  }

      resources {
        cpu    = 35
        memory = 128
      }
    }
  }
}
