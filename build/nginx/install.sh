#!/bin/bash
set -e

# Configure Nginx
cp build/nginx/nginx.conf /etc/nginx/nginx.conf
mkdir -p /etc/nginx/main.d
cp build/nginx/nginx_main_d_default.conf /etc/nginx/main.d/default.conf
mkdir -p /etc/nginx/sites-enabled
rm /etc/nginx/conf.d/default.conf

# Install Nginx runit service
mkdir /etc/service/nginx
cp build/runit/nginx /etc/service/nginx/run
chmod +x /etc/service/nginx/run

mkdir /etc/service/nginx-log-forwarder
cp build/runit/nginx-log-forwarder /etc/service/nginx-log-forwarder/run
chmod +x /etc/service/nginx-log-forwarder/run

sed -i 's|invoke-rc.d nginx rotate|sv 1 nginx|' /etc/logrotate.d/nginx
sed -i -e '/sv 1 nginx.*/a\' -e '		reopen-logs >/dev/null 2>&1' /etc/logrotate.d/nginx
