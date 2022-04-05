## cmd
`provision/cmd` contains the infrastructure for the cmd host. The
cmd belongs on the same subnet and take cares of the provisioning and
post-provisioning of all other hosts with CI/CD. It also runs the automated
creation of base images mentioned previously.

`cmd/playbooks` contains the post-provisioning playbooks that will be run
to install Terraform, Ansible and Packer to perform these tasks. It also sets up
Gitea and Drone CI for CI/CD.

### Usage
`cmd` has been tested on Debian 11 only.

Pre-requisites:
- Debian 11
- Python 3.9 and above
- Ansible 2.12
- Terraform 1.1.7

```bash
$ make plan
$ make apply
```

To re-run the provisioning playbook, run:

```bash
$ make bootstrap
```

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

To run playbooks individually, use the local `inventory/hosts-test.yml` instead.
Additionally, take care of user passwords. The base image forces the user to
reset their password on first login.

### TODO
- [ ] Force overwrite Github SSH key
- [ ] Sparse checkout homelab-iac
- [ ] Template for gitea + drone CI
- [ ] Molecule `verify.yml`

## Base

`provision/base` defines a skeleton of the infrastructure for a single
environment. To deploy an environment, we enter the necessary variables in
`[env].tfvars` and apply the infrastructure.

The following variables should differ between environments:

```
environment = "dev"
core_id = 110
apps_id = 111
ip_block = "10.10.10."
```

>DO NOT implement repository branches to manage each environment. Use a single
>source branch with separate folders or repositories for each environment
>instead.
