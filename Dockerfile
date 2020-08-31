FROM golang:alpine as builder
RUN set -ex && apk add --update git \
	&& go get -u -v github.com/txthinking/brook/cli/brook

FROM alpine:latest

ARG region=ie33
ARG username=
ARG password=
ARG protocol=udp
ARG localnet="192.168.0.0/24"
ARG proxy_port=3128

COPY --from=builder /go/bin/brook /usr/bin
COPY vpn /vpn

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && apk --update --no-cache add openvpn ufw@community runit \
  && rm -rf /var/cache/apk/* \
  && find /vpn -name run | xargs chmod u+x

ENV REGION=${region} \
    USERNAME=${username} \
    PASSWORD=${password} \
    PROTOCOL=${protocol} \
    LOCAL_NETWORK=${localnet} \
    PROXY_PORT=${proxy_port}

CMD ["runsvdir", "/vpn"]
