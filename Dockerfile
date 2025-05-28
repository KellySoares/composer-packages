FROM composer:2 AS satis-builder

RUN composer create-project --keep-vcs --no-dev composer/satis:dev-main /satis

WORKDIR /satis

COPY satis.json .
COPY packages/ ./packages/

RUN php bin/satis build satis.json public


FROM php:8.2-apache

RUN a2enmod rewrite

COPY --from=satis-builder /satis/public /var/www/html/

EXPOSE 80
