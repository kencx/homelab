.PHONY: bootstrap smoke inv-list inv-graph config

bootstrap:
	ansible-playbook main.yml -K

# smoke:
# 	ansible-playbook tests/smoke_test.yml -K

inv-list: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --list

inv-graph: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --graph --vars

config: ansible.cfg
	ansible-config view
