# Secret Management with SOPS
[SOPS](https://github.com/mozilla/sops) and [age](https://github.com/FiloSottile/age) are used to manage secret encryption.

## Usage
1. Create a new age key-pair

```bash
$ age-keygen > ~/.config/sops/age/keys.txt
$ chmod 600 keys.txt
```

If the key is in another location, you must specify it manually with

```bash
$ export SOPS_AGE_KEY_FILE=/path/to/key
```

2. Get the public key

```bash
$ grep 'public key:' [path/to/key] | cut -d':' -f2
```

3. Create a new `.sops.yaml` at the base directory with the `age` public key

```yaml
creation_rules:
	- path_regex: ./.*\.env$   # or your own regex
	  encrypted_regex: '.*password.*'
	  age: [public key]
```

- `path_regex` specifies the file to encrypt
- `encrypted_regex` specifies the line in the file to encrypt

4. Encrypt your files.

```bash
$ sops file.txt                     # create a new encrypted file
$ sops -e file.env > file.sops.env  # encrypt an existing file
$ sops -e -i file.env               # inplace
```

5. Decrypt your files.

```bash
$ sops -d file.sops.env > file.env
$ sops -d -i file.env              # inplace
```

## Ansible Support

SOPS is [directly
supported](https://docs.ansible.com/ansible/latest/collections/community/sops/docsite/guide.html)
by Ansible with the `community.sops` collection. It can be used with
- encrypted files
- encrypted data from external sources
- encrypted variables

#### Prerequisites
- A `.sops.yaml` file must already be present.
- Install the `community.sops` collection. Better yet, add it to
  `requirements.yml`
- Enable the plugin in `ansible.cfg`

```
[defaults]
vars_plugins_enabled = host_group_vars,community.sops.sops

[community.sops]
config_path = /path/to/.sops.yml
```

#### Direct Lookup

To decrypt sops-encrypted files, use the `community.sops.sops`
[lookup](https://docs.ansible.com/ansible/latest/collections/community/sops/sops_lookup.html#ansible-collections-community-sops-sops-lookup)
plugin.

```yaml
tasks:
  - name: Read private key
    debug:
      msg: "{{ lookup('community.sops.sops', 'keys/private_key.sops') }}"
```

To encrypt files with SOPS,  use the `community.sops.sops_encrypt`
[module](https://docs.ansible.com/ansible/latest/collections/community/sops/sops_encrypt_module.html#ansible-collections-community-sops-sops-encrypt-module).

```yaml
tasks:
  - name: Write encrypted key
    community.sops.sops_encrypt:
      path: keys/private_key.sops
      context_text: "{{ private_key.privatekey }}"
```

## Vars Files

This auto decrypt vars files including `group_vars, host_vars`. All
sops-encrypted files must have the following extensions:
- .sops.yaml
- .sops.yml
- .sops.json

Add the relevant files to `group_vars` or `host_vars` and check that they are
decrypted properly with

```bash
$ ansible-inventory --list
```

To load files dynamically, use the `community.sops.load_vars`
[module](https://docs.ansible.com/ansible/latest/collections/community/sops/load_vars_module.html#ansible-collections-community-sops-load-vars-module)

```yaml
tasks:
  - name: Load encrypted variables
    community.sops.load_vars:
      file: keys/credentials.sops.yml
```

## Terraform Support
[Terraform SOPS Provider](https://github.com/carlpett/terraform-provider-sops)
