FROM golang:latest AS build-env
WORKDIR /src
ENV CGO_ENABLED=0
COPY go.mod /src/
RUN go mod download
COPY . .
RUN  go build -a -o gobuster -ldflags="-s -w" -gcflags="all=-trimpath=/src" -asmflags="all=-trimpath=/src"

FROM alpine:latest

RUN apk add --no-cache ca-certificates \
    && rm -rf /var/cache/*

RUN mkdir -p /app \
    && adduser -D gobuster \
    && chown -R gobuster:gobuster /app

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1

RUN update-alternatives --set python /usr/bin/python3.7

USER gobuster
WORKDIR /app

COPY --from=build-env /src/gobuster .

ENTRYPOINT [ "./gobuster" ]
