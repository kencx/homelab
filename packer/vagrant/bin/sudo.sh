#!/bin/sh -eux

echo 'debian ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/debian
chmod 0440 /etc/sudoers.d/debian
