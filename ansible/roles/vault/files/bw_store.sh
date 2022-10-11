#!/bin/bash
# set -euo pipefail

# build json item
NAME="$1"
PASSWORD="$2"
LOGIN=$(jq -n \
	--argjson uris [] \
	--arg username "" \
	--arg password "$PASSWORD" \
	--arg totp "" \
	'$ARGS.named')
ITEM=$(jq -n \
	--argjson type 1 \
	--arg name "$NAME" \
	--argjson login "$LOGIN" \
	'$ARGS.named')

SESSION_ID=$(bw unlock --raw "$3")
bw sync --quiet --session "$SESSION_ID"

BW_EXISTING=$(bw get item "$NAME" --response --session "$SESSION_ID")
BW_SUCCESS=$(echo "$BW_EXISTING" | jq -r '.success')
BW_DATA=$(echo "$BW_EXISTING" | jq -r '.data')
BW_ID=$(echo "$BW_DATA" | jq -r '.id')

if [[ "$BW_SUCCESS" = "false" ]]; then
	echo "Creating item..."
	echo "$ITEM" | bw encode | bw create item --session "$SESSION_ID" --quiet
elif [[ ! "$BW_DATA" = "" ]]; then
	echo "Item exists. Updating..."
	NEW_ITEM=$(echo "$BW_DATA" | jq ".login.password=\"${PASSWORD}\"")
	echo "$NEW_ITEM" | bw encode | bw edit item "$BW_ID" --session "$SESSION_ID" --quiet
else
	echo "bw get failed"
fi
