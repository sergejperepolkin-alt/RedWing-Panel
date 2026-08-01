FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY . .

RUN go mod init redwing || true
RUN go mod tidy || true
RUN go build -o /app/main .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/source ./source

ENV PORT=10000
EXPOSE 10000

CMD ["./main"]
