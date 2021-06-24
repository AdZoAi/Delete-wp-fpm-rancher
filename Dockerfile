FROM wordpress:5.5.3-php7.3-fpm

RUN apt-get update && apt-get install -y \
        libicu-dev \
        libmcrypt-dev \
        libmagickwand-dev \
        libsodium-dev \
        libzip-dev \
        --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && pecl install redis-4.2.0 imagick-3.4.3 libsodium-2.0.21 \
    && docker-php-ext-enable redis imagick sodium

COPY ./ /usr/src/wordpress/

# OPcache defaults
ENV PHP_OPCACHE_ENABLE="1"
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="128"
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="10000"
ENV PHP_OPCACHE_REVALIDATE_FREQUENCY="0"
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"

# Install opcache and add the configuration file
RUN docker-php-ext-install opcache
ADD opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

# PHP-FPM defaults
ENV PHP_FPM_PM="dynamic"
ENV PHP_FPM_MAX_CHILDREN="5"
ENV PHP_FPM_START_SERVERS="2"
ENV PHP_FPM_MIN_SPARE_SERVERS="1"
ENV PHP_FPM_MAX_SPARE_SERVERS="2"
ENV PHP_FPM_MAX_REQUESTS="1000"

# Copy the PHP-FPM configuration file
COPY ./www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy the PHP application file
#COPY ./index.php /var/www/public/index.php
RUN chown -R www-data:www-data /var/www/public
