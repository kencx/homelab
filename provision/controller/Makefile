PLAYBOOK_DIR := playbooks

.PHONY: plan apply destroy bootstrap $(mol)

default: plan

# terraform
.terraform.lock.hcl: main.tf terraform.tfvars
	terraform init

plan: .terraform.lock.hcl
	terraform plan

apply: .terraform.lock.hcl
	terraform apply -auto-approve

destroy: .terraform.lock.hcl
	terraform destroy

# ansible
bootstrap:
	cd $(PLAYBOOK_DIR); ANSIBLE_FORCE_COLOR=1 ansible-playbook controller.yml -K

mol = create converge verify test
$(mol):
	cd $(PLAYBOOK_DIR); ANSIBLE_FORCE_COLOR=1 molecule $@
