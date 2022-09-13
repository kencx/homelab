#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y sudo \
	curl \
	git \
	openssh-server \
	vim \
	make \
	gnupg \
	software-properties-common

# basic security hardening
# create new user, add to sudo

# install docker, compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

# install nomad, consul, vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install -y nomad consul vault
