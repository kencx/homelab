## Work Log

### 26/03/23
- Updated Consul config to v1.15
- Updated Nomad keygen generation command
- Creating orphan, renewable Nomad-Vault integration token requires sudo
  privileges in policy path `auth/token/create/nomad_cluster` for `ansible` and
  `consul_template` policies. `auth/token/create-orphan` could not be used as
  the resulting orphan token will inherit the policies of the currently used
  "parent" token.

### 25/03/23
- Add support for different Terraform workspaces when initializing Vault.
- Add support for writing to different cert auth role paths when running
  multiple Vault-agent services.

### 14/02/23
- Discovered that Consul mTLS certificates require both Extended Key Usage of
  Server and Client Authentication. This means the `pki_int/issue/server` role
  needs both server and client flags turned on. This is probably true for Nomad
  as well.

- All Ansible roles ran successfully for a dev cluster, albeit with an issue
  about Vault-agent. On clusters with more than one Vault-agent service running
  (eg. 1 server and 1 client node), Ansible needs to write to different cert auth
  role paths to differentiate them. This can be easily done by identifying them
  via their hostname, but Ansible's and consul_template's policy must also
  support writing to these paths. Vault policies do not support regex but
  templating can be used, which I have to look into.

### 13/02/23
- I decided to scrape the previous plan of using AppRole authentication for
  Ansible because it had too many moving parts. Its much simpler to use TLS cert
  authentication.

- In the various roles, I have to issue certificates and write the key pair to
  multiple pairs. This gets tedious fast. I might write a module for DRY. Not a
  role because I'm not sure about nesting custom roles written in the same git
  repo yet (do they need to be defined in requirements.yml?).

### 12/02/23
- It seems too challenging to use molecule to test the provisioning of Vault
  agents due to its dependency on Vault server instances. I don't see how
  molecule can bring up a separate host. Perhaps it is sufficient to test Vault
  agent provisioning on the same server host.

- Ansible needs to authenticate to Vault multiple times and AppRole seems to be
  the best way to do this. The proposed method of authentication will go like
  this:
    1. Vault must have an AppRole `ansible` with policy `ansible`. This policy
       will contain all actions Ansible needs to perform (eg. issue certs, write
       certs to auth roles)
    2. Vault will also have a separate secretID token for Ansible to login
       against to generate a secretID dynamically. Its policy will only contain
       this action.
    3. Terraform will require its separate roleID token to obtain the roleID. It
       will need to target the resource and Ansible will read its output. Its
       policy will only allow reading of the roleID.
    4. Ansible will obtain the secretID via a separate ansible_secretid_token
       stored in Ansible Vault.
    5. Ansible can now login to Vault with roleID and secretID.

- The unstable nature of Vault's Terraform provider could be due to an existing
  state file that is present during testing. This poses a problem for actual
  runs vs Molecule tests as they are using the same state file. We would have to
  separate these states or use different workspaces. For now, I've added a
  `terraform destroy` step beforehand to reset any changes.

### 11/02/23
- Cleaned up `vault` role for server instances
  - Vault server tasks are moved to `tasks/server.yml`
  - Vault initialization is constrained to only be performed on the first run of
    the role. This will be the only time the root token is read by Ansible.
  - Initialization consists of initializing Vault, storing the root token and
    unseal key, logging in as root and provisioning Vault secrets with Terraform
    provider.
  - This constraint means that the role's purposes is only to configure and
    initialize Vault. The management of Vault's secrets is beyond the scope of
    this role. This prevents further runs of the role from making changes to the
    its secrets with the root token.
  - To allow for Molecule testing, the server platform must be added to the
    `mol_server` group. This hopefully allows us to test client platforms and Vault
    server/client provisioning in the future.

- Provisioning of Vault-agent has also been added to `vault` role
  - Vault-agent will be provisioned on server nodes if `vault_setup_agent ==
    true` and all client nodes.
  - It requires an existing Vault server instance to be present. The Vault
    server IP must be provided and it will check that it is running and
    unsealed before proceeding to provision Vault-agent.
  - It must fetch Vault's CA cert from the server.
  - Vault-Agent will use cert auth to authenticate to Vault. This requires
    Ansible to issue new auth certs and write the certs to the `auth` role.
    Ansible will authenticate to Vault with AppRole authentication.

- The userpass admin resource is not added on the first run of terraform apply.
  It must be run twice for the resource to be added. Unsure why.

### 03/02/23 17:46
- Created insecure root and intermediate CA for testing Vault role. These certs
  and private keys will be checked into git and should never be used for
  anything other than testing.
- I included a `generate_ca.yml` playbook to quickly generate a new testca if
  needed.
- `prepare.yml` in molecule/vault uses the ca-chain from testca to produce a
  TLS key pair to be used by Vault.

### 02/02/23 11:47
- Cleaned up `common` role
  - Replace soon to be deprecated `apt_key` with `get_url`
  - Move repository key to default keyring `/etc/apt/keyrings`
  - Install `consul-template` directly with `apt` instead of `unarchive`-ing the
    binary.
  - Generalized some OS variables with Ansible facts
  - Molecule testing of `common` role with `debian/bullseye64` box. Creating our own boxes
    will come later.

### 30/11/22 21:40
- Added Molecule unit tests for `common` and `vault` roles.
  - They use the `molecule-vagrant` driver because I can't be arsed to bother with figuring out systemd on molecule-docker.
- Added support for running the Terraform Vault provider in the `vault` role.
  - It works well, until I get to the issuing of certificates. There appears to be some
    sort of race condition that removes the `pki_int` cert. Destroying and re-applying
    the plan works, but that's not ideal is it.
- Also added support to store the unseal key and root token in the filesystem for `vault` role.
  - This is mainly for dev and testing purposes. Had to add this because I just know
    I'll overwrite my current instance's unseal key in Bitwarden.

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
