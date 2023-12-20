FROM node:19-alpine as front-builder

RUN apk add --no-cache alpine-sdk

WORKDIR /app
ADD . /app

WORKDIR /app/frontend

RUN yarn install

WORKDIR /app

RUN make build-frontend

FROM golang:alpine as builder

RUN apk add --no-cache alpine-sdk

WORKDIR /app
ADD . /app
COPY --from=front-builder /app/frontend /app/frontend

RUN make dist

FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /listmonk

COPY --from=builder /app/listmonk .

COPY config.toml.sample config.toml
COPY config-demo.toml .
CMD sleep 5 && ./listmonk
EXPOSE 9000