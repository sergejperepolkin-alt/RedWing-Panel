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

# Копируем проект
COPY . /var/www/html/

# --- ПЕРЕНАПРАВЛЯЕМ APACHE ВНУТРЬ ПАПКИ С ПРОЕКТОМ ---
# (Замените "RedWing" или название вашей папки, если она называется иначе)
RUN sed -i 's!/var/www/html!/var/www/html/название_папки!g' /etc/apache2/sites-available/000-default.conf

# Настраиваем права
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
