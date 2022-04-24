# Golden Images
A key goal for this homelab is immutable infrastructure - servers are never
modified directly once they are deployed. Instead, all configuration changes are
implemented on golden images that are subsequently provisioned on all systems.
This prevents configuration drift between systems and allows for versioned
changes that are easy to rollback.

On Proxmox, this involves the creation of VM and LXC golden images.

The image building process is quick, automated and well tested in a CI/CD
pipeline:
1. Add new configuration to playbook
2. Build the golden image and store it in an artifact repository
3. Perform automated tests for new changes
4. Backup all persistent data
5. Destroy existing servers and re-create with new images

## LXC

Ansible is used to build LXC templates.

A temporary LXC container is created and bootstrapped. After configuratiuon, it
is stopped and Proxmox create a template with `vzdump`, before deleting the
container.

### Usage
1. Run `make install` to install all Ansible roles and collections.
2. Add configuration to `images/lxc/vars.yml`
3. Ensure hosts file is defined. By default, we use the the global hosts file at
   `${BASE_DIR}/inventory/hosts.yml`.
4. Run `make lxc-image`. This will prompt for your Proxmox sudo password.

#### Notes
When destroying and recreating a new LXC with the same IP, ensure that the ARP
table is cleared. Otherwise, the recreated host will not be reachable.

### Variables
#### Authentication
| Variable                 | Type   | Description                |
| ------------------------ | ------ | -------------------------- |
| proxmox_api_host         | string | Target host of PVE cluster |
| proxmox_api_user         | string | User to authenticate with (eg. root@pam)  |
| proxmox_api_token_id     | string | API token ID               |
| proxmox_api_token_secret | string | API token secret           |

>`api_user` and `api_password` are supported in the [Proxmox
>module](https://docs.ansible.com/ansible/latest/collections/community/general/proxmox_module.html),
>but not implemented here.

#### Proxmox Parameters
| Variable           | Type   | Description                  |
| ------------------ | ------ | ---------------------------- |
| proxmox_node       | string | PVE node to operate on       |
| proxmox_storage    | string | Target storage               |

#### Temp Template Parameters
| Variable        | Type   | Description                                          |
| --------------- | ------ | ---------------------------------------------------- |
| base_image      | string | Existing base image to build on                      |
| temp_vmid       | int    | Instance ID of temp LXC                              |
| temp_hostname   | string | Hostname of temp LXC                                 |
| temp_disk_size  | string | Hard disk size of format `<Storage>:<Size>`          |
| temp_ip_address | string | IPv4 address for temp LXC of format `cidr/subnet_mask` |
| temp_gateway    | string | Gateway address for temp LXC                         |

#### Template Storage Parameters
| Variable          | Type   | Description                                |
| ----------------- | ------ | ------------------------------------------ |
| dump_dir          | string | Directory to store template                |
| template_name     | string | Name of built template. Suffixed with date |

#### Bootstrap Configuration
| Variable             | Type   | Description                                    |
| -------------------- | ------ | ---------------------------------------------- |
| template_user        | string | Username of new user                           |
| template_password    | string | Temporary password of new user                 |
| template_uid         | int    | UID of new user                                |
| apps                 | list   | Packages to install                            |
| force_reset_password | bool   | Prompt user to reset password on first login   |
| git_email            | string | Git email config                               |
| git_user             | string | Git username config                            |
| ssh_key_file         | string | Authorized SSH public key file for new account |

## VM
TODO
