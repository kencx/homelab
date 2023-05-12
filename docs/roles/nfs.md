This role configures an NFS server.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| nas_user | User to be created | string | `debian` |
| nfs_exports | NFS directories to be exported | dict | `{}` |

- `nfs_exports` should have the following structure:

```
nas_nfs_exports:
  - dir: /home/debian/apps
    ip: 10.10.10.2
    opts: rw,sync,no_subtree_check,no_root_squash
```
