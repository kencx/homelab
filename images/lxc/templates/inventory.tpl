pve:
  hosts:
    ${proxmox_ip}
  vars:
    ansible_user: ansible
    ansible_ssh_private_key_file: ~/.ssh/id_ed25519
    proxmox_api_token_id: ${proxmox_api_token_id_ansible}
    proxmox_api_token_secret: ${proxmox_api_token_secret_ansible}
lxc:
  hosts:
    ${base_lxc_ip}
  vars:
    ansible_user: root
    ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
