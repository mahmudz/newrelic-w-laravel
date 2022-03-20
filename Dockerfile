FROM php:8.0-fpm

# Copy composer.lock and composer.json into the working directory
COPY composer.lock composer.json /var/www/html/

# Set working directory
WORKDIR /var/www/html/

RUN apt update

RUN apt install -y \
            g++ \
            libicu-dev \
            libpq-dev \
            libzip-dev \
            zip \
            zlib1g-dev \
            wget

RUN docker-php-ext-install \
            intl \
            opcache \
            pdo \
            pdo_mysql

# Install composer (php package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy existing application directory contents to the working directory
COPY . /var/www/html

# Assign permissions of the working directory to the www-data user
RUN chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache


EXPOSE 9000

CMD ["php-fpm"]
