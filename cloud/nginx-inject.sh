#!/usr/bin/env bash
# Option 2: add a /fast/ location that proxies to the Go binary on loopback,
# by rewriting Cloud's generated nginx server config during the build.
set -e
conf=/etc/nginx/conf.d/default.conf
snippet='    location ^~ /fast/ { proxy_pass http://127.0.0.1:7070; proxy_set_header Host $host; proxy_set_header X-Forwarded-For $http_x_forwarded_for; proxy_set_header X-Forwarded-Proto $cloud_forwarded_proto; add_header X-Fastpath-Via nginx always; }'
tmp=$(mktemp)
if grep -qE 'listen[^;]*8080' "$conf"; then
  awk -v s="$snippet" '{print} !done && /listen[^;]*8080/ {print s; done=1}' "$conf" > "$tmp"
else
  awk -v s="$snippet" '!done && /^[[:space:]]*location / {print s; done=1} {print}' "$conf" > "$tmp"
fi
cp "$conf" /tmp/default.conf.orig
rm -f "$conf" && cp "$tmp" "$conf"
echo "##### inject diff"; diff /tmp/default.conf.orig "$conf" || true
nginx -t
