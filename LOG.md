## Work Log

### 30/11/22 21:40
- Added Molecule unit tests for `common` and `vault` roles.
  - They use the `molecule-vagrant` driver because I can't be arsed to bother with figuring out systemd on molecule-docker.
- Added support for running the Terraform Vault provider in the `vault` role.
  - It works well, until I get to the issuing of certificates. There appears to be some
    sort of race condition that removes the `pki_int` cert. Destroying and re-applying
    the plan works, but that's not ideal is it.
- Also added support to store the unseal key and root token in the filesystem for `vault` role.
  - This is mainly for dev and testing purposes. Had to add this because I just know
    I'll overwrite my current instance's unseal key in Bitwarden and cry.

### 29/11/22
- Ran Packer `proxmox-iso` builder to create VM template.
  - `boot_command` is working well to configure a static IP, without DHCP.
  - Builder does not require `vga` block for serial console to work.
  - Debugging with `tty2` (`LAlt+F2`) and `more /var/log/syslog` to see installer logs.
  - Install is not able to download preseed.cfg file. Unsure which IP address and port to specify.
  - Install can download remote preseed.cfg file from Github repo with `wget` or `boot_command`.
  - Once downloaded, unattended install and post-provisioning proceeds without any issues.
- Tested new template with Terraform `dev` cluster.
  - Template does not support cloud-init well. Need to figure out why.
  - IP address is not changed when cloned which is unexpected, it adopts the template's IP.

### 28/11/22
- Managed to build a functional Vagrant base box with Packer, qemu/libvirt.
  - It remains insecure with password-less sudo, but is perfect for testing. I plan to
    use this for my Molecule testing.

### 24/11/22 20:51
- Completed server playbook run on dev server node
- consul_template is throwing errors in Ansible when creating Nomad's Vault token for
  Nomad-Vault integration:
  - `root or sudo privileges required to create periodic token`
- Running the Vault role outside of prod will overwrite the existing unseal key and root
  token in Bitwarden, which is extremely dangerous. We should support replacement of
  these variables in the Vault role.
- `nfs_share_mounts` in `group_vars/dev.yml` inherits from `server.yml` which is
  unwanted. I need to figure out how to properly nest the inventory according to
  environment and node type.
- `cluster_server_ip` in `group_vars/dev.yml` cannot be dynamically detected
- Goss smoke test says that the some packages are not installed, although they are.
- Running client playbook on dev client node
  - consul-template failed without indication in Ansible as consul-template tls auth
    cert is not created since its supposed to be shared with server. but that does not
    seem ideal.
  - `cluster_server_ip` must be populated correctly. Ansible does not indicate any
    problems even when wrong IP is given.
  - `nfs_share_mounts` inherited from `group_vars/cluster.yml` instead of using values
    in `group_vars/dev.yml`.
- I have to fix my `group_vars`.
