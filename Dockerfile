# Выберите базовый образ
FROM golang:1.21-bullseye

# Обновляем пакеты и устанавливаем Java (JRE), wget и другие зависимости
RUN apt-get update && apt-get install -y default-jre wget

# Скачиваем скрипт-обертку apktool и сам .jar файл
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
RUN wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar

# Делаем файлы исполняемыми
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

# Копируем весь проект
WORKDIR /app
COPY . .

# Переходим внутрь папки с кодом (если она называется RedWing)
WORKDIR /app/RedWing

# Подтягиваем зависимости и собираем проект
RUN go mod tidy || true
RUN go build -o main .

# Команда для запуска (указываем путь к скомпилированному файлу внутри папки)
CMD ["./main"]
