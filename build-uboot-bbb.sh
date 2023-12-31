#!/bin/bash
# Copyright 2022 Northern.tech AS
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# Script to generate Mender integration binaries for Beaglebone Black
#
# Files that will be packaged:
#
#     - u-boot.img
#     - MLO
#     - fw_printenv
#     - fw_env.config
#
# NOTE! This script is not necessarily well tested and the main purpose
# is to provide an reference on how the current integration binaries where
# generated.

set -e

UBOOT_MENDER_BRANCH=2018.07

uboot_build() {
    local os=$1
    local media=$2
    local CROSS_COMPILE=arm-linux-gnueabi-
    local ARCH=arm
    local MAKE="make -j $(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}"

    # Test if the toolchain is actually installed
    ${CROSS_COMPILE}gcc --version

    ${MAKE} mrproper
    case ${media} in
        "sdcard") DEFCONFIG=am335x_boneblack_defconfig;;
        "emmc") DEFCONFIG=am335x_boneblack_emmc_defconfig;;
        *) echo Unknown target media ${media}; exit 0;;
    esac

    ${MAKE} ${DEFCONFIG}
    ${MAKE}
    ${MAKE} envtools
    cp tools/env/fw_printenv .
}

generate_fw_env_config() {
    local os=$1
    local media=$2
    case ${os}:${media} in
        debian:sdcard )
            cat <<- "EOF" > fw_env.config
		/dev/mmcblk0 0x800000 0x20000
		/dev/mmcblk0 0x1000000 0x20000
		EOF
            ;;
        debian:emmc )
            cat <<- "EOF" > fw_env.config
		/dev/mmcblk1 0x800000 0x20000
		/dev/mmcblk1 0x1000000 0x20000
		EOF
            ;;
        * )
            echo "Unknown OS and Media combination ${os}:${media}."
            exit 1
            ;;
    esac
}

for TARGET_OS in debian; do
    rm -rf uboot-mender
    git clone https://github.com/mendersoftware/uboot-mender.git -b mender-bbb-${TARGET_OS}-${UBOOT_MENDER_BRANCH}
    cd uboot-mender
    git log --graph --pretty=oneline -15 > uboot-git-log.txt
    for TARGET_MEDIA in sdcard emmc; do
        uboot_build ${TARGET_OS} ${TARGET_MEDIA}
        generate_fw_env_config ${TARGET_OS} ${TARGET_MEDIA}
        BEAGLEBONE_BLACK_CONFIG="beaglebone_black_${TARGET_OS}_${TARGET_MEDIA}"
        tar czvf ../${BEAGLEBONE_BLACK_CONFIG}-${UBOOT_MENDER_BRANCH}.tar.gz \
            uboot-git-log.txt \
            u-boot.img \
            MLO \
            fw_printenv \
            fw_env.config
    done
done
