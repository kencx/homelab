controller:
  hosts:
    ${controller_ip}:
  vars:
    ansible_user: ${controller_user}
    ansible_ssh_private_key_file: ~/.ssh/pve
    ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
    github_access_token: ${github_access_token}
