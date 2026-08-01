FROM golang:alpine AS builder

WORKDIR /app

COPY . .

# Ищем настоящий go.mod или собираем из папки, где лежит main.go, с правильным именем модуля
RUN set -ex; \
    MAIN_PATH=$(find . -name "main.go" | head -n 1); \
    if [ -z "$MAIN_PATH" ]; then \
        echo "main.go not found"; \
        exit 1; \
    fi; \
    BUILD_DIR=$(dirname "$MAIN_PATH"); \
    cd "$BUILD_DIR"; \
    if [ ! -f "go.mod" ]; then \
        go mod init redwing; \
    fi; \
    go build -o /app/main .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
