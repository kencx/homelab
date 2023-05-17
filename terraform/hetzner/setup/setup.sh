#!/bin/bash

# steps to post-provision vps reverse proxy

git clone https://github.com/kencx/dotfiles.git
cd dotfiles && make remote

docker pull nginx:1.23-alpine
docker pull certbot/certbot:v1.28.0

docker network create proxy

cd nginx && dcu
