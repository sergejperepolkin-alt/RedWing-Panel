FROM golang:alpine AS builder

WORKDIR /app

COPY . .

# Абсолютно безошибочная сборка Go: проверяем корень и папки, если go.mod отсутствует, создаем его на лету
RUN set -ex; \
    if [ -f "go.mod" ]; then \
        go build -o /app/main .; \
    elif [ -f "source/go.mod" ]; then \
        cd source && go build -o /app/main .; \
    else \
        go mod init redwingapp; \
        go build -o /app/main .; \
    fi

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
