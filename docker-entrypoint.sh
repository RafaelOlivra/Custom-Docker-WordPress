#!/usr/bin/env bash
set -Eeuo pipefail

# Enable PHP-FPM with Apache
apt update
apt install -y apache2

# Set Apache variables
echo "ServerName $DOMAIN" >> /etc/apache2/apache2.conf
echo "Define ServerName $DOMAIN" >> /etc/apache2/conf-enabled/environment.conf

# Enable HTTPS
a2enmod http2 ssl mpm_event rewrite headers deflate expires brotli proxy_fcgi setenvif
a2enconf php-fpm
a2ensite $DOMAIN.conf

# Remove the default index.html file added by Apache
rm -f /var/www/html/index.html

# Go live!
service apache2 restart
tail -f /dev/null