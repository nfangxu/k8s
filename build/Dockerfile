FROM registry.cn-beijing.aliyuncs.com/nfangxu/laranginx:1.2

WORKDIR /var/www/html

COPY . .
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && composer install --no-scripts --no-dev
RUN chown -R www-data /var/www/html/public && chown -R www-data /var/www/html/storage && cp .env.example .env

EXPOSE 443 80

CMD ["/init.sh"]