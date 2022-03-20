FROM php:8.0-fpm

ARG NEW_RELIC_AGENT_VERSION
ARG NEW_RELIC_LICENSE_KEY
ARG NEW_RELIC_DAEMON_ADDRESS

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
            wget \
            gnupg \
            gnupg2 \
            gnupg1

RUN docker-php-ext-install \
            intl \
            opcache \
            pdo \
            pdo_mysql

RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list
RUN wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
RUN apt update
RUN apt-get -y install newrelic-php5

RUN NR_INSTALL_SILENT=1 newrelic-install install

RUN echo ${NEW_RELIC_LICENSE_KEY}
RUN echo ${NEW_RELIC_DAEMON_ADDRESS}

RUN sed -i -e s/\"REPLACE_WITH_REAL_KEY\"/${NEW_RELIC_LICENSE_KEY}/ \
  -e "s/newrelic.appname[[:space:]]=[[:space:]].*/newrelic.appname=\"test\"/" \
  -e '$anewrelic.distributed_tracing_enabled=true' \
  $(php -r "echo(PHP_CONFIG_FILE_SCAN_DIR);")/newrelic.ini

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
