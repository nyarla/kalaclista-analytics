REV := 603c4d20c3c4f85523a425b50f1333fc36c96a8d

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
