FROM ubuntu:20.04

RUN apt-get update && apt-get install -y wget gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf git build-essential bison flex bc u-boot-tools

# To provide support for Raspberry Pi Zero W a toolchain tuned for ARMv6 architecture must be used.
# https://tracker.mender.io/browse/MEN-2399
RUN wget -nc -q https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2020.08-1.tar.bz2 \
    && tar -xjf aarch64--glibc--stable-2020.08-1.tar.bz2 \
    && rm aarch64--glibc--stable-2020.08-1.tar.bz2

COPY build-uboot-rpi.sh /usr/local/bin/

RUN apt-get install -y libssl-dev

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
