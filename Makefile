.PHONY: pre-commit docs

pre-commit:
	pre-commit run --all-files

galaxy.install: requirements.yml
	ansible-galaxy install -f -r requirements.yml

# packer
packer.validate:
	cd packer/base && packer validate -var-file="auto.pkrvars.hcl" .

packer.base:
	cd packer/base && packer build -var-file="auto.pkrvars.hcl" .

# ansible
ansible.play:
	cd ansible && ansible-playbook -i inventory/hosts.yml $(c).yml --user=debian

ansible.dev.play:
	cd ansible && ansible-playbook -i inventory/hosts.yml $(c).yml --user=debian --limit=dev

# molecule
mol = create converge verify destroy test login prepare
mol.$(mol):
	cd ansible && molecule $@ -s $(scen)

mol.list:
	cd ansible && molecule list

docs.install: docs/requirements.txt
	source .venv/bin/activate && pip install -r docs/requirements.txt

docs:
	source .venv/bin/activate && mkdocs serve
