.PHONY: venv pre-commit docs

venv: .venv
	@python3 -m venv .venv

pre-commit.install: requirements.txt venv
	source .venv/bin/activate && pip install -r $< && pre-commit install

pre-commit:
	pre-commit run --all-files

galaxy.install: requirements.yml
	ansible-galaxy install -f -r $<

# packer
packer.validate:
	cd packer/base && packer validate -var-file="auto.pkrvars.hcl" .

packer.base:
	cd packer/base && packer build -var-file="auto.pkrvars.hcl" .

# ansible
ansible.play: ansible/inventory/hosts.yml
	cd ansible && ansible-playbook -i inventory/hosts.yml $(c).yml --user=debian

ansible.dev.play: ansible/inventory/hosts.yml
	cd ansible && ansible-playbook -i inventory/hosts.yml $(c).yml --user=debian --limit=dev

# molecule
mol = create converge verify destroy test login prepare
mol.$(mol):
	cd ansible && molecule $@ -s $(scen)

mol.list:
	cd ansible && molecule list

docs.install: docs/requirements.txt venv
	source .venv/bin/activate && pip install -r $<

docs:
	source .venv/bin/activate && mkdocs serve
