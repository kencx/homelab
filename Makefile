.PHONY: pre-commit install

pre-commit:
	pre-commit run --all-files

install: requirements.yml
	ansible-galaxy install -f -r requirements.yml

# images
.PHONY: lxc-image

lxc-image-check:
	make -C images/lxc check

lxc-image:
	make -C images/lxc

# infra
.PHONY: plan apply new-env
e := base

plan:
	make -C terraform/$(e)

apply:
	make -C terraform/$(e) apply

destroy:
	make -C terraform/$(e) destroy

new-env:
	cp -r terraform/base "terraform/$(p)"
	cd "terraform/$(p)" && cp terraform.tfvars.example terraform.tfvars
	vim "terraform/$(p)/terraform.tfvars"

# bootstrap
.PHONY: bootstrap smoke config

bootstrap:
	make -C ansible/$(e) bootstrap

smoke:
	make -C ansible/$(e) smoke

config:
	make -C ansible/$(e) config
