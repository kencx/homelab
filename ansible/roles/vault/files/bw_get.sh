#!/bin/bash

NAME="$1"
SESSION_ID=$(bw unlock --raw "$2")
bw sync --quiet --session "$SESSION_ID"
bw get password "$NAME" --response --session "$SESSION_ID"
