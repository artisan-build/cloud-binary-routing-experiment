#!/usr/bin/env bash
# Read-only diagnostics about the web server setup. Prints names, not secret values.
set +e
echo "### whoami"; id; echo "pwd=$(pwd)"; uname -a
echo "### env names"; env | cut -d= -f1 | sort | tr '\n' ' '; echo
echo "### processes"; ps -eo pid,ppid,user,args 2>/dev/null | cut -c1-300
echo "### pid1"; tr '\0' ' ' </proc/1/cmdline; echo
echo "### listening"; (ss -ltnp 2>/dev/null || netstat -ltnp 2>/dev/null || cat /proc/net/tcp /proc/net/tcp6) | head -40
echo "### /etc/nginx"; ls -laR /etc/nginx 2>&1 | head -80
echo "### writable?"; for d in /etc/nginx /etc/nginx/conf.d /etc/nginx/sites-enabled /etc/nginx/http.d /etc/nginx/templates /usr/local/etc/php/conf.d /usr/local/etc/php-fpm.d /etc/frankenphp /etc/caddy; do [ -e "$d" ] && { [ -w "$d" ] && echo "W $d" || echo "- $d"; }; done
echo "### nginx -T"; nginx -T 2>&1 | head -400
echo "### entrypoints"; ls -la / /usr/local/bin /etc/entrypoint.d /etc/s6-overlay /etc/supervisor* /docker-entrypoint.d 2>&1 | head -80
echo "### templates"; grep -rIl -E 'envsubst|nginx' /usr/local/bin /etc/entrypoint.d /docker-entrypoint.d /etc/s6-overlay 2>/dev/null | head -20
echo "### caddy"; ls -la /etc/frankenphp /etc/caddy 2>&1; which frankenphp caddy 2>&1
echo "### done"
