#!/usr/bin/env bash
set -Eeuo pipefail

# Install apache if needed
if [[ ! -f /usr/sbin/apache2 ]]; then

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

# Setup snakeoil cert symlinks if needed
if [[ ! -f /var/imported/ssl/live/$DOMAIN/fullchain.pem ]]; then
    if [ $USE_SNAKEOIL_CERT_FALLBACK == 'true' ]; then
        mkdir -p /var/imported/ssl/live/$DOMAIN/
        cp /etc/ssl/certs/ssl-cert-snakeoil.pem /var/imported/ssl/live/$DOMAIN/fullchain.pem
        cp /etc/ssl/private/ssl-cert-snakeoil.key /var/imported/ssl/live/$DOMAIN/privkey.pem
    fi
fi

# Go live!
service apache2 restart
tail -f /dev/null