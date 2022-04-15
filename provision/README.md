## Command Center

`provision/cmd` provisions the Command Center and helper hosts which have the
following functions:
- Deployment and provisioning of other hosts with CI/CD
- Base image templating pipeline
- Hosts global management applications including Portainer, Gitea etc.

`cmd/playbooks` contains the post-provisioning playbooks that will be run
to install Terraform, Ansible and Packer to perform these tasks.

### Prerequisites
`cmd` has been tested with the following pre-requsites only:
- Debian 11
- Python 3.9 and above
- Ansible 2.12
- Terraform 1.1.7

### Usage
To execute the Terraform plan and apply, run:

```bash
$ make plan
$ make apply
```

Terraform will execute the Ansible playbook automatically with `local-exec`. In
the event that `local-exec` fails, we can re-run playbook with:

```bash
$ make bootstrap
```

>Known issue: Because the current base image forces the user to change its
>password on first login (with SSH), Ansible fails to connect until the user
>manually changes the password.

### Development
To test the Ansible playbooks, ensure the relevant variables are present in
`cmd/playbooks/vars.yml`

```yaml
user: debian
github_access_token: "changeme"
```

then run

```bash
$ cd /provision/cmd/playbooks
$ molecule test
```

To run and debug playbooks individually, use the local
`inventory/hosts-test.yml` instead. Take care of the user passwords.

### TODO
- [ ] Start compose stacks
- [ ] Molecule `verify.yml`
- [ ] Automate changing of password on first login

## Base Template

`provision/base` contains a base template of the infrastructure for a single
environment. Copy `terraform.tfvars.example` and populate the variables. The following variables should differ between environments:

```
ssh_public_key = "changeme"
environment = "dev"
lxc_template_name = "template-name"
apps_id = 110
ip_block = "10.10.10."
```

Init, plan and apply.

```bash
$ terraform init
$ terraform plan -vars-file=[file]
$ terraform apply -vars-file=[file]
```
