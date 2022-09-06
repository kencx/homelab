.PHONY: check cmd $(env) smoke inv-list inv-graph config

default: config

cmd:
	ansible-playbook cmd.yml -K

env = dev prod
$(env):
	ansible-playbook env.yml -K -e env=$(@)

smoke:
	ansible-playbook tests/smoke_test.yml -K

inv-list: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --list

inv-graph: inventory/hosts.yml
	ansible-inventory -i inventory/hosts.yml --graph --vars

config: ansible.cfg
	ansible-config view
