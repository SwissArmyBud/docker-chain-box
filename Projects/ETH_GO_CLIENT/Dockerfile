# Build Geth in a stock Go builder container
FROM golang:1.12-alpine as builder
COPY /geth /geth
RUN \
    # Update Alpine and grab packages
    echo "Update Alpine and grab packages..." &&\
    apk update && apk upgrade &&\
    apk add --no-cache make gcc musl-dev linux-headers git && rm -rf /var/cache/apk/* &&\
    cd /geth &&\
    make all &&\
    mv /geth/build/bin/geth /usr/local/bin/ &&\
    mv /geth/build/bin/bootnode /usr/local/bin/ &&\
    echo "Go home and pack up application..." &&\
    cd / && tar -czf bins.tar.gz /usr/local/bin
# Pull Geth into a second stage deploy container
FROM alpine:3.9
COPY --from=builder bins.tar.gz /
COPY startup.sh /
ADD datadir /app/datadir/

ENTRYPOINT ["/bin/ash"]
CMD ["/startup.sh"]
