job "whoami" {
  datacenters = ["dc1"]

  group "whoami" {
    count = 1

    network {
      port "http" {
        static = "5678"
      }
    }

	service {
	  provider = "consul"
	  name = "${NOMAD_JOB_NAME}"
	  port = "http"

	  check {
	    type     = "http"
	    path     = "/health"
	    port     = "http"
	    interval = "10s"
	    timeout  = "5s"

	    success_before_passing   = "3"
	    failures_before_critical = "3"
	  }
	}

    task "whoami" {
      driver = "docker"

      config {
        image = "traefik/whoami"
        ports = ["http"]
        args  = ["--port", "${NOMAD_PORT_http}"]
      }

      resources {
        cpu    = 35
        memory = 128
      }
    }
  }
}
