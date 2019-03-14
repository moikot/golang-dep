# Golang image with Dep

A multi-platform image for golang [dep tool](https://github.com/golang/dep).

[![Build Status](https://travis-ci.com/moikot/golang-dep.svg?branch=master)](https://travis-ci.com/moikot/golang-dep)
![Platform](https://img.shields.io/badge/platform-linux%2Famd64-blue.svg)
![Platform](https://img.shields.io/badge/platform-linux%2Farm/v7-blue.svg)
![Platform](https://img.shields.io/badge/platform-linux%2Farm64-blue.svg)

## How to Build

Assuming that you have Docker up and running, run the following commands:

```shell
git clone https://github.com/moikot/golang-dep
cd golang-dep
docker build -t goland-dep .
```

## How to use

This image intended to be used as a build image for building your Golang applications using Docker.
Here is an example of a Docker file for building one.

```docker
FROM moikot/golang-dep as build-env

ARG APP_FOLDER=/go/src/github.com/foo/bar/

ADD . ${APP_FOLDER}
WORKDIR ${APP_FOLDER}

RUN dep ensure -vendor-only

# Compile independent executable
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /bin/main .

FROM scratch

COPY --from=build-env /bin/main /

ENTRYPOINT ["/main"]
```
