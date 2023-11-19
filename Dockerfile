FROM php:7.4-cli
USER root

# Image config
ENV SKIP_COMPOSER 1
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1
ENV COMPOSER_ALLOW_SUPERUSER 1

# Update package lists and install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libpq-dev \
    unzip postgresql-client \
    git wget nano \
    && apt-get clean

# Install PHP extensions
#&& docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql zip mbstring xml curl soap intl bcmath opcache ctype dom exif fileinfo hash sockets iconv imap json pdo pdo_pgsql pdo_sqlite pgsql phar session xmlreader xmlwriter xsl pcntl

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql zip mbstring xml curl soap intl bcmath opcache pdo pdo_pgsql pgsql pcntl
    
# Composer installation (optional but commonly used)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set timezone (you can modify this to your desired timezone)
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Create a non-root user (optional but recommended for security)
#RUN useradd -ms /bin/bash appuser
#USER appuser

ADD mailrest.zip /app/mailrest.zip
# composer install
RUN mkdir -p /app && cd /app && unzip -qo mailrest.zip && composer install && rm -rf mailrest.zip || true

WORKDIR /app

ENTRYPOINT php -S 0.0.0.0:$PORT index.php
