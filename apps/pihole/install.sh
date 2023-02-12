#!/bin/bash

sudo apt install curl git sqlite3
curl -sSL https://install.pi-hole.net | bash
pihole -v
