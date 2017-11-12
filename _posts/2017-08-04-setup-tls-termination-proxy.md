---
title: Setup SSL/TLS termination proxy using Let's Encrypt and NGINX
layout: default
tags:
 - Linux
 - NGINX
 - HTTP
 - Reverse Proxy
 - Termination Proxy
 - TLS
 - SSL
---

* Create NGINX site configuration file `/etc/nginx/sites-available/terminationproxy.conf` with following contents:
    ```nginx
    server {
        listen 80;

        location ^~ /.well-known {
            alias /var/www/letsencrypt/.well-known;
        }
    }
    ```

* Enable termination proxy configuration by adding a link to NGINX's `sites-enabled` directory:
```shell
sudo ln -s /etc/nginx/sites-available/terminationproxy.conf /etc/nginx/sites-enabled/terminationproxy.conf
```

* (Re)start NGINX:
```shell
sudo service nginx restart
```

* Generate a [Let's Encrypt](https://letsencrypt.org/) certificate using `certbot` (replace `www.example.com` by your domain). `certbot` will take care of automatically re-newing the certificate well before it expires:
```shell
sudo certbot certonly --webroot -m your-email@example.com --rsa-key-size 4096 -w /var/www/letsencrypt -d www.example.com
```

* Add following section to file `/etc/nginx/sites-available/terminationproxy.conf` :
    ```nginx
    server {
        listen 443;

        ssl on;
        # replace www.example.com by your domain
        ssl_certificate     /etc/letsencrypt/live/www.example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/www.example.com/privkey.pem;

        location / {
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Proto $scheme;

            # replace address of your (internal) HTTP server
            proxy_pass           http://10.0.0.99:8888;
            proxy_read_timeout   90;
        }
    }
    ```

* Restart NGINX:
```shell
sudo service nginx restart
```

* Make sure NGINX restarts regularly so that it switches to new certificates as they become available.
  1. Open crontab file:
```shell
$ sudo crontab -e
```
  1. Add something like this:
```config
# restart NGINX every Friday at 04:13
13 04 * * fri service nginx restart
```
