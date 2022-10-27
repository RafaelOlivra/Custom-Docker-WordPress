# A simple Docker Image for Containerized WordPress

It includes by default **Mariadb 10.6.4 / WordPress:fpm / Redis / Certbot SSL (Let's Encrypt)**.  
I made this because, while there are more "modern" approaches to run a WordPress container with reverse proxy via "Caddy" or "NGINX",
a lot of plugins still relies on custom .htaccess rules to work (301 Redirection Plugins, Webp Converter for Media, etc..), so is easier to just roll with what works best.  
For smaller sites, as long as you have an optimized theme and a good caching plugin, the performance difference between the apache server and the reverse proxy solutions is almost
insignificant.

## Usage
Clone the repo, create an .env file using the provided .env.example file as example (Use strong passwords!).
Then run:
```
docker-compose up
```
For the first time you run the container, Certbot will attempt to request an SSL certificate for you domain and then save the cert files to disk. Because of this,
Apache SSL will not work right away, you need to restart the container in order for apache to be able to read the cert files and enable SSL. Just run the docker-compose up command again, and that is it!

## Enabling Redis
To enable the Redis object cache on your WordPress installation, just install the **"Redis Object Cache"** plugin: https://wordpress.org/plugins/redis-cache/.  
Then go to **Settings > Redis > Enable Object Cache**. It should work out of the box.

