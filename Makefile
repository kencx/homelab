.PHONY: pre-commit install

pre-commit:
	pre-commit run --all-files

install: requirements.yml
	ansible-galaxy install -f -r requirements.yml

# ansible inventory management
# .PHONY: inv-list inv-graph

# inv-list: inventory/hosts.yml
# 	ansible-inventory -i inventory/hosts.yml --list
#
# inv-graph: inventory/hosts.yml
# 	ansible-inventory -i inventory/hosts.yml --graph --vars

# images
.PHONY: lxc-image

lxc-image-check:
	make -C images/lxc check

lxc-image:
	make -C images/lxc

# infra
.PHONY: plan apply new-env
e := dev

plan:
	make -C terraform/$(e)

apply:
	make -C terraform/$(e) apply

destroy:
	make -C terraform/$(e) destroy

# new-env:
# 	mkdir -p "$(p)"
# 	cp -r terraform/base/* "$(p)"
# 	cd "$(p)" && cp terraform.tfvars.example terraform.tfvars

# bootstrap
.PHONY: bootstrap smoke
	PLAYBOOK_DIR := playbooks

bootstrap:
	cd $(PLAYBOOK_DIR); ansible-playbook main.yml -K

smoke:
	cd $(PLAYBOOK_DIR); ansible-playbook tests/smoke_test.yml -K
