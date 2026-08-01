# Используем базовый образ Ubuntu (чистая система)
FROM ubuntu:22.04

# Отключаем интерактивные запросы при установке программ
ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем Java (JRE), wget и другие необходимые утилиты
RUN apt-get update && apt-get install -y \
    default-jre \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем и устанавливаем apktool
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
RUN wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем все файлы вашего проекта
COPY . .

# Если ваш проект на Node.js, можно раскомментировать строчки ниже:
# RUN apt-get update && apt-get install -y nodejs npm
# RUN npm install

# Команда для запуска вашего приложения (замените на вашу, если нужно)
CMD ["./start.sh"]
