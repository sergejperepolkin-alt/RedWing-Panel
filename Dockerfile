FROM golang:alpine AS builder

WORKDIR /app

COPY . .

# Исправление: находим директорию, где реально лежит корневой go.mod проекта, и собираем модуль оттуда
RUN set -ex; \
    MOD_PATH=$(find . -name "go.mod" | head -n 1); \
    if [ -z "$MOD_PATH" ]; then \
        go mod init redwingapp; \
        go build -o /app/main .; \
    else \
        MOD_DIR=$(dirname "$MOD_PATH"); \
        cd "$MOD_DIR"; \
        go build -o /app/main .; \
    fi

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
