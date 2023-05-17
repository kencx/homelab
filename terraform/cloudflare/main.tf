terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.6.0"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
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

resource "cloudflare_zone" "cheo-dev" {
  account_id = cloudflare_account.main.id
  zone       = "cheo.dev"
}

resource "cloudflare_record" "ken-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "ken"
  value   = var.blog_url
  type    = "CNAME"
  proxied = true
}


resource "cloudflare_zone" "sxkcd-lol" {
  account_id = cloudflare_account.main.id
  zone       = "sxkcd.lol"
}

resource "cloudflare_record" "main-sxkcd" {
  zone_id = cloudflare_zone.sxkcd-lol.id
  name    = "sxkcd.lol"
  value   = var.vps_ip_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "www-sxkcd" {
  zone_id = cloudflare_zone.sxkcd-lol.id
  name    = "www"
  type    = "CNAME"
  proxied = true
}
