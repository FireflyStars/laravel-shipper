FROM x3tech/nginx-hhvm
MAINTAINER {{ $maintainer }}

# Install dependencies
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean

# Add composer
RUN php -r 'readfile("https://getcomposer.org/installer");' | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer

ADD . /var/www/

RUN cd /var/www/ && \
    composer update && \
    chown -R www-data:www-data /var/www/
