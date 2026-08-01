FROM php:8.1-apache

# Устанавливаем системные зависимости, Java (для apktool) и wget
RUN apt-get update && apt-get install -y \
    default-jre \
    wget \
    git \
    libzip-dev \
    zip \
    && docker-php-ext-install zip pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем и устанавливаем apktool
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
RUN wget https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

# Копируем содержимое папки source/web прямо в корень Apache
COPY source/web/ /var/www/html/

# Настраиваем права доступа и разрешаем .htaccess (если нужен для роутинга)
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html \
    && sed -i '/<Directory \/var\/www\/html>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
    && a2enmod rewrite

EXPOSE 80
