ARG GO_VERSION=1.11.6
ARG DEP_VERSION=v0.5.1

FROM golang:${GO_VERSION}-alpine

LABEL maintainer="sanisimov@moikot.com"

RUN apk add --no-cache musl-dev \
    \
    # Install build dependencies
    && apk add --no-cache --virtual .build-deps ca-certificates gcc git \
    \
    # Download Dep's packages
    && go get -d -u github.com/golang/dep \
    \
    # Checkout specific version
    && cd $(go env GOPATH)/src/github.com/golang/dep \
    && git checkout ${DEP_VERSION} \
    \
    # Build Dep from source
    && go install -ldflags="-X main.version=${DEP_VERSION}" ./cmd/dep \
    \
    # Install Dep's license
    && mkdir -p /usr/local/share/doc/dep \
    && cp LICENSE /usr/local/share/doc/dep/LICENSE \
    \
    # Remove source code and packages
    && rm -rf $(go env GOPATH)/src/github.com/golang/dep \
    && apk del .build-deps

ENTRYPOINT ["dep"]
CMD ["--help"]
