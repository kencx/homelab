# Traefik

## Lets Encrypt Setup
1. Create an `acme/acme.json` file with `0600` permissions.
2. Configure the `certificateResolvers` options in the static configuration.
3. Populate `DO_TOKEN` environment variable with a DigitalOcean API token.
