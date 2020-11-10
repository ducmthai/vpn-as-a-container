# Proxy through VPN connection in a Docker container

![vpncontainer](vpncontainer.png)

## Introduction
`vpn-as-a-container` is a HTTP/SOCKS5 proxy server chaining with a NordVPN connection. It includes:

- OpenVPN connection to NordVPN service with selectable region
- SOCKS5 proxy server with [brook](https://github.com/txthinking/brook)
- HTTP proxy with [privoxy](http://www.privoxy.org/)
- Killswitch using `ufw`: only allow inbound from local network and outbound through `tun0` interface
- IPv6 disabled
- Update NordVPN connection profiles monthly

## Starting the VPN Proxy
### `vpn.config`

The main configuration file, contain the following values:

- `REGION`: (Optional) The default server is set to `ie33`. `REGION` should match the supported NordVPN `.opvn` server config.
- `USERNAME`: NordVPN username.
- `PASSWORD`: NordVPN password.
- `PROXY_MODE`: socks5 or http to use SOCKS5 or HTTP as proxy protocol.
- `PROTOCOL`: UDP or TCP which are supported by NordVPN.

## Environment variables

The environment variables needed for exposing the proxy to the local network:

- `PROXY_PORT`: Proxy port
- `LOCAL_NETWORK`: The CIDR mask of the local IP addresses (e.g. 192.168.0.1/24, 10.1.1.0/24) which will be acessing the proxy. This is so the response to a request can be returned to the client (i.e. your browser).
- `NORD_PROFILES_UPDATE`: Whether to update OpenVPN profiles or not. Possible values: yes|no.

These variables can be specified in the command line or in the `.env` file in the case of `docker-compose`.

### Set password via file

Passwords can be set using a `FILE__` prefixed environment variable where its value is path to the file contains the password:

```Shell
FILE__PASSWORD=/vpn/vpnpasswd
```

### Start with `docker run`

```Shell
docker build -t ducmthai/vpncontainer .
docker run -d \
--cap-add=NET_ADMIN \
--device=/dev/net/tun \
--name=vpn_proxy \
--dns=103.86.96.100 --dns=103.86.99.100 \
--restart=always \
-e "PROXY_PORT=3128" \
-e "LOCAL_NETWORK=192.168.0.1/24" \
-e "FILE__PASSWORD=/vpn/vpnpasswd" \
-v /etc/localtime:/etc/localtime:ro \
-v ./vpn.config:/vpn/vpn.config:ro \
-v "$(pwd)"/vpnpasswd:/vpn/vpnpasswd:ro \
-p 3128:3128 \
ducmthai/vpncontainer
```

### Start with `docker-compose`

A `docker-compose.yml` file is also provided:

```Shell
docker-compose up -d
```

## Connecting to the VPN Proxy

Set proxy on host machine to `socks5h://127.0.0.1:${PROXY_PORT}` or `socks5://127.0.0.1:${PROXY_PORT}`.

```Shell
curl -x socks5h://127.0.0.1:3128 -L ifconfig.co/json
```

## Tested environments
- Raspberry Pi 4 B+ (4GB model)
- WSL 2 + Docker WSL2 technical preview (2.1.2.0)
- MacOS 10.15.4
- Linux Mint 19.2
- Windows 10 + VirtualBox Alpine guest

## Notes
WSL and VirtualBox use high CPU under loads.
