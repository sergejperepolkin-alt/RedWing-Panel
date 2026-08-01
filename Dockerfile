FROM golang:1.21-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем Java (для apktool) и wget
RUN apt-get update && apt-get install -y \
    default-jre \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Установка apktool и jar-файла
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
RUN wget https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

WORKDIR /app
COPY . .

# Собираем Go-приложение прямо внутри контейнера
RUN go build -o main .

# Запускаем скомпилированный файл
CMD ["./main"]
