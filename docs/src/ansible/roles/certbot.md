
# Certbot

This role installs, configures [certbot](https://certbot.eff.org/) to provision
Let's Encrypt certificates for the given domains.

A systemd timer is also configured to renew certificates regularly.

## Usage

The `certbot_create_command` variable is utilized within a dynamic
tasks that creates a certificate for each item in the `certbot_certs` list.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| certbot_dir | Certbot directory | string | `/etc/letsencrypt` |
| certbot_webroot | Webroot directory for certbot | string | `/var/www/letsencrypt` |
| certbot_admin_email | Default admin email for Let's Encrypt | string | `foo@example.com` |
| certbot_certs | | list | `[]` |
| certbot_create_command | Certbot command to create Let's Encrypt certificates | string | See below |

## Notes

`certbot_certs` should have the following structure:

```yml
certbot_certs:
    - email: bar@example.com
      webroot: /var/www/letsencrypt
      domains:
        - bar.example.com
    - domains:
        - foo.example1.com
```

`certbot_create_command` has the default command:

```yml
certbot_create_command: >-
  certbot certonly
  --non-interactive --agree-tos
  --email {{ item.email | default(certbot_admin_email) }}
  --webroot
  --webroot-path {{ item.webroot | default(certbot_webroot) }}
  -d {{ item.domains | join(',') }}
```
