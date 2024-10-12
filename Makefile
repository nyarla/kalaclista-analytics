all:
	@echo hi,

up: build
	flyctl deploy -a kalaclista-analytics --local-only --image kalaclista-analytics-v2:latest --image-label latest

build:
	nix-build
	docker load -i result

test:
	docker run -it -p 8080:9080 --rm --env-file .env --entrypoint /bin/sh kalaclista-analytics-v2:latest
