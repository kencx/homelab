.PHONY: check image

default: image

check: ../../inventory/hosts.yml
	ANSIBLE_FORCE_COLOR=1 ansible-playbook main.yml \
		-i ../../inventory/hosts.yml \
		-K --check

image: ../../inventory/hosts.yml
	ANSIBLE_FORCE_COLOR=1 ansible-playbook main.yml \
		-i ../../inventory/hosts.yml \
		-K
