# Этап сборки (Build stage)
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Копируем зависимости
COPY go.mod go.sum* ./
RUN go mod download

# Копируем весь исходный код
COPY . .

# Собираем бинарник (замени main.go на главный файл твоего бэкенда на Go, если он называется иначе)
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Финальный лёгкий образ
FROM alpine:latest

WORKDIR /app

# Копируем скомпилированный бинарник и статику (если нужно)
COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

# Указываем порт из переменной окружения Render
ENV PORT=10000
EXPOSE 10000

# Запускаем скомпилированный Go-файл
CMD ["./main"]
