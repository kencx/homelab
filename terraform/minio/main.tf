terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 1.15.0"
    }
  }
  backend "s3" {
    region = "main"
    bucket = "terraform-state"
    key    = "minio/terraform.tfstate"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    force_path_style            = true
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

resource "minio_s3_bucket" "tf-state" {
  bucket = "terraform-state"
  acl    = "public"
}

resource "minio_s3_bucket_versioning" "tf-state-version" {
  bucket = minio_s3_bucket.tf-state.id
  versioning_configuration {
    status = "Enabled"
  }
}
