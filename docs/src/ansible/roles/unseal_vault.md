>**Work in Progress**: This role is unfinished and untested.

This role unseals an initialized but sealed Vault server. The unseal key shares
can be provided as:

- A variable array of keys
- A variable array of file paths to the keys on the remote filesystem
- Secrets from Bitwarden

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| unseal_vault_port | Configured Vault port | int | `8200` |
| unseal_vault_addr | Vault HTTP address | string | `http://localhost:8200` |
| unseal_store | Accepts `file, bitwarden` | string | |
| unseal_keys_files | Array of files with unseal keys | list | |
| unseal_keys | Array of key shares | list | |
| unseal_bw_password | Bitwarden password | string | |
| unseal_bw_keys_names | List of Bitwarden secrets storing key shares | list | |
