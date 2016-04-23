#!/bin/bash

coreo_dir="$(pwd)"
files_dir="$(pwd)/../files"

NGINX="/etc/nginx"

mkdir -p $NGINX/sites-available
mkdir -p $NGINX/sites-enabled
cp "$files_dir/nginx.conf" "$NGINX/nginx.conf"
cp "$files_dir/thumbor.nginx.conf" "$NGINX/sites-available/thumbor.$DNS_ZONE.conf"
ln -s "$NGINX/sites-available/thumbor.$DNS_ZONE.conf" "$NGINX/sites-enabled/thumbor.$DNS_ZONE.conf"

service nginx restart
/sbin/chkconfig nginx on
