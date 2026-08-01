FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем системные зависимости, Java, PHP и wget
RUN apt-get update && apt-get install -y \
    default-jre \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    php-zip \
    php-mysql \
    wget \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем apktool
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
RUN wget https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

WORKDIR /app

# Копируем весь репозиторий
COPY . .

# Находим папку с index.php или index.html и запускаем PHP-сервер оттуда
CMD ["bash", "-c", "INDEX_FILE=$(find . -name 'index.php' -o -name 'index.html' | head -n 1); if [ -n \"$INDEX_FILE\" ]; then WEB_DIR=$(dirname \"$INDEX_FILE\"); else WEB_DIR='.'; fi; echo 'Serving from: ' $WEB_DIR; php -S 0.0.0.0:$PORT -t \"$WEB_DIR\""]
