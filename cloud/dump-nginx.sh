#!/usr/bin/env bash
# Print Cloud's nginx config files and process stack definition (secret-looking lines redacted).
set +e
redact() { sed -E 's/((key|secret|token|password|passwd|dsn|auth)[A-Za-z_]*["'"'"']?\s*[:=]\s*).*/\1[redacted]/I'; }
for f in /etc/nginx/conf.d/*.conf /etc/nginx/server-opts.d/* /etc/nginx/site-opts.d/* /etc/nginx/custom.d/* /etc/nginx/templates/*; do
  [ -f "$f" ] && { echo "##### $f ($(stat -c '%U %a' "$f"))"; redact < "$f"; }
done
echo "##### ls site-opts.d server-opts.d templates"; ls -la /etc/nginx/site-opts.d /etc/nginx/server-opts.d /etc/nginx/templates
echo "##### /opt/cloud"; ls -la /opt/cloud 2>&1
echo "##### cloud-init.yaml"; redact < /opt/cloud/cloud-init.yaml 2>&1 | head -400
