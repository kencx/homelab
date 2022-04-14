.PHONY: install check bootstrap

default: check

install: ../../requirements.yml
	ansible-galaxy install -f -r ../../requirements.yml

check: ../../inventory/hosts.yml
	ANSIBLE_FORCE_COLOR=1 ansible-playbook main.yml \
		-i ../../inventory/hosts.yml \
		-K --check

bootstrap: ../../inventory/hosts.yml
	ANSIBLE_FORCE_COLOR=1 ansible-playbook main.yml \
		-i ../../inventory/hosts.yml \
		-K
