.PHONY: pre-commit galaxy-install

pre-commit:
	pre-commit run --all-files

galaxy-install: requirements.yml
	ansible-galaxy install -f -r requirements.yml

.PHONY: create-lxc-image provision-cmd new-env

create-lxc-image:
	make -C images/lxc

provision-cmd:
	make -C provision/cmd

new-env:
	mkdir -p "$(p)"
	cp -r provision/base/* "$(p)"
	cd "$(p)" && cp terraform.tfvars.example terraform.tfvars

# inventory management
.PHONY: inv-list inv-graph

inv-list: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --list

inv-graph: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --graph --vars
