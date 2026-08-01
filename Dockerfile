FROM golang:1.22-alpine AS builder

WORKDIR /app

# Копируем весь репозиторий целиком, чтобы найти go.mod в любой подпапке
COPY . .

# Если go.mod лежит в подпапке (например, в source/), переходим туда для сборки
# Если go.mod в корне, эта команда просто выполнится в /app
RUN find . -name "go.mod" -execdir go mod download \;
RUN find . -name "go.mod" -execdir go build -o /app/main . \;

# Финальный лёгкий образ
FROM alpine:latest

WORKDIR /app

# Копируем скомпилированный бинарник и файлы проекта
COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
