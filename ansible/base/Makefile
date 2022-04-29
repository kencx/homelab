.PHONY: check $(env) smoke inv-list inv-graph config

default: check

check:
	ansible-playbook main.yml -K --check

env = dev prod
$(env):
	ansible-playbook main.yml -K -e env=$(@)

# smoke:
# 	ansible-playbook tests/smoke_test.yml -K

inv-list: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --list

inv-graph: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --graph --vars

config: ansible.cfg
	ansible-config view
