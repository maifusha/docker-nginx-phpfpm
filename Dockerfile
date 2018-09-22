FROM php:7.0-fpm-alpine

LABEL maintainer="lixin <1045909037@qq.com>"

RUN echo 'http://mirrors.ustc.edu.cn/alpine/v3.4/main/' > /etc/apk/repositories && \
		apk add --no-cache \
		git \
		g++ \
		make \
		nginx \
		nodejs \
		python-dev \
		supervisor \
		openssh-client \
		postgresql-dev \
		libmcrypt-dev

RUN docker-php-ext-install pdo_mysql pdo_pgsql mcrypt \
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
	&& composer config -g repo.packagist composer https://packagist.phpcomposer.com \
	&& composer global require "hirak/prestissimo:^0.3"

RUN npm install -g cnpm gulp bower yarn --registry=https://registry.npm.taobao.org \
    && yarn config set registry https://registry.npm.taobao.org

ENV PATH=$PATH:~/.composer/vendor/bin

COPY conf/php-fpm /usr/local/etc

COPY conf/etc /etc

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 600 /root/.ssh/id_rsa \
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
