All Terraform state is stored in a self-hosted Minio S3 bucket, configured in
`terraform/minio`.

## Configuration

Configure the backend to use the Minio instance.

```hcl
terraform {
  backend "s3" {
    region = "main"
    bucket = "terraform-state"
    key    = "path/to/terraform.tfstate"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

Initialize the backend with:

```bash
$ terraform init \
    -backend-config="access_key=${TFSTATE_ACCESS_KEY}" \
    -backend-config="secret_key=${TFSTATE_SECRET_KEY}" \
    -backend-config="endpoint=${TFSTATE_ENDPOINT}"
```

## Notes

- When the Minio credentials are passed with the `-backend-config` flag, they
  will still appear in plain text in the `.terraform` subdirectory and any plan
  files.
