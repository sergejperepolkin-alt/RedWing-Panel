FROM golang:1.22-alpine AS builder

WORKDIR /app

# Копируем зависимости
COPY go.mod go.sum* ./
RUN go mod download

# Копируем весь код проекта
COPY . .

# Собираем бинарник бэкенда
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Финальный лёгкий образ для запуска
FROM alpine:latest

WORKDIR /app

# Переносим скомпилированное приложение и статику
COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
