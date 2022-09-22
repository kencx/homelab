
cmd = ping base client
$(cmd):
	ansible-playbook -i inventory/hosts.yml playbooks/$@.yml

server:
	ansible-playbook -i inventory/hosts.yml -e host=server playbooks/server.yml

client.post:
	ansible-playbook -i inventory/hosts.yml playbooks/client-post.yml
