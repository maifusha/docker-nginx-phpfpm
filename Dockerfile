FROM php:7.0-fpm

LABEL maintainer="lixin <1045909037@qq.com>"

COPY conf/sources.list /etc/apt/sources.list

RUN curl http://nginx.org/keys/nginx_signing.key > /tmp/nginx_signing.key \
    && apt-key add /tmp/nginx_signing.key && rm -f /tmp/nginx_signing.key

RUN apt-get update && apt-get install -y --no-install-recommends \
        vim \
        git \
        sudo \
        unzip \
        dnsutils \
        nginx \
        supervisor \
        openssh-client \
        build-essential \
        libpq-dev \
        python-dev \
        libmcrypt-dev \
        libpng12-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
    && curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        mcrypt \
        bcmath \
        zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer config -g repo.packagist composer https://packagist.phpcomposer.com \
    && composer global require "hirak/prestissimo:^0.3"

RUN npm install -g cnpm gulp bower yarn --registry=https://registry.npm.taobao.org \
    && yarn config set registry https://registry.npm.taobao.org

COPY conf/etc /etc
COPY conf/php-fpm /usr/local/etc

ENV PATH=$PATH:~/.composer/vendor/bin

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /var/www/html

EXPOSE 80 443

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
