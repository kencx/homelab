terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 1.15.0"
    }
  }
}

provider "minio" {
  minio_server   = var.minio_server
  minio_user     = var.minio_user
  minio_password = var.minio_password
  minio_ssl      = true
}

resource "minio_s3_bucket" "aur" {
  bucket = "aur"
  acl    = "public"
}

resource "minio_s3_bucket" "books" {
  bucket = "books"
  acl    = "public"
}
