
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
    && apt-get clean

COPY index.html /var/www/

COPY ./certs /etc/nginx/certs/

COPY config/default /etc/nginx/sites-available/
RUN ln -fs /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

RUN service mysql start
RUN service mysql start && \
    mysql -e "CREATE DATABASE wordpress;" && \
    mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';" && \
    mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

RUN  wget http://wordpress.org/latest.tar.gz && \
    tar xzvf latest.tar.gz && mv wordpress /var/www/wordpress && \ 
    chown -R www-data:www-data /var/www/wordpress

RUN wget -O /tmp/phpMyAdmin.zip https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip && \
    unzip /tmp/phpMyAdmin.zip -d /tmp/ && \
    mv /tmp/phpMyAdmin-5.2.1-all-languages /var/www/phpmyadmin && \
    chown -R www-data:www-data /var/www/phpmyadmin && \
    rm /tmp/phpMyAdmin.zip

CMD service mysql start && \
    service php7.3-fpm start && \
    service nginx start && \
    tail -f /dev/null
