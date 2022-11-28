#!/bin/sh -eux

mkdir -m 0700 -p /home/debian/.ssh
echo 'ssh-ed25519 ssh-key foo' >> /home/debian/.ssh/authorized_keys
chown -R debian:debian /home/debian/.ssh
chmod 0600 /home/debian/.ssh/authorized_keys
