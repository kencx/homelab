.PHONY: pre-commit install

pre-commit:
	pre-commit run --all-files

galaxy.install: requirements.yml
	ansible-galaxy install -f -r requirements.yml

# packer
.PHONY: validate base

packer.validate:
	cd packer/base && packer validate -var-file="auto.pkrvars.hcl" .

packer.base:
	cd packer/base && packer build -var-file="auto.pkrvars.hcl" .

restic.check:
	sudo autorestic exec check -av

restic.unlock:
	sudo autorestic exec unlock -av

restic.snapshot:
	sudo autorestic exec snapshots -av
