FROM php:8.2-apache

# Instala dependências para o Satis e Git
RUN apt-get update \
 && apt-get install -y git zlib1g-dev libzip-dev unzip jq\
 && docker-php-ext-install zip \
 && a2enmod rewrite \
 && sed -i 's!/var/www/html!/var/www/public!g' /etc/apache2/sites-available/000-default.conf \
 && mv /var/www/html /var/www/public \
 && curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/local/bin --filename=composer \
 && echo "AllowEncodedSlashes On" >> /etc/apache2/apache2.conf

RUN echo "date.timezone=UTC" > $PHP_INI_DIR/conf.d/date_timezone.ini

RUN composer create-project --keep-vcs --no-dev composer/satis:dev-main /satis 

WORKDIR /satis

COPY satis.json .
COPY packages/ ./packages/
COPY verify-archives.sh/ .

RUN rm -rf public/*
RUN php bin/satis build satis.json public
RUN chmod +x verify-archives.sh
RUN ./verify-archives.sh

RUN rm -rf /var/www/public/* && \
    cp -r public/* /var/www/public/

EXPOSE 80
