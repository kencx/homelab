
.PHONY: galaxy-install

galaxy-install:
	ansible-galaxy install -f -r requirements.yml

.PHONY: lxc-image

lxc-image:
	make -C images/lxc
