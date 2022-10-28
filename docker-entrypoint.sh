#!/usr/bin/env bash
set -Eeuo pipefail

# Install apache if needed
if [[ ! -f /usr/sbin/apache2 ]]
then
apt update
apt install -y apache2

# Set Apache variables
echo "ServerName $DOMAIN" >> /etc/apache2/apache2.conf
echo "Define ServerName $DOMAIN" >> /etc/apache2/conf-enabled/environment.conf

# Enable apache modules & php-fpm config
a2enmod http2 ssl mpm_event rewrite headers deflate expires brotli proxy_fcgi setenvif
a2enconf php-fpm
a2ensite $DOMAIN.conf

# Remove the default index.html file added by the initial apache install
rm -f /var/www/html/index.html
fi

# Go live!
service apache2 restart
tail -f /dev/null