# Build Geth in a stock Go builder container
FROM golang:1.11.4-stretch as builder
RUN apt-get update -y &&\
    apt-get install -y make gcc musl-dev linux-headers-amd64 &&\
    git clone https://github.com/ethereum/go-ethereum ~/geth &&\
    cd ~/geth &&\
    make all && \
    ls -l ./build/bin
# Pull Geth into a second stage deploy container
FROM debian:stretch
RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get update -y &&\
    apt-get install -y bzip2 ca-certificates curl git gnupg gzip locales mercurial net-tools netcat openssh-client parallel sudo tar unzip wget xvfb zip &&\
    apt-get clean
COPY --from=builder /root/geth/build/bin/* /usr/local/bin/
ADD ./datadir /root/datadir
RUN \
    echo \
    '#!/bin/bash \n\
    set -e \n\
    if [ ! -f  /root/nodekey ] ; \n\
      then \n\
        bootnode -genkey /root/nodekey \n\
    fi \n\
    echo "[INFO] -> Starting gEth..." \n\
    geth --nodekey /root/nodekey \
         --datadir /root/datadir \
         --ethstats DockerNode-$((1000 + RANDOM % 9000)):socketsecret2@eth_net_front:3000  \
         "$@"' \
    > ~/startup.sh &&\
    chmod +x ~/startup.sh
ENTRYPOINT ["/root/startup.sh"]
