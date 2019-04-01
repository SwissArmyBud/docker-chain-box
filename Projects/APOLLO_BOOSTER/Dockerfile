# Build Geth in a stock Go builder container
FROM golang:1.12-alpine as builder
COPY /apollo /usr/local/go/src/blockitrocket.com/git/apollo
COPY env /usr/local/go/src/blockitrocket.com/git/apollo/env
RUN \
  apk add --no-cache make git gcc musl-dev linux-headers &&\
  echo "Dependency resolution for go executable..." &&\
  cd /usr/local/go/src/blockitrocket.com/git/apollo && go get &&\
  echo "Fetching golang DB driver and ORM package..." &&\
  go get -u github.com/beego/bee &&\
  go get -u github.com/astaxie/beego &&\
  echo "Compiling go executable..." &&\
  go build &&\
  echo "Installing PostgreSQL..." &&\
  apk add --no-cache postgresql postgresql-contrib tar &&\
  source ./env &&\
  echo "Setting up PostgreSQL DB..." &&\
  mkdir -p /app/pgsql/log && chown -R postgres /app/pgsql &&\
  mkdir -p /run/postgresql && chown -R postgres /run/postgresql &&\
  su postgres -c "initdb -D /app/pgsql/data -U postgres" &&\
  su postgres -c "pg_ctl -D /app/pgsql/data start" &&\
  echo "Migrating project to PostgreSQL..." &&\
  bee migrate -conn="$DB_CONN_INIT" -driver=postgres -dir="./database/init" &&\
  bee migrate -conn="$DB_CONN" -driver=postgres &&\
  su postgres -c "pg_ctl -D /app/pgsql/data stop"
RUN \
  # Go home and pack up application
  cp /usr/local/go/src/blockitrocket.com/git/apollo/apollo /app &&\
  echo "Go home and pack up application..." &&\
  cd / && tar -czf app.tar.gz /app

# Pull all binaries into a second stage deploy alpine container
FROM alpine:3.9

RUN \
    apk add --no-cache ca-certificates postgresql postgresql-contrib
COPY --from=builder app.tar.gz /
COPY env /
COPY startup.sh /
COPY /apollo/conf/app.conf /app.conf
ENTRYPOINT ["/bin/ash"]
CMD ["/startup.sh"]
