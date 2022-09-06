.PHONY: pre-commit install

pre-commit:
	pre-commit run --all-files

install: requirements.yml
	ansible-galaxy install -f -r requirements.yml
