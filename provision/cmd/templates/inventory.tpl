cmd:
  hosts:
    ${cmd_ip}:
  vars:
    ansible_user: ${cmd_user}
    ansible_ssh_private_key_file: ~/.ssh/pve
    ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
    github_access_token: ${github_access_token}

drone:
  hosts:
    ${cmd_drone_ip}:
  vars:
    ansible_user: ${cmd_user}
    ansible_ssh_private_key_file: ~/.ssh/pve
    ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
    github_access_token: ${github_access_token}
