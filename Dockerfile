FROM golang:alpine AS builder

WORKDIR /app

COPY . .

# Автоматически ищем папку, где лежит go.mod, переходим в неё, инициализируем модуль если его нет, и собираем проект
RUN set -ex; \
    MOD_DIR=$(dirname $(find . -name "go.mod" | head -n 1)); \
    if [ "$MOD_DIR" = "." ] || [ -z "$MOD_DIR" ]; then \
        if [ ! -f "go.mod" ]; then go mod init redwingapp; fi; \
        go build -o /app/main .; \
    else \
        cd "$MOD_DIR"; \
        go build -o /app/main .; \
    fi

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .
# Копируем статику из корня или из той же папки, где исходники
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
