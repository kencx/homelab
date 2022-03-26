# Provisioning from Skeleton

Ensure `terraform.tfvars` is populated. The following variables should differ
between environments:

```
environment = "dev"
core_id = 110
apps_id = 111
ip_block = "10.10.10."
```

Init, plan and apply.

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Test if hosts are reachable

```bash
$ ping 10.10.10.110
$ ping 10.10.10.111
```
