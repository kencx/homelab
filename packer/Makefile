.PHONY: validate base

validate:
	cd $(d) && packer validate -var-file="auto.pkrvars.hcl" .

base:
	cd base && packer build -var-file="auto.pkrvars.hcl" .
