terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.6.0"
    }
  }
  backend "s3" {
    region = "main"
    bucket = "terraform-state"
    key    = "cloudflare/terraform.tfstate"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_account" "main" {
  name              = "kenc"
  type              = "standard"
  enforce_twofactor = true
}

resource "cloudflare_zone" "kencv-xyz" {
  account_id = cloudflare_account.main.id
  zone       = "kencv.xyz"
}
