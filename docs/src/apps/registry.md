# Registry

## Basic Auth
Create a password file with `htpasswd`:

```bash
$ docker run \
    --entrypoint htpasswd \
    httpd:2 -Bbn foo password > htpasswd
```

## Usage

Login to the registry by providing the username and password given in [Basic
Auth](#basic-auth):

```bash
$ docker login foo.example.com
```

## References

- [Docker Registry](https://docs.docker.com/registry/deploying/)
