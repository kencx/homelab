terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.0.0-beta.1"
    }
  }
  backend "s3" {
    region = "main"
    bucket = "terraform-state"
    key    = "nomad/terraform.tfstate"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

provider "nomad" {
  address     = var.nomad_address
  skip_verify = true
}

locals {
  apps        = "${path.module}/apps"
  datacenters = jsonencode(var.datacenters)
  domain      = var.domain
}

resource "nomad_job" "whoami" {
  jobspec = templatefile("${local.apps}/whoami.tpl",
    {
      datacenters      = local.datacenters
      whoami_count     = 1
      whoami_subdomain = "whoami"
      domain           = local.domain
    }
  )
}

resource "nomad_job" "traefik" {
  jobspec = templatefile("${local.apps}/traefik.tpl",
    {
      datacenters            = local.datacenters
      traefik_dashboard_port = 8080
      traefik_subdomain      = "traefik"
      domain                 = local.domain

      traefik_image_version = var.traefik_image_version
      traefik_volumes_acme  = var.traefik_volumes_acme
      traefik_volumes_logs  = var.traefik_volumes_logs

      traefik_consul_provider_address = var.traefik_consul_provider_address
      traefik_acme_ca_server          = var.traefik_acme_ca_server

      proxmox_domain  = "pve"
      proxmox_address = var.proxmox_address
  })
}

resource "nomad_job" "yarr" {
  jobspec = templatefile("${local.apps}/yarr.tpl",
    {
      datacenters    = local.datacenters
      yarr_subdomain = "yarr"
      domain         = local.domain

      yarr_image_version = var.yarr_image_version
      yarr_volumes_data  = var.yarr_volumes_data
  })
}

resource "nomad_job" "minio" {
  jobspec = templatefile("${local.apps}/minio.tpl",
    {
      datacenters             = local.datacenters
      minio_subdomain         = "minio"
      minio_console_subdomain = "minio-console"
      domain                  = local.domain

      minio_image_version = var.minio_image_version
      minio_volumes_data  = var.minio_volumes_data
  })
}

resource "nomad_job" "actual" {
  jobspec = templatefile("${local.apps}/actual.tpl",
    {
      datacenters      = local.datacenters
      actual_subdomain = "actual"
      domain           = local.domain

      actual_image_version  = var.actual_image_version
      actual_volumes_server = var.actual_volumes_server
      actual_volumes_user   = var.actual_volumes_user
  })
}

resource "nomad_job" "linkding" {
  jobspec = templatefile("${local.apps}/linkding.tpl",
    {
      datacenters        = local.datacenters
      linkding_subdomain = "linkding"
      domain             = local.domain

      linkding_image_version = var.linkding_image_version
      linkding_volumes_data  = var.linkding_volumes_data
  })
}

# resource "nomad_job" "diun" {
#   jobspec = file("${local.apps}/diun.nomad.hcl")
# }

# resource "nomad_job" "diun" {
#   jobspec = templatefile("${local.apps}/diun.tpl",
#     {
#       datacenters    = local.datacenters
#       diun_subdomain = "diun"
#       domain         = local.domain
#       timezone       = var.timezone
#
#       diun_image_version  = var.diun_image_version
#       diun_volumes_data   = var.diun_volumes_data
#       diun_watch_schedule = "0 0 * * 5"
#   })
# }

resource "nomad_job" "openbooks" {
  jobspec = templatefile("${local.apps}/openbooks.tpl",
    {
      datacenters         = local.datacenters
      openbooks_subdomain = "openbooks"
      domain              = local.domain

      openbooks_image_version = var.openbooks_image_version
      openbooks_volumes_books = var.openbooks_volumes_books
  })
}

resource "nomad_job" "calibre_web" {
  jobspec = templatefile("${local.apps}/calibre_web.tpl",
    {
      datacenters           = local.datacenters
      calibre_web_subdomain = "books"
      domain                = local.domain

      calibre_web_image_version  = var.calibre_web_image_version
      calibre_web_volumes_config = var.calibre_web_volumes_config
      calibre_web_volumes_books  = var.calibre_web_volumes_books
  })
}

# resource "nomad_job" "ghostfolio" {
#   jobspec = templatefile("${local.apps}/ghostfolio.tpl",
#     {
#       datacenters          = local.datacenters
#       ghostfolio_subdomain = "ghostfolio"
#       domain               = local.domain
#
#       ghostfolio_image_version  = var.ghostfolio_image_version
#       ghostfolio_volumes_config = var.ghostfolio_volumes_config
#   })
# }
#
# resource "nomad_job" "paperless" {
#   jobspec = templatefile("${local.apps}/paperless.tpl",
#     {
#       datacenters         = local.datacenters
#       paperless_subdomain = "paper"
#       domain              = local.domain
#       timezone            = var.timezone
#
#       paperless_image_version   = var.paperless_image_version
#       paperless_volumes_data    = var.paperless_volumes_data
#       paperless_volumes_consume = var.paperless_volumes_consume
#       paperless_volumes_media   = var.paperless_volumes_media
#   })
# }

resource "nomad_job" "postgres" {
  jobspec = templatefile("${local.apps}/postgres.tpl",
    {
      datacenters = local.datacenters
      domain      = local.domain

      postgres_image_version = var.postgres_image_version
      postgres_volumes_data  = var.postgres_volumes_data
  })
}

resource "nomad_job" "registry" {
  jobspec = templatefile("${local.apps}/registry.tpl",
    {
      datacenters        = local.datacenters
      registry_subdomain = "registry"
      domain             = local.domain

      registry_image_version = var.registry_image_version
      registry_volumes_data  = var.registry_volumes_data
  })
}

resource "nomad_job" "pigallery2" {
  jobspec = templatefile("${local.apps}/pigallery2.tpl",
    {
      datacenters          = local.datacenters
      pigallery2_subdomain = "images"
      domain               = local.domain

      pigallery2_image_version  = var.pigallery2_image_version
      pigallery2_volumes_config = var.pigallery2_volumes_config
      pigallery2_volumes_data   = var.pigallery2_volumes_data
      pigallery2_volumes_images = var.pigallery2_volumes_images
      pigallery2_volumes_tmp    = var.pigallery2_volumes_tmp
  })
}
