# Webhook

This role installs, configures and start [webhook](https://github.com/adnanh/webhook).

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| webhook_version | Version to install | string | `2.8.1` |
| webhook_hooks_dir | Hooks directory | string | `/etc/webhook/hooks` |
| webhook_port | Port to serve hooks on | int | `9000` |
| webhook_nginx_setup | Setup webhook behind nginx proxy | bool | `false` |
| webhook_nginx_dir | Nginx configuration directory | string | `/etc/nginx` |
| webhook_nginx_server_name | Nginx server name for webhook | string | |
| webhook_certbot_webroot | Webroot directory for certbot | string | `/var/www/letsencrypt` |
| webhook_certbot_dir | Certbot directory | string | `/etc/letsencrypt` |
