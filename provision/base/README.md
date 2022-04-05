# Provisioning from Skeleton

Ensure `terraform.tfvars` is populated. The following variables should differ
between environments:

```
ssh_public_key = "changeme"
environment = "dev"
lxc_template_name = "template-name"
core_id = 110
apps_id = 111
ip_block = "10.10.10."
```

Init, plan and apply.

```bash
$ terraform init
$ terraform plan -vars-file=[file]
$ terraform apply -vars-file=[file]
```

Test if hosts are reachable

```bash
$ ping 10.10.10.110
$ ping 10.10.10.111
```

SSH into hosts and start docker containers

```bash
$ ssh root@10.10.10.110
$ git clone [url]
```
