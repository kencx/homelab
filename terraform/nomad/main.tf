terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.0.0-beta.1"
    }
  }
}

provider "nomad" {
  address = var.nomad_address
}

locals {
  apps = "${path.module}/apps"
}

resource "nomad_job" "whoami" {
  jobspec = file("${local.apps}/whoami.nomad.hcl")
}

resource "nomad_job" "countdash" {
  jobspec = file("${local.apps}/countdash.nomad.hcl")
}
