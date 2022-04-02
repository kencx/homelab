.PHONY: plan apply destroy

default: plan

.terraform.lock.hcl: main.tf terraform.tfvars
	terraform init

plan: .terraform.lock.hcl
	terraform plan

apply: .terraform.lock.hcl
	terraform apply -auto-approve

destroy: .terraform.lock.hcl
	terraform destroy
