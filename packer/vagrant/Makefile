.PHONY: build add up up.d
build:
	packer build -var-file="auto.pkrvars.hcl" .

add:
	vagrant box add builds/base.libvirt.box --provider libvirt --name kenc/debian-11.5

up:
	cd tests && vagrant up --provider=libvirt

up.d:
	cd tests && vagrant up --provider=libvirt --debug
