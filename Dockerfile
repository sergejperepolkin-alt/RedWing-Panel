# Выберите базовый образ (например, для Go)
FROM golang:1.21-bullseye

# Обновляем пакеты и устанавливаем Java (JRE), wget и другие зависимости
RUN apt-get update && apt-get install -y default-jre wget

# Скачиваем скрипт-обертку apktool и сам .jar файл
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
RUN wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar

# Делаем файлы исполняемыми
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы вашего проекта
COPY . .

# Собираем ваш проект (пример для Go)
RUN go build -o main .

# Команда для запуска вашего приложения
CMD ["./main"]
