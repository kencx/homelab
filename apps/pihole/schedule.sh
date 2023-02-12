#!/bin/bash

block() {
	echo "blocking..."
	sqlite3 /etc/pihole/gravity.db "update adlist set enabled = true where id = 3;"
	pihole restartdns
}

unblock() {
	echo "unblocking..."
	sqlite3 /etc/pihole/gravity.db "update adlist set enabled = false where id = 3;"
	pihole restartdns
}
