FROM alpine:3.9 as builder
COPY /netstats /app
RUN \
    # Update Alpine and grab packages
    echo "Update Alpine and grab packages..." &&\
    apk update && apk upgrade && apk add tar nodejs nodejs-npm && rm -rf /var/cache/apk/* &&\
    # Head into application and install deps, build, and clean up
    echo "Head into application and install deps, build, and clean up..." &&\
    cd /app &&\
    npm install && node /app/node_modules/grunt/lib/grunt.js &&\
    rm -rf /app/node_modules/grunt* && rm -rf /app/.git &&\
    # Go home and pack up application
    echo "Go home and pack up application..." &&\
    cd / &&\
    tar -czvf app.tar.gz /app &&\
    rm -rf /app

# Pull application into a second stage deploy container
FROM alpine:3.9
RUN \
    # Update Alpine and grab packages
    echo "Update Alpine and grab packages..." &&\
    apk update && apk upgrade && apk add tar nodejs && rm -rf /var/cache/apk/*
COPY --from=builder app.tar.gz /
COPY startup.sh /

ENTRYPOINT ["/bin/ash"]
CMD ["/startup.sh"]
