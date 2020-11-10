FROM alpine:3.12.1

ARG region=ie33
ARG username=
ARG password=
ARG protocol=udp
ARG localnet="192.168.0.0/24"
ARG proxy_port=3128
# Runtime architecture: arm64|amd64
ARG arch=arm64
ARG brook_version=20200909

ADD rootfs /

# s6 overlay Download
ADD https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-${arch}.tar.gz /tmp/s6overlay.tar.gz
# brook Download
ADD https://github.com/txthinking/brook/releases/download/v${brook_version}/brook_linux_${arch} /usr/bin/brook

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && apk upgrade --update --no-cache \
  && apk --update --no-cache add openvpn ufw@community privoxy \
  && tar xzf /tmp/s6overlay.tar.gz -C / \
  && rm /tmp/s6overlay.tar.gz \  
  && chmod +x /usr/bin/brook \
  && rm -rf /var/cache/apk/*

# Init
ENTRYPOINT [ "/init" ]