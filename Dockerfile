FROM golang:1.22-alpine AS builder

WORKDIR /app

# Копируем весь репозиторий целиком, чтобы файлы подпапок тоже попали в контейнер
COPY . .

# Ищем go.mod в корне или в любой подпапке, переходим туда и собираем бинарник
RUN set -ex; \
    if [ -f "go.mod" ]; then \
        go build -o /app/main .; \
    elif [ -f "source/go.mod" ]; then \
        cd source && go build -o /app/main .; \
    else \
        # Если go.mod вообще нет, инициализируем его на лету и собираем
        go mod init app || true; \
        go build -o /app/main .; \
    fi

# Финальный лёгкий образ для запуска
FROM alpine:latest

WORKDIR /app

# Копируем скомпилированный бинарник и папку со стадией/исходниками
COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
