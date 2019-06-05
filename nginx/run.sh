#!/bin/sh

NGINX_PROXY_PASS=${NGINX_PROXY_PASS:="http://www.example.com/"}
test -n "${MODSECURITY_ENFORCE}" \
  && MODSECURITY_ENFORCE="On" \
  || MODSECURITY_ENFORCE="DetectionOnly"

echo "NGINX_PROXY_PASS is set to ${NGINX_PROXY_PASS}" > /dev/stdout
echo "MODSECURITY_ENFORCE is ${MODSECURITY_ENFORCE}" > /dev/stdout

sed -e "s \$NGINX_PROXY_PASS $NGINX_PROXY_PASS g" -i /etc/nginx/nginx.conf
sed -e "s \$MODSECURITY_ENFORCE $MODSECURITY_ENFORCE g" -i /etc/nginx/modsecurity.conf

exec /usr/local/nginx/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
