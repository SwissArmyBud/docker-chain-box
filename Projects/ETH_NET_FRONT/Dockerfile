# Start with something "normal" and "small"
FROM debian:stretch
RUN \
#   Update APT source/version database
    apt-get update &&\
#   Bring image up to par with CircleCI guidelines
    apt-get install -y bzip2 ca-certificates curl git gnupg gzip locales mercurial net-tools netcat openssh-client parallel sudo tar unzip wget xvfb zip &&\
#   Clean up
    apt-get clean
RUN \
#   Go home
    cd ~ &&\
    # Using Debian, as root
    curl -sL https://deb.nodesource.com/setup_10.x | bash - &&\
    apt-get install -y nodejs &&\
#   Clean up
    apt-get clean
RUN \
    npm install -g grunt-cli &&\
    npm install -g pm2 &&\
    git clone https://github.com/EthereumEx/eth-netstats.git ~/ethui &&\
    cd ~/ethui &&\
    npm install &&\
    grunt
RUN \
    echo \
    '#!/bin/bash \n\
    set -e \n\
    sleep 5s \n\
    echo "Starting node process ETH-NETSTATS..." \n\
    echo "Export value from Builder = $BUILD_EXPORT_PUTTY" \n\
    echo "Export value from Composer = $COMPOSE_EXPORT_PUTTY" \n\
    export WS_SECRET="socketsecret2" \n\
    cd /root/ethui \n\
    node ./bin/www' \
    > ~/startup.sh &&\
    chmod +x ~/startup.sh
ARG BUILD_EXPORT_SHIM
ENV BUILD_EXPORT_PUTTY=${BUILD_EXPORT_SHIM}
ENTRYPOINT ["/bin/bash"]
CMD ["/root/startup.sh"]
