.PHONY: pre-commit galaxy-install

pre-commit:
	pre-commit run --all-files

galaxy-install:
	ansible-galaxy install -f -r requirements.yml

.PHONY: lxc-image

lxc-image:
	make -C images/lxc
