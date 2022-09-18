.PHONY: pre-commit install

pre-commit:
	pre-commit run --all-files

galaxy.install: requirements.yml
	ansible-galaxy install -f -r requirements.yml

restic.check:
	sudo autorestic exec check -av

restic.unlock:
	sudo autorestic exec unlock -av

restic.snapshot:
	sudo autorestic exec snapshots -av
