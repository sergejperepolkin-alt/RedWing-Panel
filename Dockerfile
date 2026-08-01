FROM golang:1.22-alpine AS builder

WORKDIR /app

# Копируем всё из корня репозитория
COPY . .

# Скачиваем зависимости и собираем проект из корня
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/main .

FROM alpine:latest

WORKDIR /app

# Копируем бинарник и статику
COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
