# Terraform

Terraform is used to provision Proxmox guest VMs by cloning existing templates.

## State

Terraform state can be configured to be stored in a Minio S3 bucket.

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

>**Note**: When the Minio credentials are passed with the `-backend-config`
>flag, they will still appear in plain text in the `.terraform` subdirectory and
>any plan files.
