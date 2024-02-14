REV := 9b3f565e87e135512793275f8d400649bfe1a1bd

all:
	@echo hi,

up: build
	env DOCKER_BUILDKIT=1 flyctl deploy -a kalaclista-analytics --local-only --image-label latest \
		--build-arg GITHUB_GOATCOUNTER_REVISION=$(REV)

build:
	env DOCKER_BUILDKIT=1 docker build -t kalaclista-analytics-v1 \
		--build-arg GITHUB_GOATCOUNTER_REVISION=$(REV) \
		.
