.PHONY: install check image

default: check

install: ../../requirements.yml
	ansible-galaxy install -f -r ../../requirements.yml

check: ../../inventory/hosts.yml
	ANSIBLE_FORCE_COLOR=1 ansible-playbook main.yml \
		-i ../../inventory/hosts.yml \
		-K --check

image: ../../inventory/hosts.yml
	ANSIBLE_FORCE_COLOR=1 ansible-playbook main.yml \
		-i ../../inventory/hosts.yml \
		-K
