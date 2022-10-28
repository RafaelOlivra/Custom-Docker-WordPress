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

# Fix certbot live cert files location
if [ -d /var/imported/ssl/live/$DOMAIN-0001 ]; then
    if [[ -L /var/imported/ssl/live/$DOMAIN-0001 ]]; then
        echo "Live cert files symlink already found, skipping operation"
    else
        echo "Fixing live cert files location"
        rm -rf /var/imported/ssl/live/$DOMAIN/
        cp -rf /var/imported/ssl/live/$DOMAIN-0001 /var/imported/ssl/live/$DOMAIN/ 2>/dev/null || :
        cp -rf /var/imported/ssl/live/$DOMAIN-0001 /var/imported/ssl/live/$DOMAIN/ 2>/dev/null || :
        rm -rf /var/imported/ssl/live/$DOMAIN-0001
        ln -sf /var/imported/ssl/live/$DOMAIN/ /var/imported/ssl/live/$DOMAIN-0001
    fi
fi

# Setup snakeoil certs if needed
if [[ ! -f /var/imported/ssl/live/$DOMAIN/fullchain.pem ]]; then
    if [ $USE_SNAKEOIL_CERT_FALLBACK == 'true' ]; then
        echo "Setting up snakeoil certs"
        mkdir -p /var/imported/ssl/snakeoil/$DOMAIN/
        cp /etc/ssl/certs/ssl-cert-snakeoil.pem /var/imported/ssl/snakeoil/$DOMAIN/fullchain.pem 2>/dev/null || :
        cp /etc/ssl/private/ssl-cert-snakeoil.key /var/imported/ssl/snakeoil/$DOMAIN/privkey.pem 2>/dev/null || :
        sed "s/imported\/ssl\/live/imported\/ssl\/snakeoil/g" /etc/apache2/sites-available/$DOMAIN.conf > /tmp/.intermediate-vhost-tmp
        cp /tmp/.intermediate-vhost-tmp /etc/apache2/sites-available/$DOMAIN.fallback.conf

        echo "Enabling snakeoil ssl fallback apache config"
        a2dissite $DOMAIN.conf
        a2ensite $DOMAIN.fallback.conf
    fi
# Seems like we have let's encrypt certificates, let's make sure they work
else
    if [[ -f /etc/apache2/sites-available/$DOMAIN.fallback.conf ]]; then
        echo "Let's encrypt cert files are available! Enabling let's encrypt apache config"
        a2dissite $DOMAIN.fallback.conf
        a2ensite $DOMAIN.conf
        rm -rf /etc/apache2/sites-available/$DOMAIN.fallback.conf
    fi
fi

# Go live!
service apache2 restart
tail -f /dev/null