FROM golang:alpine AS builder

WORKDIR /app

COPY . .

# Собираем Go-код из корня репозитория
RUN go build -o /app/main .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
