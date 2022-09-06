## Command

`terraform/cmd` provisions a command environment which have the following
functions:
- Deployment and provisioning of other hosts with CI/CD
- Base image templating pipeline
- Hosts global management applications including Portainer, Gitea etc.

`ansible/cmd` contains the post-provisioning playbooks that will be run
to install Terraform, Ansible and Packer to perform these tasks.

## Base Template

`terraform/base` contains a base template of the infrastructure for a single
environment. It has the following goals:
- Describes a single environment with general, default variables
- Every change is a new versioned release
