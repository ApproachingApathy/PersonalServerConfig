FROM golang:1.16-alpine as build-stage

WORKDIR /app

RUN apk update && apk add --no-cache wget git gcc musl-dev make sqlite 
RUN apk add --no-cache curl \     
  && curl -L https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-armv7.tar.gz | tar xzv \
  && mv migrate /usr/local/bin/migrate \     
  && apk del curl

RUN git clone https://github.com/oxtyped/gpodder2go.git /app/gpodder2go
# RUN cd /app/gpodder2go && git checkout tags/v0.1.1

RUN cd /app/gpodder2go && make build



FROM alpine:latest

ARG VERIFIER_SECRET_KEY 'TopSecretKey'
ARG G2G_USERNAME "gpod"
ARG G2G_EMAIL ""
ARG G2G_DISPLAY_NAME "gpod"
ARG G2G_PASSWORD ""

EXPOSE 3305

COPY --from=build-stage /app/gpodder2go/gpodder2go /app/gpodder2go
RUN mkdir /app/data
RUN mkdir /app/migrations
RUN touch /app/migrations/.

RUN cd /app && ./gpodder2go init -d /app/data/g2g.db
# Run
CMD ["sh", "-c", "cd /app && ./gpodder2go serve -b 0.0.0.0:3305 -d /app/data/g2g.db"]

RUN cd /app && ./gpodder2go accounts --api-addr='0.0.0.0:3305' create $G2G_USERNAME --email="$G2G_EMAIL" --name="$G2G_DISPLAY_NAME" --password="$G2G_PASSWORD" -d "/app/data/g2g.db"
