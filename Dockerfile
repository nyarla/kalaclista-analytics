# goatcounter
FROM golang:1.22.5-alpine as goatcounter

RUN mkdir -p /app/bin
WORKDIR /

ARG GITHUB_GOATCOUNTER_OWNER=arp242
ARG GITHUB_GOATCOUNTER_REPOSITORY=goatcounter
ARG GITHUB_GOATCOUNTER_REVISION=57c95db06282b80d6fa7e486faa8ce12fd6dd0c6

RUN apk add --update --no-cache --virtual goatcounter-build \
    build-base \
    gcc \
    git \
    musl-dev \
  \
  && mkdir -p /src && cd /src \
  \
  && git init \
  && git remote add origin https://github.com/${GITHUB_GOATCOUNTER_OWNER}/${GITHUB_GOATCOUNTER_REPOSITORY}.git \
  && git fetch --depth 1 origin $GITHUB_GOATCOUNTER_REVISION \
  && git reset --hard $GITHUB_GOATCOUNTER_REVISION \
  \
  && go build -v -trimpath \
    -ldflags="-X zgo.at/goatcounter/v2.Version=$(shell echo $GITHUB_GOATCOUNTER_REVISION | cut -c 1-7) -s -w -extldflags=-static -buildid=" \
    -o /app/bin/goatcounter \
    ./cmd/goatcounter \
  \
  && apk del --purge goatcounter-build \
  && cd / && rm -rf /src /root

# runtime
FROM alpine:3.20 as runtime

COPY --from=goatcounter --chmod=0500 /app/bin/goatcounter /app/bin/goatcounter
COPY --chmod=0500 entrypoint.sh /app/bin/entrypoint.sh

ENV PATH=/app/bin:$PATH
WORKDIR /var/run/kalaclista

ENTRYPOINT ["/app/bin/entrypoint.sh"]
