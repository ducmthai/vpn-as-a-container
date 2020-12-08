#!/usr/bin/with-contenv sh
if [ -n "${HC_PORT}" ]; then
  echo "Healthcheck through proxy on port ${HC_PORT}"
  http_proxy=http://$(hostname -i):${HC_PORT} wget -Y on -q -O - ifconfig.co/ip | grep -v "$1" || exit 1
else
  echo "Healthcheck without proxy ${HC_PORT}"
  wget -q -O - ifconfig.co/ip | grep -v "$1" || exit 1
fi