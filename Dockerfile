FROM golang:alpine AS builder

WORKDIR /app

COPY . .

# Ставим самую свежую версию Go из репозитория Alpine, чтобы версия go.mod подходила
RUN apk add --no-cache go git

RUN set -ex; \
    if [ -f "go.mod" ]; then \
        go build -o /app/main .; \
    elif [ -f "source/go.mod" ]; then \
        cd source && go build -o /app/main .; \
    else \
        go mod init app || true; \
        go build -o /app/main .; \
    fi

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
