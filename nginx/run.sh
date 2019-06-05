#!/bin/sh

export NGINX_PROXY_PASS=${NGINX_PROXY_PASS:="http://www.example.com/"}

echo "NGINX_PROXY_PASS is set to ${NGINX_PROXY_PASS}" > /dev/stdout

sed -e "s \$NGINX_PROXY_PASS $NGINX_PROXY_PASS g" -i /etc/nginx/nginx.conf

exec /usr/local/nginx/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
