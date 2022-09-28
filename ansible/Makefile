.PHONY: server client common

cmd = common server client
$(cmd):
	ansible-playbook -i inventory/hosts.yml $@.yml
