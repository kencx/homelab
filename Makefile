.PHONY: pre-commit galaxy-install

pre-commit:
	pre-commit run --all-files

galaxy-install: requirements.yml
	ansible-galaxy install -f -r requirements.yml

.PHONY: lxc-image

lxc-image:
	make -C images/lxc

# inventory management
.PHONY: inv-list inv-graph

inv-list: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --list

inv-graph: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --graph --vars

# base
.PHONY: new-env
new-env:
	mkdir -p "$(p)"
	cp -r provision/base "$(p)"
