# goatcounter
FROM cgr.dev/chainguard/go:latest AS build

WORKDIR /src

ARG GITHUB_GOATCOUNTER_OWNER=arp242
ARG GITHUB_GOATCOUNTER_REPOSITORY=goatcounter
ARG GITHUB_GOATCOUNTER_REVISION=57c95db06282b80d6fa7e486faa8ce12fd6dd0c6

RUN git init \
  && git remote add origin https://github.com/${GITHUB_GOATCOUNTER_OWNER}/${GITHUB_GOATCOUNTER_REPOSITORY}.git \
  && git fetch --depth 1 origin $GITHUB_GOATCOUNTER_REVISION \
  && git reset --hard $GITHUB_GOATCOUNTER_REVISION \
  \
  && go build -v -trimpath \
    -tags osusergo,netgo,sqlite_omit_load_extension \
    -ldflags="-X zgo.at/goatcounter/v2.Version=$GITHUB_GOATCOUNTER_REVISION -s -w -extldflags=-static -buildid=" \
    -o /goatcounter \
    ./cmd/goatcounter \
  \
  && cd .. && rm /src -rf

# runtime
FROM cgr.dev/chainguard/busybox:latest AS runtime

COPY --from=build --chmod=0555 /goatcounter /usr/bin/goatcounter
COPY --chmod=0555 entrypoint.sh /usr/bin/entrypoint.sh

WORKDIR /var/run/kalaclista

USER root:root
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
