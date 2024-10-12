REV := 530ab5edff553923fb04d9e1b1a9771f8a6d0461

all:
	@echo hi,

up: build
	env DOCKER_BUILDKIT=1 flyctl deploy -a kalaclista-analytics --local-only --image-label latest \
		--build-arg GITHUB_GOATCOUNTER_REVISION=$(REV)

build:
	env DOCKER_BUILDKIT=1 docker build -t kalaclista-analytics-v1 \
		$(EXTRA_FLAGS) \
		--build-arg GITHUB_GOATCOUNTER_REVISION=$(REV) \
		.

rebuild:
	@$(MAKE) EXTRA_FLAGS="--no-cache" build

test:
	docker run -it -p 8080:9080 --rm --env-file .env --entrypoint /bin/sh kalaclista-analytics-v1:latest
