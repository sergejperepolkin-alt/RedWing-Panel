FROM golang:alpine AS builder

WORKDIR /app

COPY . .

# Исправление: go.mod лежит в ./source, но сам Go-код бэкенда находится чуть глубже или в подпапках source, ищем файл .go
RUN set -ex; \
    GO_FILE_DIR=$(dirname $(find . -name "*.go" | head -n 1)); \
    if [ "$GO_FILE_DIR" = "." ] || [ -z "$GO_FILE_DIR" ]; then \
        if [ ! -f "go.mod" ]; then go mod init redwingapp; fi; \
        go build -o /app/main .; \
    else \
        cd "$GO_FILE_DIR"; \
        if [ ! -f "go.mod" ] && [ ! -f "../go.mod" ]; then go mod init redwingapp; fi; \
        go build -o /app/main .; \
    fi

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
