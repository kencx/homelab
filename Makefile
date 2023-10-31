.PHONY: venv pre-commit docs

venv:
	@python3 -m venv .venv

pip.install: requirements.txt venv
	source .venv/bin/activate && pip install -r $< --disable-pip-version-check -q

pre-commit.install: pip.install
	source .venv/bin/activate && pre-commit install

pre-commit:
	pre-commit run --all-files

galaxy.install: requirements.yml
	ansible-galaxy install -f -r $<

# packer
packer.validate:
	cd packer/base-clone && packer validate -var-file="auto.pkrvars.hcl" .

packer.base:
	cd packer/base-clone && packer build -var-file="auto.pkrvars.hcl" .

# molecule
mol = create converge verify destroy test login prepare
mol.$(mol):
	cd ansible && molecule $@ -s $(scen)

mol.list:
	cd ansible && molecule list

docs:
	mdbook serve docs

vars.generate: bin/generate-vars
	source .venv/bin/activate && bin/generate-vars
