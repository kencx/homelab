terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = ">= 0.8.0"
    }
  }
}

provider "b2" {
  application_key_id = var.application_key_id
  application_key    = var.application_key
}

resource "b2_application_key" "autorestic" {
  key_name  = "nas-autorestic"
  bucket_id = b2_bucket.restic.id
  capabilities = [
    "bypassGovernance",
    "deleteFiles",
    "listBuckets",
    "listFiles",
    "readBucketEncryption",
    "readBucketRetentions",
    "readBuckets",
    "readFileLegalHolds",
    "readFileRetentions",
    "readFiles",
    "shareFiles",
    "writeBucketEncryption",
    "writeBucketRetentions",
    "writeFileLegalHolds",
    "writeFileRetentions",
    "writeFiles",
  ]
}

resource "b2_bucket" "restic" {
  bucket_name = "nas-server-restic"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_hiding_to_deleting  = 180
    days_from_uploading_to_hiding = 0
  }

  file_lock_configuration {
    is_file_lock_enabled = true
  }
}
