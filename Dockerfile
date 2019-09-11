FROM ubuntu:19.04

RUN apt-get update && apt-get install -y gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf git build-essential bison flex bc u-boot-tools

COPY build-uboot-bbb.sh /usr/local/bin/
COPY build-uboot-rpi3.sh /usr/local/bin/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
