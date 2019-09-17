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
git clone https://github.com/mendersoftware/uboot-mender.git -b mender-bbb-${UBOOT_MENDER_BRANCH}
cd uboot-mender
make am335x_boneblack_defconfig
make
make envtools

cat <<- EOF > fw_env.config
/dev/mmcblk0 0x800000 0x20000
/dev/mmcblk0 0x1000000 0x20000
EOF

mkdir integration-binaries
cp u-boot.img MLO tools/env/fw_printenv fw_env.config integration-binaries/
git log --graph --pretty=oneline -15 > integration-binaries/uboot-git-log.txt
cd integration-binaries

tar cvf beaglebone-black-integration-${UBOOT_MENDER_BRANCH}.tar ./*
cd -
