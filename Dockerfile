# Базовый образ с поддержкой Go
FROM golang:1.21-bullseye

# Устанавливаем Java (нужна для apktool) и wget
RUN apt-get update && apt-get install -y default-jre wget

# Скачиваем apktool
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
RUN wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

# Рабочая директория
WORKDIR /app

# Копируем весь проект
COPY . .

# Если go.mod нет, создаем его автоматически и собираем проект
RUN go mod init redwing-panel || true
RUN go mod tidy || true
RUN go build -o main .

# Запуск приложения
CMD ["./main"]
