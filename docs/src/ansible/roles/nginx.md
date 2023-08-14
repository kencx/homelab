# Nginx

This role installs, configures and start [nginx](https://nginx.org/en/) as a
service.

Some configurations snippets are available to be reused in `{{ nginx_dir
}}/snippets`:

- `tls.conf` - Common SSL/TLS configuration
- `security.conf` - Common security headers configuration

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| nginx_dir | Nginx configuration directory | string | `/etc/nginx` |
| nginx_log_dir | Nginx logs directory | string | `/var/log/nginx` |
| nginx_certbot_webroot | Webroot directory for certbot | string | `/var/www/letsencrypt` |
