ARG GO_VERSION=1.12.9
ARG DEP_VERSION=v0.5.4

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine as build-env

LABEL maintainer="sanisimov@moikot.com"

# xx wraps go to automatically configure $GOOS, $GOARCH, and $GOARM
# based on TARGETPLATFORM provided by Docker.
COPY --from=tonistiigi/xx:golang / /

# Compile independent executable using go wrapper from xx:golang
ARG TARGETPLATFORM
RUN CGO_ENABLED=0

RUN apk add --no-cache git \
    \
    # Download Dep's packages
    && go get -d -u github.com/golang/dep \
    \
    # Checkout specific version
    && cd $(go env GOPATH)/src/github.com/golang/dep \
    && git checkout ${DEP_VERSION} \
    \
    # Build Dep from source
    && go build -ldflags="-X main.version=${DEP_VERSION}" \
    -o $(go env GOPATH)/bin/dep ./cmd/dep

FROM golang:${GO_VERSION}-alpine

RUN apk add --no-cache git \
   && mkdir -p /usr/local/share/doc/dep

COPY --from=build-env /go/bin/dep /go/bin/dep
COPY --from=build-env /go/src/github.com/golang/dep/LICENSE /usr/local/share/doc/dep/LICENSE

ENTRYPOINT ["dep"]
CMD ["--help"]
