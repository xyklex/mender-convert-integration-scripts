#!/bin/bash

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

export CROSS_COMPILE=arm-linux-gnueabi-
export ARCH=arm

# Test if the toolchain is actually installed
${CROSS_COMPILE}gcc --version

UBOOT_MENDER_BRANCH=2018.07

for TARGET_OS in debian; do
    rm -rf uboot-mender
    git clone https://github.com/mendersoftware/uboot-mender.git -b mender-bbb-${TARGET_OS}-${UBOOT_MENDER_BRANCH}
    cd uboot-mender
    git log --graph --pretty=oneline -15 > uboot-git-log.txt
    make am335x_boneblack_defconfig
    make
    make envtools
    case ${TARGET_OS} in
        debian )
            cat <<- "EOF" > fw_env.config
		/dev/mmcblk0 0x800000 0x20000
		/dev/mmcblk0 0x1000000 0x20000
		EOF
            cp tools/env/fw_printenv .
            FILES="uboot-git-log.txt u-boot.img MLO fw_printenv fw_env.config"
            ;;
    esac
    tar cvf ../beaglebone-black-integration-${TARGET_OS}-${UBOOT_MENDER_BRANCH}.tar ${FILES}
    cd -
done
