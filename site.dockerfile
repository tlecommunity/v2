FROM alpine:3

RUN apk add --no-cache hugo

WORKDIR /usr/src/site
