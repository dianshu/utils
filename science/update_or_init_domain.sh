#!/bin/bash
echo $1
cd /etc/nginx/conf.d
rm *.conf

cat>$1.conf<<EOF
server {
    listen 80;
    listen [::]:80;
    listen 81 http2;
    server_name $1;
    root /usr/share/nginx/html;
    location / {
        proxy_ssl_server_name on;
        proxy_pass https://www.wallpaperstock.net;
        proxy_set_header Accept-Encoding '';
        sub_filter "www.wallpaperstock.net" "$1";
        sub_filter_once off;
    }
        location = /robots.txt {}
}
EOF

# setup acme to sign domain
cd ~
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh  --upgrade  --auto-upgrade
~/.acme.sh/acme.sh --issue -d $1 --nginx --cert-file /etc/v2ray/ --key-file /etc/v2ray/

# update v2ray config
old_domain_name = $(grep -oP '"serverName": "\K[^"]+' /etc/v2ray/config.json)
sed 's/$old_domain_name/$1/g' /etc/v2ray/config.json
echo "done" 