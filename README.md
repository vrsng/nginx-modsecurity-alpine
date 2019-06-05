# nginx-modsecurity-alpine

 - SSDEEP - 2.14.1
 - MODSECURITY - 3.0.3
 - MODSECURITY_NGINX  - 1.0.0
 - OWASP - 3.1.0
 - NGINX - 1.16.0

```
docker run -it \
  -e NGINX_PROXY_PASS=http://your-back-end:port/ \
  -p 8765:80 \
  vrsng/nginx-modsecurity-alpine
```

inspired by krish512/modsecurity
