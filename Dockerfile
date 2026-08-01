=FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY . .

# Находим настоящий go.mod во вложенных папках репозитория, переходим туда и собираем бинарник
RUN set -ex; \
    MOD_FILE=$(find . -name "go.mod" | head -n 1); \
    if [ -z "$MOD_FILE" ]; then \
        echo "Error: go.mod not found anywhere in repository!"; \
        exit 1; \
    fi; \
    BUILD_DIR=$(dirname "$MOD_FILE"); \
    echo "Found go.mod in: $BUILD_DIR"; \
    cd "$BUILD_DIR"; \
    go build -o /app/main .

FROM alpine:latest

WORKDIR /app

# Копируем скомпилированный бинарник
COPY --from=builder /app/main .
# Копируем статику/исходники, если они нужны приложению для работы
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
