.PHONY: validate base server client

validate:
	cd $(d) && packer validate -var-file="auto.pkrvars.hcl" .

base:
	cd base && packer build -var-file="auto.pkrvars.hcl" .

server:
	cd server && packer build -var-file="auto.pkrvars.hcl" .

client:
	cd client && packer build -var-file="auto.pkrvars.hcl" .
