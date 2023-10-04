# Use a base image with the necessary dependencies
FROM ubuntu:20.04

# Set environment variables for MySQL root user password
ENV MYSQL_ROOT_PASSWORD=your_root_password

# Install required software
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx \
    mariadb-server \
    php-fpm \
    php-cli \
    php-mysql \
    php-json \
    php-mbstring \
    php-zip \
    php-gd \
    php-curl \
    php-ldap \
    php-redis \
    unzip \
    curl && \
    apt-get clean

# Install Composer (a PHP dependency manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Download and extract Pterodactyl panel and wings
WORKDIR /var/www
RUN curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz && \
    tar --strip-components=1 -xzvf panel.tar.gz && \
    rm panel.tar.gz

# Configure Nginx for Pterodactyl panel
COPY ./nginx.conf /etc/nginx/sites-available/default

# Install Pterodactyl wings
RUN apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php8.0 php8.0-{cli,xml,mbstring,zip,curl,gd,mysql,redis} && \
    mkdir -p /etc/pterodactyl && \
    curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 && \
    chmod +x /usr/local/bin/wings

# Expose ports
EXPOSE 80 3306

# Start services
CMD service mysql start && \
    service nginx start && \
    service php8.0-fpm start && \
    wings --config=/etc/pterodactyl/config.yml
