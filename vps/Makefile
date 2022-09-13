.PHONY: cert renew

cert: docker-compose.yml
	docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d "$(d)"

renew: docker-compose.yml
	docker compose run --rm certbot -q renew
