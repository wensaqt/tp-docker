
FROM debian:buster

RUN apt-get update && apt-get install -y \
    nginx \
    default-mysql-server \
    php-fpm \
    php-mysql \
    php-xml \
    php-mbstring \
    php-zip \
    php-curl \
    php-gd \
    php-json \
    curl \
    wget \
    unzip \
    certbot \
    python3-certbot-nginx \
    && apt-get clean

COPY ./ssl /etc/nginx/ssl

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf 

RUN service mysql start

RUN service mysql start && \
    mysql -e "CREATE DATABASE wordpress;" && \
    mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';" && \
    mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

RUN wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 && \
    chown -R www-data:www-data /var/www/html

RUN wget -O /tmp/phpMyAdmin.zip https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip && \
    unzip /tmp/phpMyAdmin.zip -d /tmp/ && \
    mv /tmp/phpMyAdmin-5.2.1-all-languages /var/www/phpmyadmin && \
    chown -R www-data:www-data /var/www/phpmyadmin && \
    rm /tmp/phpMyAdmin.zip

CMD service mysql start && \
    service php7.3-fpm start && \
    service nginx start && \
    tail -f /dev/null
