# images
.PHONY: lxc-image

lxc-image-check:
	make -C images check

lxc-image:
	make -C images image

# lxc-image-test:
# 	make -C images test

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
env := dev

check:
	make -C ansible check

bootstrap:
	make -C ansible $(env)

smoke:
	make -C ansible smoke

config:
	make -C ansible config
