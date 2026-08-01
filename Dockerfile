FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем Java (нужна для apktool), wget и ca-certificates
RUN apt-get update && apt-get install -y \
    default-jre \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем официальную оболочку apktool
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool

# Скачиваем актуальный .jar файл apktool (версия 2.9.3 с GitHub)
RUN wget https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar

# Делаем файлы исполняемыми
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

WORKDIR /app
COPY . .

CMD ["./start.sh"]
